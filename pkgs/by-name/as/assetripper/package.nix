{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  makeDesktopItem,
  ...
}:

buildDotnetModule rec {
  pname = "assetripper";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "AssetRipper";
    repo = "AssetRipper";
    rev = "7c98870962181138585ded1120d49eeadab0d0ff";
    hash = "sha256-CZOL2U8KAcfhPK9V37dWfG/WL3zk15xrod3EeSzsWOk=";
  };

  projectFile = "src/AssetRipper.sln";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  desktopItems = [
    (makeDesktopItem {

    })
  ];

  meta = with lib; {
    homepage = "https://assetripper.github.io/AssetRipper/";
    license = with licenses; [
      gpl3Only # main license
      mit # localizations only
    ];
    maintainers = with maintainers; [
      skylarlk
    ];
    platforms = platforms.linux;
  };
}
