{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  which,
  m4,
  python3,
  bison,
  flex,
  llvmPackages,
  ncurses,
  tbb,
  # the default test target is sse4, but that is not supported by all Hydra agents
  testedTargets ?
    if stdenv.hostPlatform.isAarch64 || stdenv.hostPlatform.isAarch32 then
      [ "neon-i32x4" ]
    else
      [ "sse2-i32x4" ],
}:

stdenv.mkDerivation rec {
  pname = "ispc";
  version = "1.27.0";

  dontFixCmake = true; # https://github.com/NixOS/nixpkgs/pull/232522#issuecomment-2133803566

  src = fetchFromGitHub {
    owner = "ispc";
    repo = "ispc";
    rev = "v${version}";
    sha256 = "sha256-nNiAlQ+MLkOV0/xLafsUNPV5HKCIqWCD2Fo8ChgFJMk=";
  };

  nativeBuildInputs = [
    cmake
    which
    m4
    bison
    flex
    python3
    llvmPackages.libllvm.dev
    tbb
  ];

  buildInputs = with llvmPackages; [
    libllvm
    libclang
    openmp
    ncurses
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace CURSES_CURSES_LIBRARY CURSES_NCURSES_LIBRARY
    substituteInPlace cmake/GenerateBuiltins.cmake \
      --replace 'bit 32 64' 'bit 64'
  '';

  inherit testedTargets;

  doCheck = true;

  # the compiler enforces -Werror, and -fno-strict-overflow makes it mad.
  # hilariously this is something of a double negative: 'disable' the
  # 'strictoverflow' hardening protection actually means we *allow* the compiler
  # to do strict overflow optimization. somewhat misleading...
  hardeningDisable = [ "strictoverflow" ];

  checkPhase = ''
    export ISPC_HOME=$PWD/bin
    for target in $testedTargets
    do
      echo "Testing target $target"
      echo "================================"
      echo
      (cd ../
       PATH=${llvmPackages.clang}/bin:$PATH python scripts/run_tests.py -t $target --non-interactive --verbose --file=test_output.log
       fgrep -q "No new fails"  test_output.log || exit 1)
    done
  '';

  cmakeFlags = [
    "-DFILE_CHECK_EXECUTABLE=${llvmPackages.llvm}/bin/FileCheck"
    "-DLLVM_AS_EXECUTABLE=${llvmPackages.llvm}/bin/llvm-as"
    "-DLLVM_CONFIG_EXECUTABLE=${llvmPackages.llvm.dev}/bin/llvm-config"
    "-DCLANG_EXECUTABLE=${llvmPackages.clang}/bin/clang"
    "-DCLANGPP_EXECUTABLE=${llvmPackages.clang}/bin/clang++"
    "-DISPC_INCLUDE_EXAMPLES=OFF"
    "-DISPC_INCLUDE_UTILS=OFF"
    (
      "-DARM_ENABLED="
      + (if stdenv.hostPlatform.isAarch64 || stdenv.hostPlatform.isAarch32 then "TRUE" else "FALSE")
    )
    (
      "-DX86_ENABLED="
      + (if stdenv.hostPlatform.isx86_64 || stdenv.hostPlatform.isx86_32 then "TRUE" else "FALSE")
    )
  ];

  meta = with lib; {
    homepage = "https://ispc.github.io/";
    description = "Intel 'Single Program, Multiple Data' Compiler, a vectorised language";
    mainProgram = "ispc";
    license = licenses.bsd3;
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ]; # TODO: buildable on more platforms?
    maintainers = with maintainers; [
      aristid
      thoughtpolice
      athas
      alexfmpe
    ];
  };
}
