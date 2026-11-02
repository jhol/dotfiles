{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.modules.jhol-dotfiles.niri;

  # Dux Shell 2.0 needs Go >= 1.27.1; nixos-26.05 ships 1.27rc3. Take the Go
  # toolchain from Dux Shell's own nixpkgs pin for this package only rather
  # than bumping Go (and rebuilding every Go package) system-wide.
  dmsPkgs = pkgs.extend (
    _final: _prev: {
      go_1_27 = inputs.dms.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.go_1_27;
    }
  );
in
{
  # niri-flake supplies `programs.niri.settings` and `config.lib.niri.actions`
  # (Home Manager 26.05 has no niri module of its own). Dux Shell ships a Home
  # Manager module for the shell and a companion module that wires its startup
  # and keybinds into niri-flake's `programs.niri`.
  imports = [
    inputs.niri.homeModules.niri
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.dms-plugin-registry.homeModules.default
  ];

  options.modules.jhol-dotfiles.niri = {
    enable = lib.mkEnableOption "Niri compositor with the Dux Shell desktop";
  };

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;

      # niri-flake defaults to building niri from source; use the cached
      # nixpkgs build instead.
      package = pkgs.niri;

      settings = {
        input = {
          keyboard.xkb.layout = "us";
          touchpad = {
            tap = true;
            dwt = true;
            natural-scroll = true;
          };
        };

        layout = {
          gaps = 8;
          center-focused-column = "never";
          default-column-width.proportion = 0.5;
          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
          ];
          focus-ring = {
            width = 2;
            active.color = "#7aa2f7";
            inactive.color = "#3b4261";
          };
          border.enable = false;
        };

        # Wine windows via xwayland-satellite: app-id is the WM_CLASS (exe name).
        window-rules = [
          {
            matches = [
              { app-id = "^wine$"; }
              { app-id = "\\.exe$"; }
              { title = "\\.exe$"; }
            ];
            open-floating = true;
          }
        ];

        prefer-no-csd = true;
        hotkey-overlay.skip-at-startup = true;
        clipboard.disable-primary = false;
        cursor.hide-after-inactive-ms = 2000;

        # Binds declared here land in hm.kdl, which `includes.override = false`
        # orders last, so they win over Dux Shell's fragments. The DMS
        # fragments (~/.config/niri/dms/*.kdl) only appear after `dms setup
        # binds`/`dms setup colors` etc. has been run once, so the essentials
        # are also declared here to keep the first session usable.
        binds = with config.lib.niri.actions; {
          "Mod+Shift+Slash".action = show-hotkey-overlay;

          # Applications and Dux Shell surfaces.
          "Mod+T".action = spawn "kitty";
          "Mod+Return".action = spawn "kitty";
          "Mod+B".action = spawn "dms" "ipc" "call" "defaultApp" "browser";
          "Mod+E".action = spawn "neovide";
          "Mod+Space".action = spawn "dms" "ipc" "call" "spotlight" "toggle";
          "Mod+N".action = spawn "dms" "ipc" "call" "notepad" "toggle";
          "Mod+X".action = spawn "dms" "ipc" "call" "powermenu" "toggle";
          "Mod+Alt+L".action = spawn "dms" "ipc" "call" "lock" "lock";
          "Mod+Shift+W".action = spawn "dms" "ipc" "call" "window-rules" "toggle";

          # Windows.
          "Mod+Q".action = close-window;
          "Mod+O".action = toggle-overview;
          "Mod+O".repeat = false;
          "Mod+Tab".action = toggle-overview;
          "Mod+Tab".repeat = false;
          "Mod+F".action = maximize-column;
          "Mod+C".action = center-column;
          "Mod+Shift+Minus".action = set-window-height "-10%";
          "Mod+Shift+Equal".action = set-window-height "+10%";
          "Mod+Ctrl+R".action = reset-window-height;
          "Mod+Shift+F".action = fullscreen-window;
          "Mod+V".action = toggle-window-floating;
          "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
          "Mod+W".action = toggle-column-tabbed-display;
          "Mod+Comma".action = consume-window-into-column;
          "Mod+Period".action = expel-window-from-column;
          "Mod+BracketLeft".action = consume-or-expel-window-left;
          "Mod+BracketRight".action = consume-or-expel-window-right;

          # Focus.
          "Mod+Left".action = focus-column-left;
          "Mod+Down".action = focus-window-down;
          "Mod+Up".action = focus-window-up;
          "Mod+Right".action = focus-column-right;
          "Mod+H".action = focus-column-left;
          "Mod+J".action = focus-window-down;
          "Mod+K".action = focus-window-up;
          "Mod+L".action = focus-column-right;

          # Move the focused window/column.
          "Mod+Ctrl+Left".action = move-column-left;
          "Mod+Ctrl+Down".action = move-window-down;
          "Mod+Ctrl+Up".action = move-window-up;
          "Mod+Ctrl+Right".action = move-column-right;
          "Mod+Ctrl+H".action = move-column-left;
          "Mod+Ctrl+J".action = move-window-down;
          "Mod+Ctrl+K".action = move-window-up;
          "Mod+Ctrl+L".action = move-column-right;

          # Workspaces.
          "Mod+Page_Down".action = focus-workspace-down;
          "Mod+Page_Up".action = focus-workspace-up;
          "Mod+U".action = focus-workspace-down;
          "Mod+I".action = focus-workspace-up;
          "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
          "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
          "Mod+Ctrl+U".action = move-column-to-workspace-down;
          "Mod+Ctrl+I".action = move-column-to-workspace-up;
          "Mod+Shift+Page_Down".action = move-workspace-down;
          "Mod+Shift+Page_Up".action = move-workspace-up;
          "Mod+Shift+U".action = move-workspace-down;
          "Mod+Shift+I".action = move-workspace-up;
          "Mod+1".action = focus-workspace 1;
          "Mod+2".action = focus-workspace 2;
          "Mod+3".action = focus-workspace 3;
          "Mod+4".action = focus-workspace 4;
          "Mod+5".action = focus-workspace 5;
          "Mod+6".action = focus-workspace 6;
          "Mod+7".action = focus-workspace 7;
          "Mod+8".action = focus-workspace 8;
          "Mod+9".action = focus-workspace 9;

          # Column sizing.
          "Mod+R".action = switch-preset-column-width;
          "Mod+Shift+R".action = switch-preset-column-width-back;
          "Mod+Minus".action = set-column-width "-10%";
          "Mod+Equal".action = set-column-width "+10%";

          # Monitors.
          "Mod+Shift+Left".action = focus-monitor-left;
          "Mod+Shift+Down".action = focus-monitor-down;
          "Mod+Shift+Up".action = focus-monitor-up;
          "Mod+Shift+Right".action = focus-monitor-right;
          "Mod+Shift+H".action = focus-monitor-left;
          "Mod+Shift+J".action = focus-monitor-down;
          "Mod+Shift+K".action = focus-monitor-up;
          "Mod+Shift+L".action = focus-monitor-right;

          "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
          "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
          "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
          "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
          "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
          "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
          "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
          "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

          # Session.
          "Mod+Shift+E".action = quit;
          "Mod+Escape".action = toggle-keyboard-shortcuts-inhibit;
          "Mod+Escape".allow-inhibiting = false;
          "Mod+Shift+P".action = power-off-monitors;

          # Media keys drive the Dux Shell OSD even before `dms setup`.
          "XF86AudioRaiseVolume".action = spawn "dms" "ipc" "call" "audio" "increment" "3";
          "XF86AudioRaiseVolume".allow-when-locked = true;
          "XF86AudioLowerVolume".action = spawn "dms" "ipc" "call" "audio" "decrement" "3";
          "XF86AudioLowerVolume".allow-when-locked = true;
          "XF86AudioMute".action = spawn "dms" "ipc" "call" "audio" "mute";
          "XF86AudioMute".allow-when-locked = true;
          "XF86AudioMicMute".action = spawn "dms" "ipc" "call" "audio" "micmute";
          "XF86AudioMicMute".allow-when-locked = true;
          "XF86MonBrightnessUp".action = spawn "dms" "ipc" "call" "brightness" "increment" "5" "";
          "XF86MonBrightnessUp".allow-when-locked = true;
          "XF86MonBrightnessDown".action = spawn "dms" "ipc" "call" "brightness" "decrement" "5" "";
          "XF86MonBrightnessDown".allow-when-locked = true;
        };
      };
    };

    programs.dank-material-shell = {
      enable = true;
      package = inputs.dms.lib.mkDmsShell dmsPkgs;

      # Start through systemd so the shell is restarted on failure. Bind it to
      # niri.service rather than the generic graphical-session.target: Plasma
      # activates that target too, which otherwise starts Dux Shell on Plasma.
      # Do not also set `niri.enableSpawn` — that would launch a second
      # instance.
      systemd.enable = true;
      systemd.target = "niri.service";

      niri = {
        # Dux Shell's full default keymap already arrives via `includes`
        # (dms/binds.kdl); `enableKeybinds` would duplicate it and warns when
        # combined with includes.
        enableKeybinds = false;
        enableSpawn = false;

        includes = {
          enable = true;
          # Include hm.kdl after the Dux Shell files so the settings above
          # take priority.
          override = false;
        };
      };

      # `settings`, `clipboardSettings` and `session` are deliberately left
      # empty: the module only writes those files when they are non-empty,
      # which keeps ~/.config/dms/settings.json writable by the shell's own
      # settings UI. Move keys here if you want them pinned declaratively.

      # "Wallpaper of the Day" (max72bra/DankPluginBingWallpaper) from the
      # registry: downloads a fresh daily image and sets it as the wallpaper.
      # The registry module only copies the plugin; its runtime dependencies
      # are provided below.
      plugins.wallpaperBing.enable = true;
    };

    # niri spawns xwayland-satellite on demand for X11 clients, so it has to
    # be on PATH. curl, inotify-tools and libnotify (notify-send) are runtime
    # dependencies of the Wallpaper of the Day plugin.
    home.packages = [
      pkgs.xwayland-satellite
      pkgs.curl
      pkgs.inotify-tools
      pkgs.libnotify
    ];
  };
}
