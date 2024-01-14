{ ffmpeg_6-full
, fetchFromGitHub
, lib
}:

let
  version = "6.0.1-1";
in

(ffmpeg_6-full.override {
  inherit version; # Important! This sets the ABI.
  confAACPSTablegenFix = false; # Has patch included
}).overrideAttrs (old: {
  pname = "jellyfin-ffmpeg";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-ffmpeg";
    rev = "v${version}";
    hash = "sha256-LMwGxx++z6TpZLnpeRGraid4653Mp8T4pY5EP4Z7GXY=";
  };

  # Clobber upstream patches as they don't apply to the Jellyfin fork
  patches = [];

  configureFlags = old.configureFlags ++ [
    "--extra-version=Jellyfin"
    "--disable-ptx-compression" # https://github.com/jellyfin/jellyfin/issues/7944#issuecomment-1156880067
  ];

  postPatch = ''
    for file in $(cat debian/patches/series); do
      patch -p1 < debian/patches/$file
    done

    ${old.postPatch or ""}
  '';

  meta = with lib; {
    description = "${old.meta.description} (Jellyfin fork)";
    homepage = "https://github.com/jellyfin/jellyfin-ffmpeg";
    license = licenses.gpl3;
    maintainers = with maintainers; [ justinas ];
    pkgConfigModules = [ "libavutil" ];
  };
})
