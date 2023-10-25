{ lib, pkgs, config, ... }:
let
  cfg = config.modules.jhol-dotfiles.web-browsers;
in
{
  options.modules.jhol-dotfiles.web-browsers = {
    enable = lib.mkEnableOption "Enable Web Browsers";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      firefox
    ];

    programs.chromium = {
      enable = true;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }  # uBlock Origin
        { id = "hdokiejnpimakedhajhdlcegeplioahd"; }  # LastPass
        { id = "oboonakemofpalcgghocfoadofidjkkk"; }  # KeePassXC-Browser
      ];
    };
  };
}
