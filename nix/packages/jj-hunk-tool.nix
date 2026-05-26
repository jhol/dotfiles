{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:
rustPlatform.buildRustPackage {
  pname = "jj-hunk-tool";
  version = "0.1.0-unstable-2025-05-25";

  src = fetchFromGitHub {
    owner = "mvzink";
    repo = "jj-hunk-tool";
    rev = "4ca39466fe0eaefdb021be09b2d6b059ab375e6a";
    hash = "sha256-nYQJ8RpONi5P7mrXAxAvNmTrAlcxh/6ykYQCyGb5ahA=";
  };

  cargoHash = "sha256-qH/R0+urKZX3qtD6wt42hjgBOtu170HaR3SegRNlkh4=";

  # Integration tests require a jj binary at test time
  doCheck = false;

  meta = with lib; {
    description = "Non-interactive hunk-level jj operations";
    homepage = "https://github.com/mvzink/jj-hunk-tool";
    license = licenses.mit;
    mainProgram = "jj-hunk-tool";
  };
}
