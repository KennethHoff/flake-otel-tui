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

        otel-tui-version = "0.4.1";

        otel-tui = pkgs.buildGo123Module {
          pname = "otel-tui";
          version = "${otel-tui-version}";

          src = pkgs.fetchFromGitHub {
            owner = "ymtdzzz";
            repo = "otel-tui";
            tag = "v${otel-tui-version}";
            sha256 = "sha256-oe0V/iTo7LPbajLVRbjQTTqDaht/SnONAaaKwrMWRKI=";
          };

          vendorHash = "sha256-yUD+9tvBr2U1U7+WXqz6sKt9EBXGQCWVyYRYCDRENf4=";

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
