{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.jhol-dotfiles.ai-tools;

  # --- Shared provider types ---------------------------------------------------

  modelModule = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Human-readable model name.";
      };
      context = lib.mkOption {
        type = lib.types.int;
        description = "Context window size in tokens.";
      };
      output = lib.mkOption {
        type = lib.types.int;
        description = "Maximum output tokens.";
      };
      reasoning = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether the model supports extended thinking.";
      };
      input = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "text" ];
        description = "Supported input modalities.";
      };
    };
  };

  opencodeProviderModule = lib.types.submodule {
    options = {
      npm = lib.mkOption {
        type = lib.types.str;
        description = "NPM package implementing the AI SDK provider.";
        example = "@ai-sdk/openai-compatible";
      };
    };
  };

  piProviderModule = lib.types.submodule {
    options = {
      api = lib.mkOption {
        type = lib.types.str;
        description = "Pi API type (openai-completions, anthropic-messages, etc).";
        example = "openai-completions";
      };
      apiKey = lib.mkOption {
        type = lib.types.str;
        description = "API key: literal, env var name, or '!cmd' shell command.";
        example = "!cat /run/secrets/api-key";
      };
      compat = lib.mkOption {
        type = lib.types.attrsOf lib.types.bool;
        default = { };
        description = "Pi compatibility flags for the provider.";
        example = {
          supportsDeveloperRole = false;
          supportsReasoningEffort = false;
        };
      };
    };
  };

  hermesProviderModule = lib.types.submodule {
    options = {
      keyEnv = lib.mkOption {
        type = lib.types.str;
        description = "Environment variable name containing the API key for Hermes.";
        example = "NVIDIA_API_KEY";
      };
      transport = lib.mkOption {
        type = lib.types.str;
        default = "chat_completions";
        description = "Hermes wire transport (chat_completions, codex_responses, etc).";
      };
    };
  };

  providerModule = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Human-readable provider name.";
      };
      baseUrl = lib.mkOption {
        type = lib.types.str;
        description = "Provider API base URL.";
      };
      models = lib.mkOption {
        type = lib.types.attrsOf modelModule;
        default = { };
        description = "Model definitions keyed by model ID.";
      };
      opencode = lib.mkOption {
        type = opencodeProviderModule;
        description = "OpenCode-specific provider configuration.";
      };
      pi = lib.mkOption {
        type = piProviderModule;
        description = "Pi-specific provider configuration.";
      };
      hermes = lib.mkOption {
        type = hermesProviderModule;
        description = "Hermes-specific provider configuration.";
      };
    };
  };

  # --- Provider transformations ------------------------------------------------

  # Transform providers into OpenCode settings.provider format.
  mkOpencodeProviders = lib.mapAttrs (_id: prov: {
    npm = prov.opencode.npm;
    name = prov.name;
    options.baseURL = prov.baseUrl;
    models = lib.mapAttrs (_mid: m: {
      inherit (m) name;
      limit = {
        inherit (m) context output;
      };
    }) prov.models;
  }) cfg.providers;

  # Transform providers into Pi models.json format.
  mkPiModelsJson =
    let
      piProviders = lib.mapAttrs (
        _id: prov:
        {
          baseUrl = prov.baseUrl;
          inherit (prov.pi) api apiKey;
        }
        // lib.optionalAttrs (prov.pi.compat != { }) { inherit (prov.pi) compat; }
        // {
          models = lib.mapAttrsToList (
            id: m:
            {
              inherit id;
              inherit (m) name reasoning;
              contextWindow = m.context;
              maxTokens = m.output;
            }
            // lib.optionalAttrs (m.input != [ "text" ]) { inherit (m) input; }
          ) prov.models;
        }
      ) cfg.providers;
    in
    (pkgs.formats.json { }).generate "pi-coding-agent-models.json" { providers = piProviders; };

  # Transform providers into Hermes config.yaml providers format.
  mkHermesProviders = lib.mapAttrs (_id: prov: {
    name = prov.name;
    base_url = prov.baseUrl;
    key_env = prov.hermes.keyEnv;
    transport = prov.hermes.transport;
    models = lib.mapAttrs (_mid: m: {
      context_length = m.context;
    }) prov.models;
  }) cfg.providers;

  hasProviders = cfg.providers != { };

  lspServers = {
    clangd = {
      package = pkgs.clang-tools;
      command = [ "clangd" ];
    };
    nixd = {
      package = pkgs.nixd;
      command = [ "nixd" ];
    };
    pyright = {
      package = pkgs.pyright;
      command = [
        "pyright-langserver"
        "--stdio"
      ];
    };
    rust = {
      package = pkgs.rust-analyzer;
      command = [ "rust-analyzer" ];
    };
  };

  lspPackages = lib.mapAttrsToList (_: s: s.package) lspServers;

  lspSettings = lib.mapAttrs (_: s: {
    command = [ "${s.package}/bin/${builtins.head s.command}" ] ++ builtins.tail s.command;
  }) lspServers;

  skills =
    let
      caveman-src = pkgs.fetchFromGitHub {
        owner = "JuliusBrussee";
        repo = "caveman";
        rev = "84cc3c14fa1e10182adaced856e003406ccd250d";
        hash = "sha256-M+NoWXxrhtbkbe/lmq7P0/KpmqOZzJjhgeUVjY+7N2k=";
      };

      agent-skills-src = pkgs.fetchFromGitHub {
        owner = "regenrek";
        repo = "agent-skills";
        rev = "a1dce7f962b8bcb4f6215cf7fa4941c1cb50c426";
        hash = "sha256-UUVTpf9QXOAo5yrdGwjyX8N1MkaAAhwWJ2wXUYJnA8M=";
      };
    in
    {
      "caveman" = "${caveman-src}/skills/caveman/SKILL.md";
      "consolidate-test-suites" = "${agent-skills-src}/skills/consolidate-test-suites/SKILL.md";
      "git-surgeon" = "${pkgs.git-surgeon.src}/skills/git-surgeon/SKILL.md";
      "jj-surgeon" = "${pkgs.jj-hunk-tool.src}/skills/jj-surgeon/SKILL.md";
    };

  skillPackages = [
    pkgs.git-surgeon
    pkgs.jj-hunk-tool
  ];

  mcpServers = { };

  opencodePlugins = {
    "opencode-notify" = "${pkgs.opencode-notify}/lib/opencode-notify/index.js";
    "opencode-background-agents" =
      "${pkgs.opencode-background-agents}/lib/opencode-background-agents/index.js";
  };

  narumitw-pi-extensions-src = pkgs.fetchFromGitHub {
    owner = "narumiruna";
    repo = "pi-extensions";
    rev = "20c9525ec270394c7f22410b3ed3ef9ede6ced4f"; # v0.22.0
    hash = "sha256-GJuihw8eFNKtG/rGrvgKJJwDPIS5sKUZNRUh+6CDifE=";
  };

  pi-observational-memory-src = pkgs.fetchFromGitHub {
    owner = "elpapi42";
    repo = "pi-observational-memory";
    rev = "27a5195eaf90e4e2ca1302e3a31d4bb14df982a5"; # v3.0.3
    hash = "sha256-/XVD/VqEC8XFn8bu8R+f1Wah0SSm7yDdkR5NBuG94oA=";
  };

  pi-openrouter-realtime-src = pkgs.fetchFromGitHub {
    owner = "olixis";
    repo = "pi-openrouter-plus";
    rev = "eb29f6864f63152d19d39dae86d8a59afa583a54"; # v0.3.7
    hash = "sha256-Z7WGmOllKAIArtxiuP0lvNWtWXm+3y21257ud1sBqG8=";
  };

  # rpiv-todo and rpiv-ask-user-question import @juicesharp/rpiv-config (hard)
  # and dynamically import @juicesharp/rpiv-i18n (soft-optional; English
  # fallback if missing). The shim below makes both resolvable via node's
  # parent-dir node_modules walk; typebox and @earendil-works/* resolve from
  # pi's bundled NODE_PATH.
  rpiv-mono-src = pkgs.fetchFromGitHub {
    owner = "juicesharp";
    repo = "rpiv-mono";
    rev = "060373d9292aeb46aeedc23a6d818a997200a6e5"; # v1.20.0
    hash = "sha256-t2WVwhyT7x5D049iot4UDUWp+oM+XDudHbq/nBL/b84=";
  };

  rpiv-extensions = pkgs.runCommand "rpiv-extensions" { } ''
    mkdir -p $out/node_modules/@juicesharp
    cp -R ${rpiv-mono-src}/packages/rpiv-todo $out/rpiv-todo
    cp -R ${rpiv-mono-src}/packages/rpiv-ask-user-question $out/rpiv-ask-user-question
    cp -R ${rpiv-mono-src}/packages/rpiv-config $out/node_modules/@juicesharp/rpiv-config
    cp -R ${rpiv-mono-src}/packages/rpiv-i18n $out/node_modules/@juicesharp/rpiv-i18n
  '';
