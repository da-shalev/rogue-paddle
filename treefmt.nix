{ ... }:

{
  projectRootFile = "flake.nix";

  programs = {
    stylua.enable = true;
  };

  settings.formatter = {
    stylua.settingsFile = ./.stylua.toml;
  };
}
