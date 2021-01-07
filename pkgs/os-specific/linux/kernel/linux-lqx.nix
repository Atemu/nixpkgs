{ stdenv, fetchFromGitHub, buildLinux, linux_zen, ... } @ args:

let
  version = "5.10.4";
in

buildLinux (args // {
  modDirVersion = "${version}-lqx1";
  inherit version;
  isZen = true;

  src = fetchFromGitHub {
    owner = "zen-kernel";
    repo = "zen-kernel";
    rev = "v${version}-lqx1";
    sha256 = "1innk3syvhmvabq3iwaqjqp9l9rqrqb2dsy29r8xcz0a2lqyh5fn";
  };

  extraMeta = {
    branch = "5.10/master";
    maintainers = with stdenv.lib.maintainers; [ atemu ];
    description = linux_zen.meta.description + " (Same as linux_zen but less aggressive release schedule)";
  };

} // (args.argsOverride or {}))
