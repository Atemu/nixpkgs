{
  lib,
  stdenv,
  fetchgit,
  python3,
  jdk17_headless,
  gradle,
}:

stdenv.mkDerivation rec {
  pname = "libeufin";
  version = "0.11.2";

  src = fetchgit {
    url = "https://git.taler.net/libeufin.git/";
    rev = "v${version}";
    hash = "sha256-7w5G8F/XWsWJwkpQQ8GqDA9u6HLV+X9N2RJHn+yXihs=";
    fetchSubmodules = true;
    leaveDotGit = true; # Required for correct submodule fetching
    # Delete .git folder for reproducibility (otherwise, the hash changes unexpectedly after fetching submodules)
    # Save the HEAD short commit hash in a file so it can be retrieved later for versioning.
    postFetch = ''
      (
        cd $out
        git rev-parse --short HEAD > ./common/src/main/resources/HEAD.txt
        rm -rf .git
      )
    '';
  };

  patches = [
    # The .git folder had to be deleted. Read hash from file instead of using the git command.
    ./read-HEAD-hash-from-file.patch
    # Gradle projects provide a .module metadata file as artifact. This artifact is used by gradle
    # to download dependencies to the cache when needed, but do not provide the jar for the
    # offline installation for our build phase. Since we make an offline Maven repo, we have to
    # substitute the gradle deps for their maven counterpart to retrieve the .jar artifacts.
    ./use-maven-deps.patch
  ];

  preConfigure = ''
    cp build-system/taler-build-scripts/configure ./configure
  '';

  mitmCache = gradle.fetchDeps {
    inherit pname;
    data = ./deps.json;
  };

  gradleFlags = [ "-Dorg.gradle.java.home=${jdk17_headless}" ];
  gradleBuildTask = [ "bank:installShadowDist" "nexus:installShadowDist" ];

  nativeBuildInputs = [
    python3
    jdk17_headless
    gradle
  ];

  # # Tell gradle to use the offline Maven repository
  # buildPhase = ''
  #   gradle bank:installShadowDist nexus:installShadowDist --offline --no-daemon --init-script ${gradleInit}
  # '';

  installPhase = ''
    make install-nobuild
  '';

  # Tests need a database to run.
  # TODO there's a postgres runner thingy you could use here
  doCheck = false;

  passthru.updateDeps = gradle.updateDeps {
    inherit pname;
  };

  meta = {
    homepage = "https://git.taler.net/libeufin.git/";
    description = "Integration and sandbox testing for FinTech APIs and data formats.";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ atemu ];
  };
}
