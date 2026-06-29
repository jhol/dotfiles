{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  pi-coding-agent,
}:
let
  pname = "pi-plan-mode";
  version = "0.28.0";

  src = fetchFromGitHub {
    owner = "dreki-gg";
    repo = "pi-extensions";
    rev = "bb2f034ffc6502386762a99b338daeaa3adf1d66";
    hash = "sha256-YFrpjUAb6vbVpA95myIXY+ke1PNihsrJzex92qIZH98=";
  };

  node_modules = stdenvNoCC.mkDerivation {
    pname = "${pname}-node_modules";
    inherit version src;

    nativeBuildInputs = [ bun ];

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
    outputHash = "sha256-Q9e/pMUqu1hNCZHqxsBHY7GMo/g8YXDMh+w6K8CDj1s=";
  };

  piNodeModules = "${pi-coding-agent}/lib/node_modules/pi-monorepo/node_modules/@earendil-works";
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ bun ];

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR

    cp -R ${node_modules}/node_modules ./node_modules
    chmod -R u+w ./node_modules
    rm node_modules/.bin/tsdown
    cp $(readlink -f ${node_modules}/node_modules/.bin/tsdown) node_modules/.bin/tsdown
    chmod +w node_modules/.bin/tsdown
    patchShebangs node_modules/.bin/tsdown

    (cd packages/command-sandbox && bun ../../node_modules/tsdown/dist/run.mjs)
    (cd packages/taskman && bun ../../node_modules/tsdown/dist/run.mjs)

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    cp packages/plan-mode/package.json $out/
    cp packages/plan-mode/README.md $out/
    cp packages/plan-mode/CHANGELOG.md $out/
    cp -R packages/plan-mode/extensions $out/
    cp -R packages/plan-mode/skills $out/
    cp -R packages/plan-mode/bin $out/
    cp -R node_modules $out/

    rm -f $out/node_modules/.bin/pi-plan-mode
    find $out/node_modules/@dreki-gg -maxdepth 1 -type l -delete

    rm -rf $out/node_modules/@dreki-gg/pi-command-sandbox
    rm -rf $out/node_modules/@dreki-gg/taskman
    mkdir -p $out/node_modules/@dreki-gg
    cp -R packages/command-sandbox $out/node_modules/@dreki-gg/pi-command-sandbox
    cp -R packages/taskman $out/node_modules/@dreki-gg/taskman

    mkdir -p $out/node_modules/@earendil-works
    ln -s ${piNodeModules}/pi-ai $out/node_modules/@earendil-works/pi-ai
    ln -s ${piNodeModules}/pi-tui $out/node_modules/@earendil-works/pi-tui

    runHook postInstall
  '';

  passthru = {
    inherit src node_modules;
  };

  meta = with lib; {
    description = "Two-phase planning workflow extension for Pi Coding Agent";
    homepage = "https://pi.dev/packages/@dreki-gg/pi-plan-mode";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
