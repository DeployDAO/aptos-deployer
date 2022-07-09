{ pkgs }:
with pkgs;
stdenv.mkDerivation {
  name = "devshell";
  buildInputs = [
    aptos
    move-cli-aptos
  ];
}
