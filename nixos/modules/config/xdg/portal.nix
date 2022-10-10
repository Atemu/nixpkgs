{ config, pkgs, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkRenamedOptionModule
    mkRemovedOptionModule
    unique
    teams
    types;
in

{
  imports = [
    (mkRenamedOptionModule [ "services" "flatpak" "extraPortals" ] [ "xdg" "portal" "extraPortals" ])
    (mkRemovedOptionModule [ "xdg" "portal" "gtkUsePortal" ] "`gtkUsePortal` has been deprecated. If you need it in spite of that, declare `GTK_USE_PORTAL` in `environment.sessionVariables` yourself.")
  ];

  meta = {
    maintainers = teams.freedesktop.members;
  };

  options.xdg.portal = {
    enable =
      mkEnableOption (lib.mdDoc ''[xdg desktop integration](https://github.com/flatpak/xdg-desktop-portal)'') // {
        default = false;
      };

    extraPortals = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = lib.mdDoc ''
        List of additional portals to add to path. Portals allow interaction
        with system, like choosing files or taking screenshots. At minimum,
        a desktop portal implementation should be listed. GNOME and KDE already
        adds `xdg-desktop-portal-gtk`; and
        `xdg-desktop-portal-kde` respectively. On other desktop
        environments you probably want to add them yourself.
      '';
    };
  };

  config =
    let
      cfg = config.xdg.portal;
      packages = unique ([ pkgs.xdg-desktop-portal ] ++ cfg.extraPortals);
      joinedPortals = pkgs.buildEnv {
        name = "xdg-portals";
        paths = packages;
        pathsToLink = [ "/share/xdg-desktop-portal/portals" "/share/applications" ];
      };

    in
    mkIf cfg.enable {

      assertions = [
        {
          assertion = cfg.extraPortals != [ ];
          message = "Setting xdg.portal.enable to true requires a portal implementation in xdg.portal.extraPortals such as xdg-desktop-portal-gtk or xdg-desktop-portal-kde.";
        }
      ];

      # TODO Is it actually necessary to make the packages accessible to anything but the user service(s)?
      services.dbus.packages = packages;
      systemd = {
        inherit packages;
        user.services.xdg-desktop-portal = {
          restartIfChanged = true;
          environment = {
            XDG_DESKTOP_PORTAL_DIR = "${joinedPortals}/share/xdg-desktop-portal/portals";
          };
        };
      };

      environment = {
        # fixes screen sharing on plasmawayland on non-chromium apps by linking
        # share/applications/*.desktop files
        # see https://github.com/NixOS/nixpkgs/issues/145174
        systemPackages = [ joinedPortals ];
        # Makes the portals available in the system-wide share
        inherit (joinedPortals) pathsToLink;
      };
    };
}
