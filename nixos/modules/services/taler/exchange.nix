{
  lib,
  config,
  pkgs,
  ...
}:

let
  this = config.services.taler.exchange;
  services = [ "httpd" ];
  inherit (config.services.taler) configFile;
in

{
  options.services.taler.exchange = {
    enable = lib.mkEnableOption "the GNU Taler exchange";
    package = lib.mkPackageOption pkgs "taler-exchange" { };
    debug = lib.mkEnableOption "debug logging";
  };

  config = lib.mkIf this.enable {
    systemd.slices.taler-exchange = {
      description = "Slice for GNU taler exchange processes";
      before = [ "slices.target" ];
    };

    systemd.services = lib.genAttrs (map (n: "taler-exchange-${n}") services) (name: {
      serviceConfig = {
        DynamicUser = true;
        User = name;
        ExecStart =
          "${this.package}/bin/${name} -c ${configFile}" + lib.optionalString this.debug " -L debug"; # TODO as a list?
        RuntimeDirectory = name;
        # TODO more hardening
        # PrivateTmp = "yes";
        # PrivateDevices = "yes";
        # ProtectSystem = "full";
        # Slice = "taler-exchange.slice";
      };
      wantedBy = [ "multi-user.target" ]; # TODO slice?
    });
  };
}
