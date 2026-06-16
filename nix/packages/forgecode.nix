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
  version = "2.13.11";

  src = fetchFromGitHub {
    owner = "tailcallhq";
    repo = "forgecode";
    rev = "v${version}";
    hash = "sha256-fCVgErQwBClKoHdfDJy/PI6x0L/R6TuaUpsWTMbaUMk=";
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

  # Nix pins the version — disable the built-in auto-update that would
  # prompt "Confirm upgrade from X -> Y (latest)?" on every launch and
  # attempt to curl the upstream installer script.
  postPatch = ''
    substituteInPlace crates/forge_main/src/update.rs \
      --replace-fail \
        'let update = update.cloned().unwrap_or_default();' \
        'return; let update = update.cloned().unwrap_or_default();'
  '';

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

    # The shell plugin spawns `forge update --no-confirm` in a background
    # process after every interactive command.  The Rust patch above already
    # makes that a no-op, but there is no reason to fork the process at all.
    substituteInPlace $out/share/forgecode/shell-plugin/lib/dispatcher.zsh \
      --replace-fail '_forge_start_background_update' ':'
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
