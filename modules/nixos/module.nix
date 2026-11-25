{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.programs.nixdg-ninja;
in {
  imports = [
    ../options.nix
  ];

  config = mkIf cfg.enable {
    xdg.directories.enable = true;

    environment = let
      enabledPrograms = lib.filterAttrs (_: v: v.enable) cfg.programs;

      allFilesByTarget =
        lib.concatMapAttrs (
          _: prog:
            lib.mapAttrs (_: file: {inherit (file) text;})
            (lib.filterAttrs (_: file: file.enable && file.text != null) prog.files)
        )
        enabledPrograms;
    in {
      # Set up global variables from collected variables
      variables = cfg.env.globalVars;

      sessionVariables.XDG_BIN_HOME = "$HOME/.local/bin";

      # Link files associated with enabled programs
      etc = allFilesByTarget;
    };
  };
}
