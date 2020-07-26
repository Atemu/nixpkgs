{ buildPythonPackage
, fetchFromGitHub
, pkgs
}:
let
  pname = "orjson";
  version = "3.3.0";
in

buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "ijl";
    repo = "orjson";
    rev = version;
    sha256 = "0w3hmg2193bsadg4b3ri68s1sj8w1ph7z9v3ms80bi9dq8qmxnx8";
  };

  format = "pyproject";

  nativeBuildInputs = [ pkgs.maturin ];
}
