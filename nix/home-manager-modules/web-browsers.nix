{ lib, pkgs, config, ... }:
with lib; let
  cfg = config.modules.jhol-dotfiles.web-browsers;
in
{
  options.modules.jhol-dotfiles.web-browsers = {
    enable = mkEnableOption "Enable Web Browsers";

    extraChromiumExtensions = mkOption {
      type = with types;
        let
          extensionType = submodule {
            options = {
              id = mkOption {
                type = strMatching "[a-zA-Z]{32}";
                description = ''
                  The extension's ID from the Chrome Web Store url or the unpacked crx.
                '';
                default = "";
              };

              updateUrl = mkOption {
                type = str;
                description = ''
                  URL of the extension's update manifest XML file. Linux only.
                '';
                default = "https://clients2.google.com/service/update2/crx";
              };

              crxPath = mkOption {
                type = nullOr path;
                description = ''
                  Path to the extension's crx file. Linux only.
                '';
                default = null;
              };

              version = mkOption {
                type = nullOr str;
                description = ''
                  The extension's version, required for local installation. Linux only.
                '';
                default = null;
              };
            };
          };
        in listOf (coercedTo str (v: { id = v; }) extensionType);
      default = [ ];
      example = literalExpression ''
        [
          { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
          {
            id = "dcpihecpambacapedldabdbpakmachpb";
            updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
          }
          {
            id = "aaaaaaaaaabbbbbbbbbbcccccccccc";
            crxPath = "/home/share/extension.crx";
            version = "1.0";
          }
        ]
      '';
      description = ''
        List of ${name} extensions to install.
        To find the extension ID, check its URL on the
        [Chrome Web Store](https://chrome.google.com/webstore/category/extensions).

        To install extensions outside of the Chrome Web Store set
        `updateUrl` or `crxPath` and
        `version` as explained in the
        [Chrome
        documentation](https://developer.chrome.com/docs/extensions/mv2/external_extensions).
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      firefox
    ];

    programs.chromium = {
      enable = true;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }  # uBlock Origin
        { id = "oboonakemofpalcgghocfoadofidjkkk"; }  # KeePassXC-Browser
      ] ++ cfg.extraChromiumExtensions;
    };
  };
}
