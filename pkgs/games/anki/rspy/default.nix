{ stdenv
, src
, rustPlatform
, bash
, pkgs # FIXME
}:

let
  pname = "ankirspy";
  version = "2.1.28";
in

rustPlatform.buildRustPackage {
  inherit pname version;
  # inherit src;
  # src = pkgs.runCommand "mkSubProject" { inherit src; } ''
  #   cp -a $src/rspy $out
  # '';
  src = pkgs.runCommand "source" { inherit src; lock = ./Cargo.lock; toml = ./Cargo.toml; } ''
    cp -r $src/. $out
    # We don't have write permission now for some reason
    chmod -R u+rw $out

    # We need to update pyo3 to a version that builds without experimental Rust features
    cp $toml $out/rspy/Cargo.toml
    # Upstream doesn't ship Cargo.lock and we modified the TOML
    cp $lock $out/rspy/Cargo.lock

    # rspy needs rslib to build but isn't permitted access because it's not in sourceRoot
    cp -a $out/rslib/ $out/rspy/
  '';

  sourceRoot = "source/rspy"; # needed for fetchCargoTarball to work

  cargoSha256 = "1yvnpvw3x9irsjgfhgmdrbz1fln6ai1xslfajsxh1xahiz90p6w5";

  buildInputs = with pkgs; [
    openssl
  ];
  nativeBuildInputs = with pkgs; [
    pkgconfig
    perl
  ];

  # pyo3 requires Rust nightly.
  RUSTC_BOOTSTRAP = 1;

  buildPhase = ''
    HOME=$NIX_BUILD_TOP
    RUST_BACKTRACE=full \
    FTL_TEMPLATE_DIRS="../qt/ftl" ${pkgs.maturin}/bin/maturin build -i ${pkgs.python3}/bin/python -o $out --release --strip
  '';
}
