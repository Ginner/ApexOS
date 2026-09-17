# Run this separate fixture with QT_QPA_PLATFORM=offscreen.
shell:
shell.overrideAttrs (old: {
  name = "apex-quickshell-menu-test";
  buildCommand = old.buildCommand + ''
    cp --remove-destination ${./menu.qml} "$out/shell.qml"
  '';
})
