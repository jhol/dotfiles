{ lib, pkgs, config, ... }:
let
  cfg = config.modules.jhol-dotfiles.shell;
in
{
  options.modules.jhol-dotfiles.shell = {
    enable = lib.mkEnableOption "Enable shell configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;

      history.size = 10000;

      localVariables = {
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=13,underline";
        ZSH_AUTOSUGGEST_STRATEGY = [ "history" "completion" ];
        KEYTIMEOUT = 1;
      };

      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      enableVteIntegration = true;
      historySubstringSearch.enable = true;

      plugins = [
        {
          name = "zsh-history-substring-search";
          file = "zsh-history-substring-search.zsh";
          src = "${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search";
        }
        {
          name = "nix-shell";
          src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
        }
      ];

      initExtra = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    };
  };
}
