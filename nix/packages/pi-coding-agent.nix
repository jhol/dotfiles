{ flakeInputs, stdenv, ... }: flakeInputs.pi.packages.${stdenv.hostPlatform.system}.coding-agent
