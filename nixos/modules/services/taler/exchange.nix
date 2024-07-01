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
    services.taler.settings = {
      exchange = {
        # TODO these should be generated from high-level NixOS options
        AML_THRESHOLD = "KUDOS:1000000";
        MAX_KEYS_CACHING = "forever";
        DB = "postgres";
        MASTER_PUBLIC_KEY = "Q6KCV81R9T3SC41T5FCACC2D084ACVH5A25FH44S6M5WXWZAA8P0";
        # WIRE_RESPONSE = ${TALER_DATA_HOME}/exchange/account-1.json;

        PORT = 8081; # TODO option
        BASE_URL = "https://exchange.hephaistos.foo.bar/"; # TODO ensure / is present!
        SIGNKEY_DURATION = "2 weeks";
        SIGNKEY_LEGAL_DURATION = "2 years";
        LOOKAHEAD_SIGN = "3 weeks 1 day";
        KEYDIR = "\${TALER_DATA_HOME}/exchange/live-keys/";
        REVOCATION_DIR = "\${TALER_DATA_HOME}/exchange/revocations/";
        TERMS_ETAG = 0;
        PRIVACY_ETAG = 0;
      };
      exchangedb-postgres = {
        CONFIG = "postgres:///taler-exchange-httpd";
      };
    };
    services.postgresql.enable = true;
    services.postgresql.ensureDatabases = [ "taler-exchange-httpd" ];
    services.postgresql.ensureUsers = [
      {
        name = "taler-exchange-httpd";
        ensureDBOwnership = true;
      }
    ];
  };
}
