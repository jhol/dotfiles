{
  flakeInputs,
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.jhol-dotfiles.web-browsers;
in
{
  options.modules.jhol-dotfiles.web-browsers = {
    enable = mkEnableOption "Enable Web Browsers";
  };

  config = mkIf cfg.enable (
    let
      nurPkgs = import flakeInputs.nur {
        inherit pkgs;
        nurpkgs = import flakeInputs.nixpkgs { system = pkgs.system; };
      };
    in
    {
      programs.brave.enable = true;

      programs.chromium = {
        enable = true;
        extensions = [
          { id = "bkdgflcldnnnapblkhphbgpggdiikppg"; } # DuckDuckGo Privacy Essentials
          { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
          { id = "edibdbjcniadpccecjdfdjjppcpchdlm"; } # I still don't care about cookies
          { id = "fnaicdffflnofjppbagibeoednhnbjhg"; } # Floccus
          { id = "oboonakemofpalcgghocfoadofidjkkk"; } # KeePassXC-Browser
          { id = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"; } # Privacy Badger
        ];
      };

      programs.firefox = {
        enable = true;

        policies = {
          DisablePocket = true;
          DisplayBookmarksToolbar = false;
          DontCheckDefaultBrowser = true;
          OfferToSaveLogins = false;
          NewTabPage = false;
          NoDefaultBookmarks = true;
          PasswordManagerEnable = false;
          FirefoxHome = {
            Highlights = false;
            Snippets = false;
            SponsoredPocket = false;
            SponsoredTopSites = false;
            Locked = true;
          };
          FirefoxSuggest = {
            SponsoredSuggestions = true;
            Locked = true;
          };
        };

        profiles.jhol = {
          name = "jhol";
          isDefault = true;

          search = {
            force = true;
            default = "ddg";
            engines = {
              "amazon-co-uk".metaData.hidden = true;
              "bing".metaData.hidden = true;
              "ebay".metaData.hidden = true;
            };
          };

          extensions.packages = with nurPkgs.repos.rycee.firefox-addons; [
            duckduckgo-privacy-essentials
            floccus
            istilldontcareaboutcookies
            keepassxc-browser
            privacy-badger
            ublock-origin
          ];
        };
      };
    }
  );
}
