# Run this separate fixture with QT_QPA_PLATFORM=offscreen.
shell:
shell.overrideAttrs (old: {
  name = "apex-quickshell-statistics-test";
  buildCommand = old.buildCommand + ''
    cp --remove-destination ${./statistics.qml} "$out/shell.qml"
  '';
})
