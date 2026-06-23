# Forward-port of the upstream home-manager pi-coding-agent module (master only).
# Remove once release-26.05 includes it.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    ;

  cfg = config.programs.pi-coding-agent;

  jsonFormat = pkgs.formats.json { };

  upstreamConfigDir = "${config.home.homeDirectory}/.pi/agent";

  packageWithExtraPackages =
    if cfg.package != null && cfg.extraPackages != [ ] then
      pkgs.symlinkJoin {
        inherit (cfg.package) meta;
        name = "${lib.getName cfg.package}-wrapped-${lib.getVersion cfg.package}";
        paths = [ cfg.package ];
        preferLocalBuild = true;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/pi \
            --suffix PATH : ${lib.makeBinPath cfg.extraPackages}
        '';
      }
    else
      cfg.package;
in
{
  options.programs.pi-coding-agent = {
    enable = mkEnableOption "pi-coding-agent";

    package = mkPackageOption pkgs "pi-coding-agent" { nullable = true; };

    extraPackages = mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      example = literalExpression "[ pkgs.nodejs pkgs.bun ]";
      description = ''
        Extra packages available to Pi Coding Agent.
        These are added to the PATH of the wrapped pi binary.
      '';
    };

    configDir = mkOption {
      type = lib.types.str;
      default = upstreamConfigDir;
      defaultText = literalExpression ''"''${config.home.homeDirectory}/.pi/agent"'';
      example = literalExpression ''"''${config.xdg.configHome}/pi/agent"'';
      description = ''
        Directory holding Pi Coding Agent's configuration files.

        Defaults to {file}`~/.pi/agent`, matching the upstream
        {command}`pi` CLI default. The {env}`PI_CODING_AGENT_DIR`
        environment variable is exported automatically whenever the
        directory differs from this default so the CLI reads
        configuration from the same location.
      '';
    };

    settings = mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = {
        defaultProvider = "anthropic";
        defaultModel = "claude-sonnet-4-20250514";
        defaultThinkingLevel = "medium";
        theme = "dark";
      };
      description = ''
        Configuration written to
        {file}`~/.pi/agent/settings.json`.
        See <https://pi.dev/docs/latest/settings> for the
        documentation.
      '';
    };

    keybindings = mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = ''
        Keybindings configuration written to
        {file}`~/.pi/agent/keybindings.json`.
        See <https://pi.dev/docs/latest/keybindings> for the
        documentation.
      '';
    };

    models = mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = ''
        Custom model providers written to
        {file}`~/.pi/agent/models.json`.
        See <https://pi.dev/docs/latest/models> for the
        documentation.
      '';
    };

    context = mkOption {
      type = lib.types.either lib.types.lines lib.types.path;
      default = "";
      description = ''
        Global context for Pi Coding Agent.

        The value is either:
        - Inline content as a string
        - A path to a file containing the content

        The configured content is written to
        {file}`AGENTS.md` inside
        {option}`programs.pi-coding-agent.configDir`
        (default {file}`~/.pi/agent/AGENTS.md`).
      '';
      example = literalExpression "./pi-context.md";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = mkIf (packageWithExtraPackages != null) [
        packageWithExtraPackages
      ];

      sessionVariables = lib.mkIf (cfg.configDir != upstreamConfigDir) {
        PI_CODING_AGENT_DIR = cfg.configDir;
      };

      file = lib.mkMerge [
        (mkIf (cfg.settings != { }) {
          "${cfg.configDir}/settings.json".source =
            jsonFormat.generate "pi-coding-agent-settings.json" cfg.settings;
        })

        (mkIf (cfg.keybindings != { }) {
          "${cfg.configDir}/keybindings.json".source =
            jsonFormat.generate "pi-coding-agent-keybindings.json" cfg.keybindings;
        })

        (mkIf (cfg.models != { }) {
          "${cfg.configDir}/models.json".source =
            jsonFormat.generate "pi-coding-agent-models.json" cfg.models;
        })

        (
          if lib.isPath cfg.context then
            { "${cfg.configDir}/AGENTS.md".source = cfg.context; }
          else
            (mkIf (cfg.context != "") {
              "${cfg.configDir}/AGENTS.md".text = cfg.context;
            })
        )
      ];
    };
  };
}
