{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.hermes-agent;

  jsonFormat = pkgs.formats.json { };

  # Environment prelude: export secrets from file paths or literal values at
  # runtime so they never enter the Nix store.
  envPrelude = lib.optionalString (cfg.environment != { }) (
    lib.concatLines (
      lib.mapAttrsToList (
        name: value:
        if value ? file then
          ''export ${name}="$(cat ${lib.escapeShellArg "${value.file}"})"''
        else
          "export ${name}=${lib.escapeShellArg value.value}"
      ) (lib.filterAttrs (_: v: v != null) cfg.environment)
    )
  );

  # Generated config.yaml — Hermes reads YAML which is a superset of JSON.
  hermesConfig = cfg.settings // {
    model = {
      provider = cfg.defaultProvider;
      default = cfg.defaultModel;
    };
  };

  configFile = jsonFormat.generate "hermes-config.yaml" hermesConfig;

  # Wrapper script that sets up environment then execs hermes.
  wrapped =
    if envPrelude == "" then
      cfg.package
    else
      pkgs.writeShellScriptBin "hermes" ''
        ${envPrelude}
        exec ${lib.getExe cfg.package} "$@"
      '';

  environmentValue =
    let
      nixPath = lib.types.addCheck lib.types.path builtins.isPath;
      taggedValue = lib.types.attrTag {
        file = lib.mkOption {
          type = lib.types.either lib.types.str nixPath;
          description = "File whose contents are exported at runtime.";
        };
        value = lib.mkOption {
          type = lib.types.str;
          description = "Literal value to export.";
        };
      };
    in
    taggedValue;
in
{
  options.programs.hermes-agent = {
    enable = lib.mkEnableOption "Hermes Agent";

    package = lib.mkPackageOption pkgs "hermes-agent" { };

    homeDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.hermes";
      description = "Hermes home directory (HERMES_HOME).";
    };

    defaultProvider = lib.mkOption {
      type = lib.types.str;
      description = "Default inference provider ID.";
      example = "nvidia-hub";
    };

    defaultModel = lib.mkOption {
      type = lib.types.str;
      description = "Default model ID within the provider.";
      example = "gcp/google/gemini-2.5-flash";
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Hermes config.yaml settings (deep-merged).";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf environmentValue;
      default = { };
      description = ''
        Environment variables exported before launching Hermes.
        Use { file = path; } for runtime secret resolution or
        { value = "literal"; } for non-sensitive values.
      '';
      example = lib.literalExpression ''
        {
          NVIDIA_API_KEY.file = config.sops.secrets.nvidia_api_key.path;
          HERMES_TUI_DIR.value = "/some/path";
        }
      '';
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages on Hermes' PATH.";
    };

    gateway = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the Hermes messaging gateway as a systemd user service.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ wrapped ] ++ cfg.extraPackages;

    # Generate declarative config.yaml
    home.file."${cfg.homeDir}/config.yaml".source = configFile;

    # Managed mode marker
    home.file."${cfg.homeDir}/.managed".text = "";

    # Set HERMES_HOME for interactive shells
    home.sessionVariables.HERMES_HOME = cfg.homeDir;

    # Create mutable state directories
    home.activation.hermes-agent-dirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      for dir in cron sessions logs logs/curator memories skills pairing hooks image_cache audio_cache; do
        mkdir -p "${cfg.homeDir}/$dir"
      done
    '';

    # Systemd user gateway service
    systemd.user.services = lib.mkIf cfg.gateway.enable {
      hermes-gateway = {
        Unit = {
          Description = "Hermes Agent Messaging Gateway";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "${lib.getExe wrapped} gateway run --replace";
          WorkingDirectory = cfg.homeDir;
          Environment = [
            "HERMES_HOME=${cfg.homeDir}"
            "HERMES_MANAGED=nixos"
            "PATH=${
              lib.makeBinPath (
                [
                  wrapped
                  pkgs.bash
                  pkgs.coreutils
                  pkgs.git
                ]
                ++ cfg.extraPackages
              )
            }:$PATH"
          ];
          Restart = "always";
          RestartSec = 5;
          KillMode = "mixed";
          KillSignal = "SIGTERM";
          TimeoutStopSec = 90;
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
