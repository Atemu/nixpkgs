{ lib, fetchFromGitHub, buildLinux, ... } @ args:

let
  version = "5.10.14";
  suffix = "zen1";
in

buildLinux (args // {
  modDirVersion = "${version}-${suffix}";
  inherit version;
  isZen = true;

  src = fetchFromGitHub {
    owner = "zen-kernel";
    repo = "zen-kernel";
    rev = "v${version}-${suffix}";
    sha256 = "1z9y12skmsxwyi3zqq7ylzc6r3gdyjh7xxvr4g1p9gysffrd81lk";
  };

  extraMeta = {
    branch = "5.10/master";
    maintainers = with lib.maintainers; [ atemu andresilva ];
    description = "Built using the best configuration and kernel sources for desktop, multimedia, and gaming workloads.";
  };

} // (args.argsOverride or {}))
