{
  description = "Crystal 2 Nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    (with flake-utils.lib; eachSystem defaultSystems) (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        crystal2nixPkg = pkgs.crystal.buildCrystalPackage {
          pname = "crystal2nix";
          inherit (pkgs.lib.importJSON ./version.json) version;

          src = ./.;

          format = "shards";
          lockFile = ./shard.lock;
          shardsFile = ./shards.nix;

          buildInputs = with pkgs; [ openssl ];

          nativeBuildInputs = with pkgs; [ pkg-config ];
        };

        specCheck = pkgs.stdenvNoCC.mkDerivation {
          pname = "crystal2nix-specs-offline";
          version = (pkgs.lib.importJSON ./version.json).version;
          src = ./.;

          nativeBuildInputs = with pkgs; [
            crystal
            shards
            openssl
            pkg-config
          ];

          dontInstall = true;

          buildPhase = ''
            shards install
            crystal spec spec/repo_spec.cr spec/prefetch_spec.cr spec/shards_nix_spec.cr
          '';
        };

        onlineSpecCheck = pkgs.stdenvNoCC.mkDerivation {
          pname = "crystal2nix-specs-online";
          version = (pkgs.lib.importJSON ./version.json).version;
          src = ./.;

          # Prefetching requires network access inside the Nix builder.
          __impure = true;

          nativeBuildInputs = with pkgs; [
            crystal
            shards
            openssl
            pkg-config
            nix
            nix-prefetch-git
            nix-prefetch-hg
            nix-prefetch-fossil
            git
            mercurial
            fossil
          ];

          dontInstall = true;

          buildPhase = ''
            shards install
            export CRYSTAL2NIX_ONLINE_TESTS=1
            crystal spec spec/integration_spec.cr
          '';
        };

      in
      rec {
        packages = flake-utils.lib.flattenTree rec {
          crystal2nix = crystal2nixPkg;
          default = crystal2nix;
        };

        checks = flake-utils.lib.flattenTree {
          default = crystal2nixPkg;
          specs-offline = specCheck;
          specs-online = onlineSpecCheck;
        };

        devShells = flake-utils.lib.flattenTree {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              openssl
            ];

            nativeBuildInputs = with pkgs; [
              pkg-config
              crystal
              shards
              nix
              nix-prefetch-git
              nix-prefetch-hg
              nix-prefetch-fossil
              git
              mercurial
              fossil
            ];
          };
        };
      }
    );
}
