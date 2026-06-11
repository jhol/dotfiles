{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
}:
let
  pname = "opencode-notify";
  version = "0-unstable-2026-06-11";

  # Upstream ships the canonical plugin source in the OCX monorepo. The
  # standalone facade repo (kdcokenny/opencode-notify) is incomplete, so we
  # fetch the monorepo and extract just the notify plugin subgraph.
  src = fetchFromGitHub {
    owner = "kdcokenny";
    repo = "ocx";
    rev = "08628d3cf7aace9b74d578dd562745647d88f7a7";
    hash = "sha256-7JpHwJLBbvRUOWDHw9QhIW5lmFAjUrtWlrE7GcTpHh4=";
  };

  pluginRoot = "workers/kdco-registry/files/plugins";

  # The notify plugin has no package.json/lockfile upstream, so we vendor a
  # minimal manifest pinning its two runtime npm dependencies (matching the
  # versions declared in the OCX registry).
  manifest = ./package.json;
  lockfile = ./bun.lock;

  # Fixed-output derivation that resolves the bun dependencies. The output
  # hash must be updated whenever bun.lock changes.
  node_modules = stdenvNoCC.mkDerivation {
    pname = "${pname}-node_modules";
    inherit version;

    dontUnpack = true;

    nativeBuildInputs = [ bun ];

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR
      cp ${manifest} ./package.json
      cp ${lockfile} ./bun.lock
      bun install \
        --frozen-lockfile \
        --no-progress \
        --ignore-scripts

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R node_modules $out/

      runHook postInstall
    '';

    dontFixup = true;

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-wvdTBt0eldy3+b9QMp3q+iJIjH/DrVLeg7/Nvtp9h1E=";
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ bun ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR

    # Assemble the minimal notify plugin subgraph alongside the vendored
    # manifest and resolved dependencies.
    mkdir -p build/src/notify build/src/kdco-primitives
    cp ${pluginRoot}/notify.ts build/src/notify.ts
    cp ${pluginRoot}/notify/backend.ts build/src/notify/
    cp ${pluginRoot}/notify/cmux.ts build/src/notify/
    cp ${pluginRoot}/notify/status.ts build/src/notify/
    cp ${pluginRoot}/notify/title.ts build/src/notify/
    cp ${pluginRoot}/kdco-primitives/cmux.ts build/src/kdco-primitives/
    cp ${pluginRoot}/kdco-primitives/types.ts build/src/kdco-primitives/
    cp ${pluginRoot}/kdco-primitives/with-timeout.ts build/src/kdco-primitives/

    cp ${manifest} build/package.json
    cp -R ${node_modules}/node_modules build/node_modules

    cd build
    bun build ./src/notify.ts \
      --outdir ./dist \
      --target node

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Install as a local opencode plugin directory. opencode loads any
    # JS/TS files placed under its plugins directory.
    mkdir -p $out/lib/opencode-notify
    cp dist/notify.js $out/lib/opencode-notify/index.js

    runHook postInstall
  '';

  passthru = { inherit src node_modules; };

  meta = with lib; {
    description = "Native OS notifications for OpenCode - know when tasks complete";
    homepage = "https://github.com/kdcokenny/opencode-notify";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
