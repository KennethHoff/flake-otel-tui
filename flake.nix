{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        # Version >=0.4 exists, but I couldn't get it working for some reason.
        otel-tui-version = "0.3.10";

        otel-tui = pkgs.buildGo123Module {
          pname = "otel-tui";
          version = "${otel-tui-version}";

          src = pkgs.fetchFromGitHub {
            owner = "ymtdzzz";
            repo = "otel-tui";
            tag = "v${otel-tui-version}";
            sha256 = "sha256-Xv+AfXT5fMgovGB/02btRDujwWJK6UgZ53xYtjp+qcY=";
          };

          vendorHash = "sha256-f9inY8qVcF8d3HCKp5EA+d/+dMo+uI8bbJedhVnHlY4=";

          subPackages = [ "." ];

          # Do not use Go Workspaces as they're not supported by the nix build system.
          env.GOWORK = "off";

          buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.xorg.libX11 ];
        };
      in
      {
        packages = {
          otel-tui = otel-tui;
          default = otel-tui;
        };
        defaultPackage = otel-tui;
        devShells.default = pkgs.mkShell {
          buildInputs = [ otel-tui ];
        };
      }
    );
}
