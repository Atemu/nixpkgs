{ lib, fetchFromGitHub, buildLinux, linux_zen, ... } @ args:

let
  version = "5.13.12";
  suffix = "lqx2";
in

buildLinux (args // {
  modDirVersion = "${version}-${suffix}";
  inherit version;
  isZen = true;

  src = fetchFromGitHub {
    owner = "zen-kernel";
    repo = "zen-kernel";
    rev = "v${version}-${suffix}";
    sha256 = "sha256-LUjhfbd971q0sGAy+zeCWvlqTB3jhe+W+zRzuvTwa4c=";
  };

  extraMeta = {
    branch = "5.13/master";
    maintainers = with lib.maintainers; [ atemu ];
    description = linux_zen.meta.description + " (Same as linux_zen but less aggressive release schedule)";
  };

} // (args.argsOverride or { }))
