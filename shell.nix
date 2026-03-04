# To activate this environment, run:
#   nix-shell shell.nix
let
  nixpkgs = import <nixpkgs> {};
in
  with nixpkgs;
  stdenv.mkDerivation {
    name = "site-env";
    buildInputs = [
      jdk21_headless
    ];

    shellHook = ''
      export PATH="/Users/aeciosantos/workspace/personal/sitegen/build/install/sitegen/bin:$PATH"
    '';
  }
