{ flakeInputs, stdenv, ... }:
let
  upstream = flakeInputs.llm-agents.packages.${stdenv.hostPlatform.system}.hermes-agent;
in
upstream.overrideAttrs (prev: {
  postPatch = (prev.postPatch or "") + ''
    cp ${./patches/daemon-pool-py314.py} tools/daemon_pool.py
  '';
})
