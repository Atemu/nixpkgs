{ lib, pkgs, ... }:

{
  options.services.taler.exchange = {
    enable = lib.mkEnableOption "the GNU Taler exchange";
  };
}
