{ stdenv
, buildPythonPackage
, src
, beautifulsoup4
, requests
  , orjson
}:
let
  pname = "ankipylib";
  version = "1.11.8";
in

buildPythonPackage rec {
  inherit pname version src;

  sourceRoot = "anki/pylib"; #

  propagatedBuildInputs = [ beautifulsoup4 requests orjson ];
}
