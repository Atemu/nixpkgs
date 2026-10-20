{
  lib,
  stdenv,
  fetchFromCodeberg,
  zig,
  pkg-config,
  wayland,
  wayland-scanner,
  wayland-protocols,
  river,
  libxkbcommon,
  libnotify,
  dbus,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rhine";
  version = "0.4.1-unstable-2026-10-18";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromCodeberg {
    owner = "sivecano";
    repo = "rhine";
    rev = "ff499d004ed283ca784d2494e40cfc17ebc8f77a";
    hash = "sha256-HLGWjJOqbvVn9R35TimqaxcX0e2nWlDKersDmD3viUY=";
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

  zigDeps = zig.fetchDeps {
    inherit (finalAttrs) src pname version;
    hash = "sha256-nvM2DcFnVkGXBUQ/XGsIJXr0sJWlqJaoTiTUOyU7u9k=";
  };
  postConfigure = ''
    ln -s ${finalAttrs.zigDeps} $ZIG_GLOBAL_CACHE_DIR/p
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch=main"
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
