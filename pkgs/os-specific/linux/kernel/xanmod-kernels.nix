{ lib, stdenv, fetchFromGitHub, buildLinux, ... } @ args:

let
  # These names are how they are designated in https://xanmod.org.
  ltsVariant = {
    version = "5.15.75";
    hash = "sha256-tgm5nmguEfRFq3OhmZgRgFLIW7E798Rv1basxnfdqLI=";
    variant = "lts";
  };

  currentVariant = {
    version = "6.0.6";
    hash = "sha256-JMfAtiPDgoVF+ypeFXev06PL39ZM2H7m07IxpasjAoM=";
    variant = "current";
  };

  nextVariant = currentVariant;

  ttVariant = {
    version = "5.15.54";
    suffix = "xanmod1-tt";
    hash = "sha256-4ck9PAFuIt/TxA/U+moGlVfCudJnzSuAw7ooFG3OJis=";
    variant = "tt";
  };

  xanmodKernelFor = { version, suffix ? "xanmod1", hash, variant }: buildLinux (args // rec {
    inherit version;
    modDirVersion = "${version}-${suffix}";

    src = fetchFromGitHub {
      owner = "xanmod";
      repo = "linux";
      rev = modDirVersion;
      inherit hash;
    };

    structuredExtraConfig = with lib.kernel; {
      # AMD P-state driver
      X86_AMD_PSTATE = yes;

      # Google's BBRv2 TCP congestion Control
      TCP_CONG_BBR2 = yes;
      DEFAULT_BBR2 = yes;

      # FQ-PIE Packet Scheduling
      NET_SCH_DEFAULT = yes;
      DEFAULT_FQ_PIE = yes;

      # Futex WAIT_MULTIPLE implementation for Wine / Proton Fsync.
      FUTEX = yes;
      FUTEX_PI = yes;

      # WineSync driver for fast kernel-backed Wine
      WINESYNC = module;
    } // lib.optionalAttrs (variant == "tt") {
      # removed options
      CFS_BANDWIDTH = lib.mkForce (option no);
      RT_GROUP_SCHED = lib.mkForce (option no);
      SCHED_AUTOGROUP = lib.mkForce (option no);
      SCHED_CORE = lib.mkForce (option no);
    };

    extraMeta = {
      branch = lib.versions.majorMinor version;
      maintainers = with lib.maintainers; [ fortuneteller2k lovesegfault atemu ];
      description = "Built with custom settings and new features built to provide a stable, responsive and smooth desktop experience";
      broken = stdenv.isAarch64;
    };
  } // (args.argsOverride or { }));
in
{
  lts = xanmodKernelFor ltsVariant;
  current = xanmodKernelFor currentVariant;
  next = xanmodKernelFor nextVariant;
  tt = xanmodKernelFor ttVariant;
}
