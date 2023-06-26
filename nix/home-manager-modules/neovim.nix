{ lib, pkgs, config, ... }:
let
  cfg = config.modules.jhol-dotfiles.neovim;
in
{
  options.modules.jhol-dotfiles.neovim = {
    enable = lib.mkEnableOption "Enable Neovim configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      neovide
      neovim-remote
      neovim-qt
    ];

    programs.neovim = {
      enable = true;

      plugins = with pkgs.vimPlugins; [
        asyncrun-vim
        base16-vim
        bufexplorer
        fzf-vim
        lens-vim
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        vim-airline
        vim-airline-themes
        editorconfig-vim
        vim-flog
        vim-fugitive
        vim-localvimrc
        mkdir-nvim
        vim-nix
        openscad-nvim
        vim-qml
        vim-repeat
        vim-rooter
        vim-sleuth

        (pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "SmartCase";
          version = "2010-10-18";
          src = pkgs.fetchFromGitHub {
            owner = "vim-scripts";
            repo = "SmartCase";
            rev = "e8a737fae8961e45f270f255d43d16c36ac18f27";
            sha256 = "06hf56a3gyc6zawdjfvs1arl62aq5fzncl8bpwv35v66bbkjvw3w";
          };
          meta.homepage = "https://github.com/vim-scripts/SmartCase/";
        })

        (pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "errormarker.vim";
          version = "2015-01-26";
          src = pkgs.fetchFromGitHub {
            owner = "vim-scripts";
            repo = "errormarker.vim";
            rev = "eab7ae1d8961d3512703aa9eadefbde5f062a970";
            sha256 = "11fh1468fr0vrgf73hjkvvpslh2s2pmghnkq8nny38zvf6kwzhxa";
          };
          meta.homepage = "https://github.com/vim-scripts/errormarker.vim/";
        })

        (pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "vim-autosource";
          version = "2021-12-22";
          src = pkgs.fetchFromGitHub {
            owner = "jenterkin";
            repo = "vim-autosource";
            rev = "569440e157d6eb37fb098dfe95252533553a56f5";
            sha256 = "0myg0knv0ld2jdhvdz9hx9rfngh1qh6668wbmnf4g1d25vccr2i1";
          };
          meta.homepage = "https://github.com/jenterkin/vim-autosource/";
        })

        (pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "vim-cmake";
          version = "2021-06-25";
          src = pkgs.fetchFromGitHub {
            owner = "vhdirk";
            repo = "vim-cmake";
            rev = "d4a6d1836987b933b064ba8ce5f3f0040a976880";
            sha256 = "1xhak5cdnh0mg0w1hy0y4pgwaz9gcw1x1pbxidfxz0w903d0x5zw";
          };
          meta.homepage = "https://github.com/vhdirk/vim-cmake/";
        })

        (pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "vim-gas";
          version = "2022-03-07";
          src = pkgs.fetchFromGitHub {
            owner = "Shirk";
            repo = "vim-gas";
            rev = "2ca95211b465be8e2871a62ee12f16e01e64bd98";
            sha256 = "1lc75g9spww221n64pjxwmill5rw5vix21nh0lhlaq1rl2y89vd6";
          };
          meta.homepage = "https://github.com/Shirk/vim-gas/";
        })

        (pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "tinykeymap";
          version = "2019-03-15";
          src = pkgs.fetchFromGitHub {
            owner = "tomtom";
            repo = "tinykeymap_vim";
            rev = "be48fc729244f84c2d293c3db18420e7f5d74bb8";
            sha256 = "1w4zplg0mbiv9jp70cnzb1aw5xx3x8ibnm38vsapvspzy9h8ygqx";
          };
          meta.homepage = "https://github.com/tomtom/tinykeymap_vim/";
        })
      ];

      extraLuaConfig = ''
        if vim.g.neovide then
          require('neovide')
        end

        require('config')
      '';

      extraPackages = with pkgs; [
        ccls
        cmake-language-server
        neovim-remote
        nodePackages.pyright
        silver-searcher
        tree-sitter
      ];

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      defaultEditor = true;

      withNodeJs = true;
      withPython3 = true;
    };

    home.file."${config.xdg.configHome}/nvim/lua" = {
      source = ../../dotfiles/config/nvim/lua;
      recursive = true;
    };
  };
}
