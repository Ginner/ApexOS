# Isolated, offscreen test. Replace privileged commands with a harmless fixture.
shell:
shell.overrideAttrs (old: {
  name = "apex-quickshell-battery-test";
  buildCommand = old.buildCommand + ''
    chmod u+w "$out/Settings.qml" "$out/Services.qml" "$out/shell.qml"
    # Use the build shell's interpreter, retained as a store reference.
    printf '#!%s\n' "$SHELL" > "$out/charge-fixture"
    cat >> "$out/charge-fixture" <<'EOF'
    case "$3" in
      fullcharge) exit 0 ;;
      setcharge) echo 'fixture restore failure' >&2; exit 1 ;;
      *) exit 2 ;;
    esac
    EOF
    chmod +x "$out/charge-fixture"
    substituteInPlace "$out/Settings.qml" --replace-fail /run/wrappers/bin/sudo "$out/charge-fixture"
    substituteInPlace "$out/Services.qml" \
      --replace-fail 'Settings.data.noBattery ? null : UPower.displayDevice' \
        '({ready: true, isPresent: true, percentage: 1, state: UPowerDeviceState.FullyCharged, timeToFull: 0, timeToEmpty: 0})'
    cp ${./battery.qml} "$out/shell.qml"
  '';
})
