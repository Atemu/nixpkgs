{ lib, fetchFromGitHub, buildLinux, linux_zen, ... } @ args:

let
  version = "5.11.2";
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
    sha256 = "0yalkg4w4cwab53g4zxjgffvjhvmzhv3prczn5cy7avnc3hmjdh1";
  };

  extraMeta = {
    branch = "5.10/master";
    maintainers = with lib.maintainers; [ atemu ];
    description = linux_zen.meta.description + " (Same as linux_zen but less aggressive release schedule)";
  };

} // (args.argsOverride or {}))
