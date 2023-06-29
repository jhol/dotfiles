{ lib, pkgs, config, ... }:
let
  cfg = config.modules.jhol-dotfiles.shell;
in
{
  options.modules.jhol-dotfiles.shell = {
    enable = lib.mkEnableOption "Enable shell configuration";
  };

  config = lib.mkIf cfg.enable (
    let
      historySize = 10000;

      shellAliases = {
        g = "git";
        tvim = "vim -c ':term ++curwin'";
        cp = "cp --reflink=auto --sparse=always";
      };
    in
    {
      programs.bash = {
        inherit historySize shellAliases;
        enable = true;
      };

      programs.zsh = {
        inherit shellAliases;

        enable = true;

        history.size = historySize;

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
          {
            name = "powerlevel10k";
            src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
          }
        ];

        initExtra = ''
          #
          # Key Bindings
          #

          bindkey "^[[1;5D" backward-word
          bindkey "^[[1;5C" forward-word

          #
          # Powerlevel9k
          #

          source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
          source "${./p10k.zsh}"
        '';
      };

      programs.fzf = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
    }
  );
}
