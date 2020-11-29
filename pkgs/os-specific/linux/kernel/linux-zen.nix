{ stdenv, fetchFromGitHub, buildLinux, ... } @ args:

let
  version = "5.9.11";
in

buildLinux (args // {
  modDirVersion = "${version}-zen1";
  inherit version;
  isZen = true;

  src = fetchFromGitHub {
    owner = "zen-kernel";
    repo = "zen-kernel";
    rev = "v${version}-zen1";
    sha256 = "0az63dky9514bw2zx7qkng56w7iilzgw14k57lwwih3psw8sk754";
  };

  extraMeta = {
    branch = "5.9/master";
    maintainers = with stdenv.lib.maintainers; [ atemu andresilva ];
  };

} // (args.argsOverride or {}))
