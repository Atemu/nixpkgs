{ stdenv
, src
, fetchFromGitHub
, rustPlatform
, bash
, pkgs # FIXME
}:

let
  pname = "ankirspy";
  version = "2.1.28";

  # TODO move to default.nix
  desktopFtl = fetchFromGitHub {
    owner = "ankitects";
    repo = "anki-desktop-ftl";
    rev = "8b0520e63b9537d2431c31501c3561e086978648";
    sha256 = "06fyj7lfnvj44zldj8pgs8ik4cs8p3s01hg2ra7kh4dih304ma6h";
  };
in

rustPlatform.buildRustPackage {
  inherit pname version;

  # TODO copy rspy into main dir and make anki its sub dir, link anki/rspy to main dir
  src = pkgs.runCommand "source" { inherit src desktopFtl; lock = ./Cargo.lock; toml = ./Cargo.toml; } ''
    cp -r $src/. $out
    # We don't have write permission now for some reason
    chmod -R u+rw $out

    # We need to update pyo3 to a version that builds without experimental Rust features
    cp $toml $out/rspy/Cargo.toml
    # Upstream doesn't ship Cargo.lock and we modified the TOML
    cp $lock $out/rspy/Cargo.lock

    # rslib build.rs needs the paths in FTL_TEMPLATE_DIRS and QT_FTL_LOCALES
    cp -a $out/qt/ $out/rslib/
    # and translations from external repos
    cp -a $desktopFtl $out/rslib/qt/ftl/repo/

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


  buildPhase = ''
    HOME=$NIX_BUILD_TOP
    FTL_TEMPLATE_DIRS="./qt/ftl" QT_FTL_LOCALES="./qt/ftl/repo/desktop" ${pkgs.maturin}/bin/maturin build -i ${pkgs.python3}/bin/python -o $out --release --strip
  '';
}
