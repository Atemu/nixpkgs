{ stdenv
, src
, fetchFromGitHub
, rustPlatform
, bash
, pkgs # FIXME
}:

let
  pname = "ankirslib";
  version = "2.1.28";

  desktopFtl = fetchFromGitHub {
    owner = "ankitects";
    repo = "anki-desktop-ftl";
    rev = "8b0520e63b9537d2431c31501c3561e086978648";
    sha256 = "06fyj7lfnvj44zldj8pgs8ik4cs8p3s01hg2ra7kh4dih304ma6h";
  };
in

rustPlatform.buildRustPackage {
  inherit pname version;
  # inherit src;
  # src = pkgs.runCommand "mkSubProject" { inherit src; } ''
  #   cp -a $src/rspy $out
  # '';
  src = pkgs.runCommand "source" { inherit src desktopFtl; lock = ./Cargo.lock; } ''
    cp -r $src/. $out
    chmod -R u+rw $out

    cp $lock $out/rslib/Cargo.lock

    #
    cp -a $out/qt/ $out/rslib/

    cp -a $desktopFtl $out/rslib/qt/ftl/repo/
  '';

  sourceRoot = "source/rslib"; # needed for fetchCargoTarball to work

  cargoSha256 = "11g58spipxw9p9zgxw3kdq0k41ribxw0jhwvd818jr8ham4nndxg";

  buildInputs = with pkgs; [
    openssl
  ];
  nativeBuildInputs = with pkgs; [
    pkgconfig
    perl
  ];

  postPatch = ''
    # substituteInPlace $NIX_BUILD_TOP/$cargoDepsCopy/pyo3/build.rs \

    rm $NIX_BUILD_TOP/$cargoDepsCopy/prost-build/third-party/protobuf/protoc-linux-x86_64
    ln -s ${pkgs.protobuf}/bin/protoc $NIX_BUILD_TOP/$cargoDepsCopy/prost-build/third-party/protobuf/protoc-linux-x86_64

    # Patching the vendored dependency invalidates the file
    # checksums, so remove them. This should be safe, since
    # this is just a copy of the vendored dependencies and
    # the integrity of the vendored dependencies is validated
    # by cargoSha256.
    sed -r -i 's|"files":\{[^}]+\}|"files":{}|' \
      $NIX_BUILD_TOP/$cargoDepsCopy/prost-build/.cargo-checksum.json
  '';

  # buildPhase = ''
  #   HOME=$NIX_BUILD_TOP
  #   RUST_LOG=debug RUST_BACKTRACE=full \
  #   FTL_TEMPLATE_DIRS="./qt/ftl" QT_FTL_LOCALES="./qt/ftl/repo/desktop" ${pkgs.maturin}/bin/maturin build -i ${pkgs.python3}/bin/python -o $out --release --strip
  #   # FTL_TEMPLATE_DIRS="./qt/ftl" QT_FTL_LOCALES="./qt/ftl/repo/desktop" ${pkgs.strace}/bin/strace -f -v -s 1000 ${pkgs.maturin}/bin/maturin build -i ${pkgs.python3}/bin/python -o $out --release --strip
  # '';
}
