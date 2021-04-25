{
  lib,
  stdenv,
  clangStdenv,
  fetchFromGitHub,
  opencl-headers,
  cmake,
  jsoncpp,
  boost,
  makeWrapper,
  cudatoolkit,
  withCuda ? cudatoolkit != null,
  mesa,
  ethash,
  opencl-info,
  ocl-icd,
  openssl,
  pkg-config,
  cli11
}@args:

# Note that this requires clang < 9.0 to build, and currently
# clangStdenv provides clang 7.1 which satisfies the requirement.
let stdenv = if withCuda then clangStdenv else args.stdenv;

in stdenv.mkDerivation rec {
  pname = "ethminer";
  version = "0.19.0";

  src =
    fetchFromGitHub {
      owner = "ethereum-mining";
      repo = "ethminer";
      rev = "v${version}";
      sha256 = "1kyff3vx2r4hjpqah9qk99z6dwz7nsnbnhhl6a76mdhjmgp1q646";
      fetchSubmodules = true;
    };

  # NOTE: dbus is broken
  cmakeFlags = [
    "-DHUNTER_ENABLED=OFF"
    "-DETHASHCUDA=ON"
    "-DAPICORE=ON"
    "-DETHDBUS=OFF"
    "-DCMAKE_BUILD_TYPE=Release"
  ] ++ lib.optionals (!withCuda) [
    "-DETHASHCUDA=OFF" # on by default
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    cli11
    boost
    opencl-headers
    mesa
    ethash
    opencl-info
    ocl-icd
    openssl
    jsoncpp
  ] ++ lib.optionals withCuda [
    cudatoolkit
  ];

  preConfigure = ''
    sed -i 's/_lib_static//' libpoolprotocols/CMakeLists.txt
  '';

  postInstall = ''
    wrapProgram $out/bin/ethminer --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
  '';

  meta = with lib; {
    description = "Ethereum miner with OpenCL${lib.optionalString withCuda ", CUDA"} and stratum support";
    homepage = "https://github.com/ethereum-mining/ethminer";
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ nand0p atemu ];
    license = licenses.gpl2;
  };
}
