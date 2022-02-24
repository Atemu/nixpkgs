{ lib, fetchFromGitHub, buildLinux, linux_zen, ... } @ args:

let
  version = "5.16.11";
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
    sha256 = "sha256-cGVdh1LMJCNhlWamNyTp6pwq9/u3XNanPLLOCuGFSKM=";
  };

  extraMeta = {
    branch = "5.16/master";
    maintainers = with lib.maintainers; [ atemu ];
    description = linux_zen.meta.description + " (Same as linux_zen but less aggressive release schedule)";
  };

} // (args.argsOverride or { }))
