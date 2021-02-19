# Used in the generation of package search database.
{
  # Ensures no aliases are in the results.
  allowAliases = false;

  # Enable recursion into attribute sets that nix-env normally doesn't look into
  # so that we can get a more complete picture of the available packages for the
  # purposes of the index.
  packageOverrides = super: with super; lib.mapAttrs (n: v: recurseIntoAttrs v) {
    inherit
      roundcubePlugins
      fdbPackages
      nodePackages_latest
      nodePackages
      platformioPackages
      haskellPackages
      idrisPackages
      sconsPackages
      gns3Packages
      quicklispPackagesClisp
      quicklispPackagesSBCL
      rPackages
      apacheHttpdPackages_2_4
      zabbix50
      zabbix40
      zabbix30
      fusePackages
      sourceHanPackages
      atomPackages
      steamPackages
      ut2004Packages
      zeroadPackages
    ;
      # inherit (emacs) pkgs;
      # inherit (emacs26) pkgs;
      # inherit (emacs27) pkgs;
  };
}
