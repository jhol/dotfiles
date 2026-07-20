{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  jq,
}:
buildNpmPackage rec {
  pname = "pi-mcp-adapter";
  version = "2.11.0";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    rev = "b702afe6451e007ff510ff53adcf6b2e5c354eba"; # v2.11.0
    hash = "sha256-JjYS9tPSoVuubdmHTqTNNYfDJOc9CBPvVbIxvdJWi7M=";
  };

  npmDepsHash = "sha256-uyQvySvDYGUb1ukZuHsFQIb5+eRJGg9snOuXew3bRdg=";
  npmDepsFetcherVersion = 2;

  # Upstream package-lock.json (v3) is missing integrity hashes for three
  # nested @earendil-works/* deps of pi-coding-agent, which makes
  # prefetch-npm-deps panic. Patch the lockfile to add them.
  postPatch = ''
    ${lib.getExe jq} '
      .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-agent-core"].integrity = "sha512-XKxgdjhcPuyjrthCOFSgfzT3xZ1uBrJ1IMVDxci1to6hIN6BIg9J5iY8q0pGXK1DLgATLP23da+1UyZLwA360Q=="
      | .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-ai"].integrity = "sha512-9jR23tOl0BIUdQMn70Gr72xYBpM7Xgl9Lyv7gAnU1USfkNRuYG/f/edLl+n/Dp/RafDW3JI4DF7y/GhgkORuew=="
      | .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-tui"].integrity = "sha512-FUVOjDn1DVwM1uHD5MNYboXQrXjIDbSt+BQ3py7nQWCY62tKfxgiM1OBMxTcwRWLfSdZHUPpV0hm1loIdUJnPw=="
    ' package-lock.json > package-lock.json.tmp && mv package-lock.json.tmp package-lock.json
  '';

  # No build script upstream (only test scripts); cli.js and
  # app-bridge.bundle.js are committed prebuilt artifacts.
  dontNpmBuild = true;

  # Strip @earendil-works/* from node_modules so those imports resolve to
  # the running pi's own bundled copies (matching pi 0.80.10) via NODE_PATH,
  # rather than the npm-installed versions. The other deps
  # (@modelcontextprotocol/*, open, recheck, zod) stay self-contained.
  # Also remove the .bin symlinks that pointed at the stripped packages.
  postInstall = ''
    rm -rf $out/lib/node_modules/${pname}/node_modules/@earendil-works
    find $out/lib/node_modules/${pname}/node_modules/.bin -xtype l -delete
  '';

  nativeBuildInputs = [ jq ];

  meta = with lib; {
    description = "MCP (Model Context Protocol) adapter extension for Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    license = licenses.mit;
  };
}
