{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
}:
let
  pname = "opencode-background-agents";
  version = "0-unstable-2026-06-11";

  # Upstream ships the canonical plugin source in the OCX monorepo. The
  # standalone facade repo (kdcokenny/opencode-background-agents) is
  # incomplete, so we fetch the monorepo and extract just this plugin's
  # subgraph.
  src = fetchFromGitHub {
    owner = "kdcokenny";
    repo = "ocx";
    rev = "08628d3cf7aace9b74d578dd562745647d88f7a7";
    hash = "sha256-7JpHwJLBbvRUOWDHw9QhIW5lmFAjUrtWlrE7GcTpHh4=";
  };

  pluginRoot = "workers/kdco-registry/files/plugins";

  # The plugin has no package.json/lockfile upstream, so we vendor a minimal
  # manifest pinning its single runtime npm dependency (matching the version
  # declared in the OCX registry).
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
    outputHash = "sha256-Co+o7fMgBrqBTQ0yAlV0T8YC2tn9qqp81oDx7e00/Jw=";
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ bun ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR

    # Assemble the minimal plugin subgraph alongside the vendored manifest and
    # resolved dependencies.
    mkdir -p build/src/kdco-primitives
    cp ${pluginRoot}/background-agents.ts build/src/background-agents.ts
    cp ${pluginRoot}/kdco-primitives/get-project-id.ts build/src/kdco-primitives/
    cp ${pluginRoot}/kdco-primitives/types.ts build/src/kdco-primitives/
    cp ${pluginRoot}/kdco-primitives/log-warn.ts build/src/kdco-primitives/
    cp ${pluginRoot}/kdco-primitives/with-timeout.ts build/src/kdco-primitives/

    cp ${manifest} build/package.json
    cp -R ${node_modules}/node_modules build/node_modules

    cd build
    # `@opencode-ai/plugin` and `@opencode-ai/sdk` are provided by opencode at
    # plugin load time, so keep them external instead of bundling them.
    bun build ./src/background-agents.ts \
      --outdir ./dist \
      --target node \
      --external @opencode-ai/plugin \
      --external @opencode-ai/sdk

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Install as a local opencode plugin directory. opencode loads any
    # JS/TS files placed under its plugins directory.
    mkdir -p $out/lib/opencode-background-agents
    cp dist/background-agents.js $out/lib/opencode-background-agents/index.js

    runHook postInstall
  '';

  passthru = { inherit src node_modules; };

  meta = with lib; {
    description = "Background agent execution for OpenCode - run async tasks while you work";
    homepage = "https://github.com/kdcokenny/opencode-background-agents";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
