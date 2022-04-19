{ runCommand, fetchgit, makeWrapper, python3, lib, qrencode, platform-tools }:

runCommand "debug_from_qr" {
  src = fetchgit {
    url = "https://gist.github.com/benigumocom/a6a87fc1cb690c3c4e3a7642ebf2be6f";
    rev = "c79e18f2979a1a8e0d2b5a6518837aae35b4996a";
    sha256 = "sha256-l66M6VWLgyqAS8S5+/MtVKMyE6czXwdw1XctzMshKa8=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ (python3.withPackages (p: [ p.zeroconf ])) ];

  pname = "debug_from_qr";
  version = "2020-10-18";
} ''
  mkdir -p $out/bin
  cp $src/debug_from_qr.py $out/bin/debug_from_qr
  chmod +rwx $out/bin/debug_from_qr

  # Patch in zeroconfPython from buildInputs
  patchShebangs $out/bin/debug_from_qr

  wrapProgram $out/bin/debug_from_qr --prefix PATH : ${lib.makeBinPath [ qrencode platform-tools ]}
''
