{
  inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      treefmt-nix,
    }:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      apps = eachSystem (pkgs: {
        default = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "run-game" ''
            cd ${./src}
            exec ${pkgs.lib.getExe pkgs.love} .
          ''}/bin/run-game";
        };
      });

      devShell = eachSystem (
        pkgs:
        pkgs.mkShellNoCC {
          packages = with pkgs; [ love ];
        }
      );
    };
}
