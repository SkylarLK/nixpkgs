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
    rev = "b08d463572f62a9b5acb1f54565fd2e5846a8b40";
    hash = "sha256-NJl3ffdCI7WOzZDCDAPXzIL7cRXuiPbyZUOpMx4IlhM=";
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

