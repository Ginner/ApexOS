# Evaluate with a generated programs.quickshell.configs.apex derivation.
# This builds a separate test configuration; the installed shell is untouched.
shell:
shell.overrideAttrs (old: {
  name = "apex-quickshell-smoke";
  buildCommand = old.buildCommand + ''
    mv "$out/shell.qml" "$out/Production.qml"
    chmod u+w "$out/Bar.qml"
    substituteInPlace "$out/Bar.qml" --replace-fail 'id: root' 'id: root; visible: false'
    cp ${./smoke.qml} "$out/shell.qml"
  '';
})
