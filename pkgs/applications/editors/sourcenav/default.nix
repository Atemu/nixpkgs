{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sourcenav";
  version = "SN-NG4.5";

  src = fetchgit {
    url = "https://git.code.sf.net/p/sourcenav/git";
    rev = version;
    sha256 = "0hrfw81maq19bxgri2jwcpgqmq8nkjzygj3595i90ph5ganj4q98";
  };
}
