{ lib, fetchFromGitHub, buildLinux, linux_zen, ... } @ args:

let
  version = "5.16.10";
  suffix = "lqx1";
in

buildLinux (args // {
  modDirVersion = "${version}-${suffix}";
  inherit version;
  isZen = true;

  src = fetchFromGitHub {
    owner = "zen-kernel";
    repo = "zen-kernel";
    rev = "v${version}-${suffix}";
    sha256 = "sha256-vWc9OAU9BQIPeo6sLN9Zmj8hdMElHZvq80/9gu2pjOA=";
  };

  extraMeta = {
    branch = "5.16/master";
    maintainers = with lib.maintainers; [ atemu ];
    description = linux_zen.meta.description + " (Same as linux_zen but less aggressive release schedule)";
  };

} // (args.argsOverride or { }))
