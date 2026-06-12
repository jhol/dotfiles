{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  nasm,
  perl,
  pkg-config,
  protobuf,
  sqlite,
  libxkbcommon,
  xorg,
  wayland,
  stdenv,
}:
rustPlatform.buildRustPackage rec {
  pname = "forgecode";
  version = "2.13.9";

  src = fetchFromGitHub {
    owner = "tailcallhq";
    repo = "forgecode";
    rev = "v${version}";
    hash = "sha256-DOTMZX1/ElIQItUMl9Mg7na2MecVzaN52+B5Jq34L1o=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    allowBuiltinFetchGit = true;
  };

  cargoBuildFlags = [
    "-p"
    "forge_main"
    "--bin"
    "forge"
  ];

  doCheck = false;

  nativeBuildInputs = [
    cmake
    nasm
    perl
    pkg-config
    protobuf
  ];

  buildInputs = [
    sqlite
  ]
  ++ lib.optionals stdenv.isLinux [
    libxkbcommon
    xorg.libX11
    xorg.libXext
    xorg.libXfixes
    xorg.libxcb
    wayland
  ];

  env = {
    PROTOC = "${protobuf}/bin/protoc";
    PROTOC_INCLUDE = "${protobuf}/include";
    APP_VERSION = version;
  };

  postInstall = ''
    # Install the ZSH plugin for shell integration
    mkdir -p $out/share/forgecode
    cp -r shell-plugin $out/share/forgecode/
  '';

  passthru = { inherit src; };

  meta = with lib; {
    description = "AI-enabled pair programmer for Claude, GPT, and 300+ models";
    homepage = "https://forgecode.dev";
    license = licenses.asl20;
    mainProgram = "forge";
    platforms = platforms.linux;
  };
}
