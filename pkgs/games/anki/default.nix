{ stdenv
, fetchFromGitHub
, callPackage
, pythonPackages
, python3Packages
, pkgs
}:

let
  version = "2.1.29";
  pname = "anki";

  # src = fetchFromGitHub {
  #   owner = "ankitects";
  #   repo = pname;
  #   rev = version;
  #   sha256 = "14hq3n6yw1n35d5zx5w22zr281700bbid0kc1i2vfd1wbvj65nnc";
  # };

  src = /home/atemu/Projects/anki;

  ts = callPackage ./ts { src = src + "/ts"; };

  # rslib = callPackage ./rslib { inherit src; };

  rspy = pythonPackages.callPackage ./rspy { inherit src; };

  orjson = python3Packages.callPackage ./orjson { };

  pylib = python3Packages.callPackage ./pylib { inherit src orjson; };

# in

# rspy
anki =
pythonPackages.buildPythonApplication {
  inherit pname version;

  src = pkgs.runCommand "source" { inherit src; ts = ts.package; } ''
    mkdir -p $out
    cp -r $src/. $out
    chmod -R u+rw $out
    rm -r $out/ts
    ln -s $ts/lib/node_modules/anki/ $out/ts
  '';

  nativeBuildInputs = with pkgs; [ python3 git maturin ];
  buildPhase = ''
    make build
  '';
}
;

in

{
  inherit anki rspy ts orjson pylib;
}
