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

        # 0.3.7+ does exist, but I couldn't get it to work 🤷
        otel-tui-version = "0.3.6";

        otel-tui = pkgs.buildGo123Module {
          pname = "otel-tui";
          version = "${otel-tui-version}";

          src = pkgs.fetchFromGitHub {
            owner = "ymtdzzz";
            repo = "otel-tui";
            tag = "v${otel-tui-version}";
            sha256 = "sha256-K/Cwdu/BDxS9FniQJxp005V+HoZFiu+S5/yRZg3aOz8=";
          };
          vendorHash = "sha256-zHBM+nVwYuTTeObb74T6Lp9et9qDJjtZlxEkvYovhns=";

          modRoot = ".";
          subPackages = [ "." ];

          # Disable Go Workspaces; Not supported by the nix build system (yet?).
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
      }
    );
}
