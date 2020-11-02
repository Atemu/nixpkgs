import ./make-test-python.nix ({ pkgs, ... }:

{
  name = "anbox";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ mvnetbiz ];
  };

  machine = { pkgs, config, ... }: {
    imports = [
      ./common/user-account.nix
      ./common/x11.nix
    ];

    test-support.displayManager.auto.user = "alice";

    virtualisation.anbox.enable = true;
    virtualisation.memorySize = 1500;

    programs.adb.enable = true;
  };

  testScript = { nodes, ... }: let
    user = nodes.machine.config.users.users.alice;
    bus = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${toString user.uid}/bus";
  in ''
    machine.wait_for_x()

    machine.succeed(
        "sudo -iu alice ${bus} anbox wait-ready"
    )

    machine.wait_until_succeeds("adb shell true")

    print(machine.succeed("adb devices"))
  '';
})
