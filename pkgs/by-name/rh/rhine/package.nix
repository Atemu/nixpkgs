{
  lib,
  stdenv,
  fetchFromGitea,
  zig,
  pkg-config,
  wayland,
  wayland-scanner,
  wayland-protocols,
  river,
  libxkbcommon,
  libnotify,
  dbus,
  callPackage,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rhine";
  version = "0.3.0-unstable-2026-08-03";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "sivecano";
    repo = "rhine";
    rev = "71f1c6eb8878f88f397a3d8fa8bb40af3df63d73";
    hash = "sha256-C0mD4BLCOFbiD0NwgYs88fu+0RWzxm38fBkwEvwu8g8=";
  };

  nativeBuildInputs = [
    zig
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayland-scanner
    wayland-protocols
    wayland
    river
    libxkbcommon
    libnotify
    dbus
  ];

  deps = callPackage ./build.zig.zon.nix { };
  zigBuildFlags = [
    "--system"
    "${finalAttrs.deps}"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
    ];
  };

  meta = {
    description = "Window manager for river supporting multiple layouts and awesome animations";
    homepage = "https://codeberg.org/sivecano/rhine";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [
      atemu
    ];
    mainProgram = "rhine";
    inherit (zig.meta) platforms;
  };
})
