{ flakeInputs, lib, pkgs, config, ... }:
with lib; let
  cfg = config.modules.jhol-dotfiles.web-browsers;
in
{
  options.modules.jhol-dotfiles.web-browsers = {
    enable = mkEnableOption "Enable Web Browsers";
  };

  config = mkIf cfg.enable (let
    nurPkgs = import flakeInputs.nur {
      inherit pkgs;
      nurpkgs = import flakeInputs.nixpkgs { system = pkgs.system; };
    };
  in {
    programs.chromium = {
      enable = true;
      extensions = [
        { id = "bkdgflcldnnnapblkhphbgpggdiikppg"; }  # DuckDuckGo Privacy Essentials
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }  # uBlock Origin
        { id = "oboonakemofpalcgghocfoadofidjkkk"; }  # KeePassXC-Browser
        { id = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"; }  # Privacy Badger
      ];
    };

    programs.firefox = {
      enable = true;

      # TODO: Enable once 23.11 is release
      #policies =  {
      #  DisablePocket = true;
      #  DisplayBookmarksToolbar = false;
      #  DontCheckDefaultBrowser = true;
      #  OfferToSaveLogins = false;
      #  NewTabPage = false;
      #  NoDefaultBookmarks = true;
      #  PasswordManagerEnable = false;
      #};

      profiles.jhol = {
        name = "jhol";
        isDefault = true;

        search = {
          force = true;
          default = "DuckDuckGo";
          engines = {
            "Amazon.co.uk".metaData.hidden = true;
            "Bing".metaData.hidden = true;
            "eBay".metaData.hidden = true;
          };
        };

        extensions = with nurPkgs.repos.rycee.firefox-addons; [
          duckduckgo-privacy-essentials
          keepassxc-browser
          privacy-badger
          ublock-origin
        ];
      };
    };
  });
}
