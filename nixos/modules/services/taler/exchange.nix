{ lib, pkgs, ... }:

{
  options = {
    enable = lib.mkEnableOption "the GNU Taler exchange";
  };
}
