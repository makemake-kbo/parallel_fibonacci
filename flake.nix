{
  description = "Blutgang - The WD40 of Ethereum load balancers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" ] (system:
      let
        overlays = [ rust-overlay.overlays.default ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        cargoMeta = builtins.fromTOML (builtins.readFile ./Cargo.toml);
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gcc
            pkg-config
            openssl
            systemd
            clang
            gdb
            go
            valgrind
            python311Packages.requests
            python311Packages.websocket-client
            ocamlPackages.ocaml
            ocamlPackages.dune_3
            ocamlPackages.findlib
            ocamlPackages.utop
            ocamlPackages.odoc
            ocamlPackages.ocaml-lsp
            ocamlformat
            (rust-bin.nightly.latest.default.override {
              extensions = [ "rust-src" "rustfmt-preview" "rust-analyzer" ];
            })
          ];

          shellHook = ''
            export CARGO_BUILD_RUSTC_WRAPPER=$(which sccache)
            export RUSTC_WRAPPER=$(which sccache)
            export OLD_PS1="$PS1" # Preserve the original PS1
            export PS1="nix-shell:fib $PS1" # Customize this line as needed

            # Set NIX_LD and NIX_LD_LIBRARY_PATH for rust-analyzer
            # export NIX_LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.glibc pkgs.gcc-unwrapped.lib ]}"
            # export NIX_LD="${pkgs.stdenv.cc}/nix-support/dynamic-linker"
          '';

          # reset ps1
          shellExitHook = ''
            export PS1="$OLD_PS1"
          '';
        };
      }
    );
}
