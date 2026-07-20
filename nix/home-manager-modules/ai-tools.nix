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
            --suffix PATH : ${lib.makeBinPath skillPackages}
        '';
      };

      environment.PI_SKIP_VERSION_CHECK.value = "1";

      skills = lib.mapAttrsToList (_: builtins.dirOf) skills;

      settings.packages = [ "npm:@dreki-gg/pi-plan-mode" ];
    };

    # TODO: Install using programs.opencode.skills after 26.05 release
    xdg.configFile =
      lib.mapAttrs' (
        name: drv: lib.nameValuePair "opencode/skills/${name}/SKILL.md" { source = drv; }
      ) skills
      // lib.mapAttrs' (
        name: source: lib.nameValuePair "opencode/plugin/${name}.js" { inherit source; }
      ) opencodePlugins;

    home.file.".pi/agent/npm/node_modules/@dreki-gg/pi-plan-mode".source = pkgs.pi-plan-mode;
  };
}
