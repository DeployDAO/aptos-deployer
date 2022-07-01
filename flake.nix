{
  description = "Aptos Nix overlay.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # dotnet (mono, boogie dependency) is wrongfully marked broken
          # https://discourse.nixos.org/t/why-was-dotnet-marked-broken-on-darwin/19473/2
          config.allowBroken = true;
          config.allowUnsupportedSystem = true;

          overlays = [
            (self: super: {
              mono6 = super.mono6.overrideAttrs (old: {
                version = "6.12.0.168";
                src = super.fetchurl {
                  sha256 = "sha256:1b0hhd6a0l0b62x601ics8m2fnvwknnkj8nn96v3gxymng5r3y65";
                  url = "https://download.mono-project.com/sources/mono/preview/mono-6.12.0.168.tar.xz";
                };
              });
            })
          ];
        };
      in
      {
        devShells = {
          default = with pkgs; stdenv.mkDerivation {
            name = "devshell";
            # See: <https://github.com/move-language/move/blob/2dabc08cb115a2385d3844b681917dd3129a30fe/scripts/dev_setup.sh>
            buildInputs = [
              # Build tools
              rustup

              cmake
              clang
              pkg-config
              openssl
              libclang

              nodejs

              # Move prover
              z3
              # boogie
              cvc5
              dotnet-sdk

              # Git
              git
            ] ++ (lib.optionals stdenv.isDarwin ([
              libiconv
            ] ++ (with darwin.apple_sdk.frameworks; [
              DiskArbitration
              Foundation
            ])));

            LIBCLANG_PATH = "${libclang}/lib";

            shellHook = ''
              dotnet tool install --global boogie
              export PATH=$HOME/.dotnet/tools:$PATH
              export DOTNET_ROOT=${dotnet-sdk}
              export BOOGIE_EXE=$HOME/.dotnet/tools/boogie
            '';
          };
        };
      });
}
