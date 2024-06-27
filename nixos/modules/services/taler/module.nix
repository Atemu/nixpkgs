{
  lib,
  pkgs,
  config,
  ...
}:

let
  settingsFormat = pkgs.formats.ini { };
  this = config.services.taler;
in

{
  imports = [ ./exchange.nix ];

  options.services.taler = {
    enable = lib.mkEnableOption "the GNU Taler system";
    settings = lib.mkOption {
      type = lib.types.submodule { freeformType = settingsFormat.type; };
      default = { };
    };
    configFile = lib.mkOption {
      internal = true;
      default = settingsFormat.generate "taler.conf" this.settings;
    };
  };

  config = {
    environment.etc."taler/taler.conf".source = this.configFile;
  };
}
