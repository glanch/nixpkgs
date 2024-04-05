{ stdenv
, lib
, fetchFromGitHub
, wrapQtAppsHook
, pkg-config
, qmake
, qtquickcontrols2
, SDL2
, SDL2_ttf
, libva
, libvdpau
, libxkbcommon
, alsa-lib
, libpulseaudio
, openssl
, libopus
, ffmpeg
, wayland
, darwin
}:

let
  inherit (darwin.apple_sdk_11_0.frameworks) AVFoundation AppKit AudioUnit VideoToolbox;
in

stdenv.mkDerivation rec {
  pname = "moonlight-qt";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "moonlight-stream";
    repo = "moonlight-qt";
    rev = "89a628a0dde50264fd2170125588c15d8dd80a2c";
    hash = "sha256-6KJTYYbrIPt3zNaK63fcFBb9W8reItpeqylugj0CwjU=";
    fetchSubmodules = true;
  };

  #patches = [ ./darwin.diff ];

  nativeBuildInputs = [
    wrapQtAppsHook
    pkg-config
    qmake
  ];

  buildInputs = [
    qtquickcontrols2
    SDL2
    SDL2_ttf
    openssl
    libopus
    ffmpeg
  ] ++ lib.optionals stdenv.isLinux [
    libva
    libvdpau
    libxkbcommon
    alsa-lib
    libpulseaudio
    wayland
  ] ++ lib.optionals stdenv.isDarwin [
    AVFoundation
    AppKit
    AudioUnit
    VideoToolbox
  ];

  postInstall = lib.optionalString stdenv.isDarwin ''
    mkdir $out/Applications $out/bin
    mv app/Moonlight.app $out/Applications
    rm -r $out/Applications/Moonlight.app/Contents/Frameworks
    ln -s $out/Applications/Moonlight.app/Contents/MacOS/Moonlight $out/bin/moonlight
  '';

  meta = with lib; {
    description = "Play your PC games on almost any device";
    homepage = "https://moonlight-stream.org";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ luc65r ];
    platforms = platforms.all;
    mainProgram = "moonlight";
  };
}
