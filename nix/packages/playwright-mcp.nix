{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "playwright-mcp";
  version = "0.0.83";

  src = fetchFromGitHub {
    owner = "Microsoft";
    repo = "playwright-mcp";
    tag = "v${version}";
    hash = "sha256-Pkm4kmnWgLX7wmPjL3hM3LWfkPwIVUoW3Wp/RHjX/hA=";
  };

  npmDepsHash = "sha256-+uDq8oXkxQK4SNXBNZFtd4zrun1MGeSMeiLHViaNqHY=";

  # Keep upstream's coupled Playwright dependencies for bridge protocol compatibility.
  # Extension mode uses the installed browser, not downloaded Playwright browsers.
  PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  dontNpmBuild = true;

  passthru.skipBulkUpdate = true;

  meta = {
    changelog = "https://github.com/Microsoft/playwright-mcp/releases/tag/v${version}";
    description = "Playwright MCP server";
    homepage = "https://github.com/Microsoft/playwright-mcp";
    license = lib.licenses.asl20;
    mainProgram = "playwright-mcp";
  };
}
