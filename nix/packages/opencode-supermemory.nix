{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
}:
let
  pname = "opencode-supermemory";
  version = "2.0.6";

  src = fetchFromGitHub {
    owner = "supermemoryai";
    repo = "opencode-supermemory";
    rev = "f932847671a77463ee694d32d39ced7cb22a1ffe";
    hash = "sha256-nhrCLkPU98H8vg8s0t4pgdcyJ2gWpGsfPHq7zKMatmQ=";
  };

  # Fixed-output derivation that resolves the bun dependencies. The output
  # hash must be updated whenever bun.lock changes.
  node_modules = stdenvNoCC.mkDerivation {
    pname = "${pname}-node_modules";
    inherit version src;

    nativeBuildInputs = [ bun ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR
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
    outputHash = "sha256-JGxW3tMKYotxEg4VIN/8Cz/0PeFM7K+aQOlzqMVualM=";
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ bun ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    cp -R ${node_modules}/node_modules ./node_modules
    chmod -R u+w ./node_modules

    bun build ./src/index.ts \
      --outdir ./dist \
      --target node

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Install as a local opencode plugin directory. opencode loads any
    # JS/TS files placed under its plugins directory.
    mkdir -p $out/lib/opencode-supermemory
    cp -R dist/* $out/lib/opencode-supermemory/

    runHook postInstall
  '';

  passthru = { inherit src node_modules; };

  meta = with lib; {
    description = "OpenCode plugin for persistent memory using Supermemory";
    homepage = "https://github.com/supermemoryai/opencode-supermemory";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