in
{
  options.modules.jhol-dotfiles.ai-tools = {
    enable = lib.mkEnableOption "Enable AI Tools";

    opencodePackage = lib.mkPackageOption pkgs "opencode" { };

    providers = lib.mkOption {
      type = lib.types.attrsOf providerModule;
      default = { };
      description = ''
        Shared provider definitions that are rendered into both OpenCode
        and Pi configurations. Each provider is keyed by a unique ID that
        appears in model selectors (e.g. "nvidia-hub/gcp/google/gemini-2.5-flash").
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;

      package = pkgs.symlinkJoin {
        inherit (cfg.opencodePackage) meta;
        name = "${lib.getName cfg.opencodePackage}-with-lsp";
        paths = [ cfg.opencodePackage ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/opencode \
            --suffix PATH : ${
              lib.makeBinPath (
                lspPackages
                ++ skillPackages
                ++ [
                  # `notify-send` backend used by opencode-notify on Linux.
                  pkgs.libnotify
                ]
              )
            } \
            --set OPENCODE_DISABLE_LSP_DOWNLOAD true
        '';
      };

      settings.lsp = lspSettings;
      settings.mcp = mcpServers;

      # opencode-background-agents provides its own task-delegation tool, so
      # the native `task` tool is disabled to avoid conflicting delegation
      # mechanisms (per the OCX registry recommendation).
      settings.permission.task = "deny";

      settings.provider = lib.mkIf hasProviders mkOpencodeProviders;
    };

    programs.hermes-agent.settings.providers = lib.mkIf hasProviders mkHermesProviders;

    programs.hermes-agent.enable = true;

    programs.pi.coding-agent = {
      enable = true;

      models = lib.mkIf hasProviders mkPiModelsJson;

      package = pkgs.symlinkJoin {
        inherit (pkgs.pi-coding-agent) meta;
        name = "${lib.getName pkgs.pi-coding-agent}-wrapped";
        paths = [ pkgs.pi-coding-agent ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/pi \
            --suffix PATH : ${lib.makeBinPath (skillPackages ++ lspPackages)}
        '';
      };

      environment.PI_SKIP_VERSION_CHECK.value = "1";

      skills = lib.mapAttrsToList (_: builtins.dirOf) skills;

      extensions =
        (map (name: "${narumitw-pi-extensions-src}/extensions/pi-${name}/src/${name}.ts") [
          "btw"
          "firecrawl"
          "goal"
          "plan-mode"
          "retry"
          "statusline"
          "subagents"
        ])
        ++ [
          "${narumitw-pi-extensions-src}/extensions/pi-lsp/src/pi-lsp.ts"
          "${pi-observational-memory-src}/src/index.ts"
          "${pi-openrouter-realtime-src}/extensions/openrouter-routing/index.ts"
          "${rpiv-extensions}/rpiv-todo/index.ts"
          "${rpiv-extensions}/rpiv-ask-user-question/index.ts"
          "${pkgs.pi-mcp-adapter}/lib/node_modules/pi-mcp-adapter/index.ts"
        ];
    };

    # TODO: Install using programs.opencode.skills after 26.05 release
    xdg.configFile =
      lib.mapAttrs' (
        name: drv: lib.nameValuePair "opencode/skills/${name}/SKILL.md" { source = drv; }
      ) skills
      // lib.mapAttrs' (
        name: source: lib.nameValuePair "opencode/plugin/${name}.js" { inherit source; }
      ) opencodePlugins;
  };
}
