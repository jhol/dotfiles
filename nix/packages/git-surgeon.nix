{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:
rustPlatform.buildRustPackage rec {
  pname = "git-surgeon";
  version = "0.1.17";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "git-surgeon";
    rev = "v${version}";
    hash = "sha256-SeXHYZwhwvkYxFHW694Cp1VKKeehxgOdfKqShuPI7M4=";
  };

  cargoHash = "sha256-PbhASsdDxmVcIzV+oHIbpX70zjSeNvkwGcbhQRi88rE=";

  meta = with lib; {
    description = "Git primitives for autonomous coding agents";
    homepage = "https://github.com/raine/git-surgeon";
    license = licenses.mit;
    mainProgram = "git-surgeon";
  };
}
