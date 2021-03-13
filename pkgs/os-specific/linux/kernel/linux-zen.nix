{ lib, fetchFromGitHub, buildLinux, ... } @ args:

let
  version = "5.11.6";
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
    sha256 = "076r983w01vqdi83c3kwax6d32pqrk18cmxk9r503jrysi0zbwnv";
  };

  extraMeta = {
    branch = "5.10/master";
    maintainers = with lib.maintainers; [ atemu andresilva ];
    description = "Built using the best configuration and kernel sources for desktop, multimedia, and gaming workloads.";
  };

} // (args.argsOverride or {}))
