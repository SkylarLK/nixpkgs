{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "godots";
  version = "1.3.stable";

  src = fetchFromGitHub {
    owner = "MakovWait";
    repo = "godots";
    rev = "v${version}";
    hash = "sha256-9icWs0UVLkKJugv1cX9NIOhdey3l2fSfUPyNJjL4TZs=";
  };

  meta = {
    description = "Ultimate go-to hub for managing your Godot versions and projects";
    homepage = "https://github.com/MakovWait/godots";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "godots";
    platforms = lib.platforms.all;
  };
}
