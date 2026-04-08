{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    templ.url = "github:a-h/templ";
    # templ.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      templ,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        templui = pkgs.buildGoModule rec {
          pname = "templui";
          version = "0.97.0";

          src = pkgs.fetchFromGitHub {
            owner = "axzilla";
            repo = "templui";
            tag = "v${version}";
            hash = "sha256-Mj1sad+cZKOTwrU6YxgS3IMQYm2BOIPpm4ssbEkE3Nw=";
          };

          nativeBuildInputs = [
            templ.packages.${system}.templ
          ];

          preBuild = ''
            templ generate
          '';

          vendorHash = "sha256-WPr+fXSCdZ4ENMG5ALxlTVfzx4wKb1gSu22POjQFbEI=";

          meta = {
            description = "The UI Kit for templ";
            homepage = "https://templui.io/";
            license = pkgs.lib.licenses.mit;
          };
        };
        go-migrate-pg = pkgs.go-migrate.overrideAttrs (oldAttrs: {
          tags = [ "postgres" ];
        });
      in
      rec {
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            go
            (templ.packages.${system}.templ)
            nodejs
            air
            overmind
            delve
            tailwindcss_4
            templui
          ];

          shellHook = ''
            export ENVIRONMENT=dev

            # needed for debugging with delve
            export CGO_CFLAGS="-O2"
            export CGO_CPPFLAGS="-O2"

            #CURRENT_DIR=$(pwd)
            #tmuxp load "$CURRENT_DIR"
          '';
        };

        packages.go-blog = pkgs.buildGoModule {
          pname = "go-blog";
          version = "0.5";

          src = ./.;

          vendorHash = "sha256-q9MUb+zhEKzDGSxJga3nxkT1iP++ckrxbsbTvW3QQhw=";

          nativeBuildInputs = [
            templ.packages.${system}.templ
          ];

          preBuild = ''
            templ generate
          '';

        };

        packages.blog-image = pkgs.dockerTools.buildLayeredImage {
          name = "info6141-blog";
          config = {
            Cmd = [
              "${packages.go-blog}/bin/blog"
            ];
            ExposedPorts = {
              "8080/tcp" = { };
            };
          };
        };

        defaultPackage = packages.go-blog;
      }
    );
}
