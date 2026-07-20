{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.jhol-dotfiles.ai-tools;

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
    };

    programs.pi.coding-agent = {
      enable = true;

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
