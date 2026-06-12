{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.forgecode;
  tomlFormat = pkgs.formats.toml { };
  jsonFormat = pkgs.formats.json { };

  configDir = "forgecode";

  # ForgeCode no longer reads API keys from environment variables. Instead it
  # uses a mutable .credentials.json file in the config directory. The wrapper
  # writes this file at runtime from the referenced secret files so that sops
  # decryption happens at the correct time.
  #
  # We generate a small helper script that writes .credentials.json from the
  # referenced secret files. This avoids quoting nightmares with --run.
  credentialsWriter =
    let
      # Shell script that reads each secret file and writes the JSON array.
      script = pkgs.writeShellScript "forge-write-credentials" (
        let
          configPath = "${config.xdg.configHome}/${configDir}/.credentials.json";
          entries = lib.mapAttrsToList (providerId: filePath: ''
            key="$(cat ${filePath})"
            entries+=("{\"id\":\"${providerId}\",\"auth_details\":{\"api_key\":\"$key\"}}")
          '') cfg.credentialFiles;
        in
        ''
          entries=()
          ${lib.concatStringsSep "\n" entries}
          # Join entries with commas and write JSON array
          IFS=','
          printf '[%s]' "''${entries[*]}" > ${configPath}
        ''
      );
    in
    lib.optionalString (cfg.credentialFiles != { }) "--run ${script}";

  packageWithExtras =
    if cfg.package != null then
      pkgs.symlinkJoin {
        inherit (cfg.package) meta;
        name = "${lib.getName cfg.package}-wrapped";
        paths = [ cfg.package ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/forge \
            --set FORGE_CONFIG "${config.xdg.configHome}/${configDir}" \
            ${
              lib.optionalString (cfg.extraPackages != [ ]) "--suffix PATH : ${lib.makeBinPath cfg.extraPackages}"
            } \
            ${credentialsWriter}
        '';
      }
    else
      null;
in
{
  options.programs.forgecode = {
    enable = lib.mkEnableOption "forgecode";

    package = lib.mkPackageOption pkgs "forgecode" { };

    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.fd ]";
      description = "Extra packages available on forge's PATH.";
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the ForgeCode ZSH plugin (: prefix commands).";
    };

    credentialFiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        "nvidia-hub" = "/run/secrets/nvidia_api_key";
      };
      description = ''
        Mapping of provider IDs to runtime file paths containing API keys.
        At startup, a .credentials.json is written from these files.
        ForgeCode no longer reads API keys from environment variables.
      '';
    };

    settings = lib.mkOption {
      inherit (tomlFormat) type;
      default = { };
      description = ''
        Configuration written to {file}`$FORGE_CONFIG/.forge.toml`.
        See <https://forgecode.dev/docs/forgecode-config/> for available options.
      '';
    };

    context = lib.mkOption {
      type = lib.types.either lib.types.lines lib.types.path;
      default = "";
      description = ''
        Global AGENTS.md for all ForgeCode sessions.
        Written to {file}`$FORGE_CONFIG/AGENTS.md`.
      '';
    };

    skills = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path);
      default = { };
      description = ''
        Skills installed under {file}`$FORGE_CONFIG/skills/<name>/SKILL.md`.
        See <https://forgecode.dev/docs/skills/> for the format.
      '';
    };

    mcp = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = ''
        MCP server configuration written to {file}`$FORGE_CONFIG/.mcp.json`.
        See <https://forgecode.dev/docs/mcp-integration/> for the format.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional (packageWithExtras != null) packageWithExtras;

    programs.zsh.plugins = lib.mkIf cfg.enableZshIntegration [
      {
        name = "forge";
        src = "${cfg.package}/share/forgecode/shell-plugin";
      }
    ];

    programs.zsh.sessionVariables = lib.mkIf cfg.enableZshIntegration {
      FORGE_BIN = "${packageWithExtras}/bin/forge";
    };

    xdg.configFile = {
      "${configDir}/.forge.toml" = lib.mkIf (cfg.settings != { }) {
        source = tomlFormat.generate "forge.toml" cfg.settings;
      };

      "${configDir}/AGENTS.md" =
        if lib.isPath cfg.context then
          { source = cfg.context; }
        else
          lib.mkIf (cfg.context != "") { text = cfg.context; };

      "${configDir}/.mcp.json" = lib.mkIf (cfg.mcp != { }) {
        source = jsonFormat.generate "mcp.json" { mcpServers = cfg.mcp; };
      };
    }
    // lib.mapAttrs' (
      name: content:
      lib.nameValuePair "${configDir}/skills/${name}/SKILL.md" (
        if lib.isPath content then { source = content; } else { text = content; }
      )
    ) cfg.skills;
  };
}
