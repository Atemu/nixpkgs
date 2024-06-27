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
  options.services.taler = {
    enable = lib.mkEnableOption "the GNU Taler system";
    exchange = lib.mkOption {
      type = lib.types.submodule ./exchange.nix;
    };
    settings = lib.mkOption {
      type = lib.types.submodule { freeformType = settingsFormat.type; };
      default = { };
    };
  };

  config = {
    environment.etc."taler/taler.conf".source = settingsFormat.generate "foo-config.json" this.settings;
  };
}
