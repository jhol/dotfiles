{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.jhol-dotfiles.neovim;
in
{
  options.modules.jhol-dotfiles.neovim =
    let
      default.font = {
        name = "SauceCodePro Nerd Font";
        size = 7.5;
      };
    in
    {
      enable = lib.mkEnableOption "Enable Neovim configuration";

      neovide = {
        fontName = lib.mkOption {
          type = lib.types.str;
          default = default.font.name;
          description = lib.mdDoc ''
            The Neovide font face name.
          '';
        };

        fontSize = lib.mkOption {
          type = lib.types.either lib.types.float lib.types.ints.positive;
          default = default.font.size;
          description = lib.mdDoc ''
            The Neovide font face size.
          '';
        };

        fontAntiAliasing = lib.mkOption {
          type = lib.types.enum [
            "antialias"
            "subpixelantialias"
            "alias"
          ];
          default = "subpixelantialias";
          description = lib.mdDoc ''
            The Neovide font anti-aliasing method.
          '';
        };

        fontHinting = lib.mkOption {
          type = lib.types.enum [
            "full"
            "normal"
            "slight"
            "none"
          ];
          default = "none";
          description = lib.mdDoc ''
            The Neovide font hinting.
          '';
        };
      };

      neovim-qt = {
        fontName = lib.mkOption {
          type = lib.types.str;
          default = default.font.name;
          description = lib.mdDoc ''
            The Neovim-Qt font face name.
          '';
        };

        fontSize = lib.mkOption {
          type = lib.types.either lib.types.float lib.types.ints.positive;
          default = default.font.size;
          description = lib.mdDoc ''
            The Neovim-Qt font face size.
          '';
        };
      };
    };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      neovide
      neovim-remote
      (neovim-qt.override { neovim = config.programs.neovim.finalPackage; })
    ];

    programs.neovim = {
      enable = true;

      plugins =
        let
          bufselect = pkgs.vimUtils.buildVimPlugin (
            let
              name = "bufselect";
            in
            {
              inherit name;
              src = pkgs.fetchFromGitHub {
                owner = "PhilRunninger";
                repo = name;
                rev = "b5110f0ad8f6e5679697eec1bebe7a205243686f";
                hash = "sha256-AVS6IoV4aPEyn9wGDAc40p1mlddCQGLwMeHNUotJFK4=";
              };
              meta.homepage = "https://github.com/PhilRunninger/bufselect";
            }
          );
        in
        with pkgs.vimPlugins;
        [
          SmartCase
          editorconfig-vim
          errormarker-vim
          mini-icons
          mkdir-nvim
          nvim-web-devicons
          openscad-nvim
          vim-autosource
          vim-devicons
          vim-gas
          vim-nix
          vim-qml
          vim-repeat
          vim-sleuth

          {
            plugin = bufselect;
            type = "lua";
            config = ''
              --
              -- BufSelect
              --

              vim.api.nvim_set_keymap('n', '<leader>bs', ':ShowBufferList<CR>', { noremap=true, silent=true })

              require("which-key").add({
                { '<leader>bs', desc = 'Show buffer list' }
              });
            '';
          }

          {
            plugin = vim-localvimrc;
            type = "lua";
            config = ''
              --
              -- localvimrc
              --

              vim.g.localvimrc_persistent = 1
              vim.g.localvimrc_sandbox = 0
            '';
          }

          {
            plugin = telescope-nvim;
            type = "lua";
            config = ''
              --
              -- telescope.nvim
              --

              require("which-key").add({
                { '<leader>f', group = 'telescope' },
                { '<leader>fa', '<cmd>Telescope live_grep<cr>', desc = 'Telescope Grep Search' },
                { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Telescope Buffer Search' },
                { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Telescope File Search' },
                { '<leader>fq', '<cmd>Telescope command_history<cr>', desc = 'Telescope Command History Search' }
              });
            '';
          }

          {
            plugin = asyncrun-vim;
            type = "lua";
            config = ''
              --
              -- AsyncRun
              --

              vim.g.asyncrun_auto = "make"
              vim.g.asyncrun_open = 10
              vim.g.asyncrun_rootmarks = {"build", "_build", ".git"}
              vim.g.asyncrun_status = ""

              require("which-key").add({
                { '<leader>m', group = 'make' },
                { '<leader>mm', '<cmd>AsyncRun -cwd=<root> -program=make<cr>', desc = 'Make' },
                { '<leader>mc', '<cmd>AsyncStop<cr>', desc = 'Cancel Make' }
              });
            '';
          }

          {
            plugin = vim-fugitive;
            type = "lua";
            config = ''
              --
              -- vim-fugitive
              --

              require("which-key").add({
                { '<leader>g', group = 'git' },
                { '<leader>ga', '<cmd>Gwrite<cr>', desc = 'Git Add File' },
                { '<leader>gc', '<cmd>Git commit<cr>', desc = 'Git Commit' },
                { '<leader>gd', '<cmd>Git diff<cr>', desc = 'Git Diff' },
                { '<leader>gg', '<cmd>Git config set commit.gpgsign false<cr>', desc = 'Disable GPG signing' },
                { '<leader>gG', '<cmd>Git config unset commit.gpgsign<cr>', desc = 'Restore GPG signing' },
                { '<leader>gl', '<cmd>Git log --decorate<cr>', desc = 'Git Log' },
                { '<leader>gp', '<cmd>Git add -p<cr>', desc = 'Git Add Patch' },
                { '<leader>gs', '<cmd>Git<cr>', desc = 'Git Status' },

                { '<leader>gr', group = 'git rebase' },
                { '<leader>gra', '<cmd>Git rebase --abort<cr>', desc = 'Git Rebase Abort' },
                { '<leader>grc', '<cmd>Git rebase --continue<cr>', desc = 'Git Rebase Continue' }
              });
            '';
          }

          {
            plugin = vim-flog;
            type = "lua";
            config = ''
              require("which-key").add({
                { '<leader>gv', '<cmd>Flogsplit<cr>', desc = 'Git Visualize Branch' },
                { '<leader>gV', '<cmd>Flogsplit -all<cr>', desc = 'Git Visualize All Branches' }
              });
            '';
          }

          {
            plugin = lens-vim;
            type = "lua";
            config = ''
              --
              -- lens.vim
              --

              vim.g['lens#width_resize_min'] = 20
              vim.g['lens#width_resize_max'] = 128
            '';
          }

          {
            plugin = vim-cmake;
            type = "lua";
            config = ''
              --
              -- vim-cmake
              --

              vim.g.cmake_export_compile_commands = true
              vim.g.cmake_ycm_symlinks = true
            '';
          }

          {
            plugin = which-key-nvim;
            type = "lua";
            config = ''
              vim.api.nvim_set_option("timeoutlen", 300)
              require("which-key").setup({})
            '';
          }

          {
            plugin = base16-nvim;
            type = "lua";
            config = ''
              --
              -- Colour Scheme
              --

              require('base16-colorscheme').setup({
                  base00 = '#000000', base01 = '#282828', base02 = '#383838', base03 = '#585858',
                  base04 = '#b8b8b8', base05 = '#d8d8d8', base06 = '#e8e8e8', base07 = '#f8f8f8',
                  base08 = '#ab4642', base09 = '#dc9656', base0A = '#f7ca88', base0B = '#a1b56c',
                  base0C = '#86c1b9', base0D = '#7cafc2', base0E = '#ba8baf', base0F = '#a16946'
                })

              vim.api.nvim_set_hl(0, 'LineNrAbove', { fg='#585858', bold = false })
              vim.api.nvim_set_hl(0, 'LineNr', { fg='#585858', bold = true })
              vim.api.nvim_set_hl(0, 'LineNrBelow', { fg='#585858', bold = false })

              vim.o.termguicolors = (not vim.env.TMUX and vim.fn.has('termguicolors') == 1)

              vim.g.terminal_color_0  = '#2e3436'
              vim.g.terminal_color_1  = '#cc0000'
              vim.g.terminal_color_2  = '#4e9a06'
              vim.g.terminal_color_3  = '#c4a000'
              vim.g.terminal_color_4  = '#3465a4'
              vim.g.terminal_color_5  = '#75507b'
              vim.g.terminal_color_6  = '#0b939b'
              vim.g.terminal_color_7  = '#d3d7cf'
              vim.g.terminal_color_8  = '#555753'
              vim.g.terminal_color_9  = '#ef2929'
              vim.g.terminal_color_10 = '#8ae234'
              vim.g.terminal_color_11 = '#fce94f'
              vim.g.terminal_color_12 = '#729fcf'
              vim.g.terminal_color_13 = '#ad7fa8'
              vim.g.terminal_color_14 = '#00f5e9'
              vim.g.terminal_color_15 = '#eeeeec'
            '';
          }

          {
            plugin = lualine-nvim;
            type = "lua";
            config = ''
              require('lualine').setup {
                options = {
                  icons_enabled = true,
                  theme = 'base16',
                  component_separators = { left = '', right = ''},
                  section_separators = { left = '', right = ''},
                  disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                  },
                  ignore_focus = {},
                  always_divide_middle = true,
                  globalstatus = false,
                  refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                  }
                },
                sections = {
                  lualine_a = {'mode'},
                  lualine_b = {'branch', 'diff', 'diagnostics'},
                  lualine_c = {'filename'},
                  lualine_x = {'encoding', 'fileformat', 'filetype'},
                  lualine_y = {'progress'},
                  lualine_z = {'location'}
                },
                inactive_sections = {
                  lualine_a = {},
                  lualine_b = {},
                  lualine_c = {'filename'},
                  lualine_x = {'location'},
                  lualine_y = {},
                  lualine_z = {}
                },
                tabline = {},
                winbar = {},
                inactive_winbar = {},
                extensions = {}
              }
            '';
          }

          {
            plugin = nvim-treesitter.withAllGrammars;
            type = "lua";
            config = ''
              --
              -- Tree Sitter
              --

              require 'nvim-treesitter.configs'.setup {
                highlight = {
                  enable = true,
                  additional_vim_regex_highlighting = false
                }
              }

              vim.api.nvim_command("highlight Error guibg=#572321")
            '';
          }

          {
            plugin = nvim-treesitter-textobjects;
            type = "lua";
            config = ''
              --
              -- Tree Sitter Text Objects
              --

              require 'nvim-treesitter.configs'.setup {
                textobjects = {
                  swap = {
                    enable = true,
                    swap_next = {
                      ["g>"] = "@parameter.inner",
                    },
                    swap_previous = {
                      ["g<"] = "@parameter.inner",
                    },
                  },
                },
              }

              require("which-key").add({
                { 'g>', desc = 'Swap Next' },
                { 'g<', desc = 'Swap Previous' }
              })
            '';
          }

          {
            plugin = nvim-lspconfig;
            type = "lua";
            config = ''
              --
              -- LSP
              --

              local opts = { noremap=true, silent=true }
              vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
              vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
              vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
              vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<cr>', opts)

              lsp_on_attach = function(client, bufnr)
                -- Enable completion triggered by <c-x><c-o>
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                -- Mappings.
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.format()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)

                -- Use LSP as the handler for omnifunc
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                -- Update which-key
                require("which-key").add({
                  { '<C-k>', vim.lsp.buf.signature_help, desc = "LSP Signature Help" },
                  { '<space>D', vim.lsp.buf.type_definition, desc = "LSP Type Definitions" },
                  { '<space>ca', vim.lsp.buf.code_action, desc = "LSP Code Action" },
                  { '<space>f', vim.lsp.buf.format, desc = "LSP Formatting" },
                  { '<space>rn', vim.lsp.buf.rename, desc = "LSP Rename" },
                  { '<space>wa', vim.lsp.buf.add_workspace_folder, desc = "LSP Add Workspace Folder" },
                  { '<space>wl', vim.lsp.buf.list_workspace_folders, desc = "LSP List Workspace Folders" },
                  { 'K', vim.lsp.buf.hover, desc = "LSP Hover" },
                  { 'gD', vim.lsp.buf.declaration, desc = "LSP Declaration" },
                  { 'gd', vim.lsp.buf.definition, desc = "LSP Definition" },
                  { 'gi', vim.lsp.buf.implementation, desc = "LSP Implementation" },
                  { 'gr', vim.lsp.buf.references, desc = "LSP References" }
                });

              end

              local servers = {
                'cmake',
                'pyright'
              }

              for _, lsp in pairs(servers) do
                require('lspconfig')[lsp].setup {
                  on_attach = lsp_on_attach,
                  flags = {
                    -- This will be the default in neovim 0.7+
                    debounce_text_changes = 150,
                  }
                }
              end

              -- Update which-key
              require("which-key").add({
                { '<space>e', vim.diagnostic.open_float, desc = 'Buffer Diagnostics' },
                { '[d', vim.diagnostic.goto_prev, desc = 'Previous Diagnostic' },
                { ']d', vim.diagnostic.goto_next, desc = 'Next Diagnostic' },
                { '<space>q', vim.diagnostic.setloclist, desc = 'Add Buffer Diagnostics to Location List' }
              })
            '';
          }

          {
            plugin = nerdtree;
            type = "lua";
            config = ''
              -- Define NERDTreeToggleInCurDir command
              vim.api.nvim_exec(
              [[

              function! s:NERDTreeToggleInCurDir()
                " If NERDTree is open in the current buffer
                if (exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1)
                  exe ":NERDTreeClose"
                else
                  if (expand("%:t") != "")
                    exe ":NERDTreeFind"
                  else
                    exe ":NERDTreeToggle"
                  endif
                endif
              endfunction

              command! NERDTreeToggleInCurDir call s:NERDTreeToggleInCurDir()

              ]], true)

              -- Close after opening a file or bookmark
              vim.g.NERDTreeQuitOnOpen = 3

              -- Redefine :Ex
              vim.cmd('command! Ex NERDTreeToggleInCurDir')

              require("which-key").add({
                { '<leader>n', '<cmd>NERDTreeToggleInCurDir<cr>', desc = 'Toggle NERDTree' }
              })
            '';
          }

          {
            plugin = vim-rooter;
            type = "lua";
            config = ''
              --
              -- vim-rooter
              --

              vim.g.rooter_patterns = {'.git'};
            '';
          }
        ];

      extraLuaConfig = ''
        --
        -- GUI Configuration
        --

        -- Font
        if (vim.fn.exists('GuiFont') == 1) then
          vim.cmd('GuiFont', '${cfg.neovim-qt.fontName}:h${builtins.toString cfg.neovim-qt.fontSize}')
        end

        -- Disable the GUI tab-line
        vim.rpcnotify(0, 'Gui', 'Option', 'Tabline', 0)

        -- Neovide Configuration
        if vim.g.neovide then
          -- Font
          vim.o.guifont = '${cfg.neovide.fontName}:h${builtins.toString cfg.neovide.fontSize}:#e-${cfg.neovide.fontAntiAliasing}:#h-${cfg.neovide.fontHinting}';

          -- Animation
          vim.g.neovide_refresh_rate = 60;
          vim.g.neovide_cursor_animation_length = 0.01;

          -- Misc
          vim.g.neovide_hide_mouse_when_typing = true;
        end

        -- Full Screen Toggle
        if vim.g.neovide then
          vim.api.nvim_exec(
          [[

          function! s:GuiFullScreenToggle()
            let g:neovide_fullscreen=!g:neovide_fullscreen
          endfunction

          command! GuiFullScreenToggle call s:GuiFullScreenToggle()

          ]], true)

        else
          vim.api.nvim_exec(
          [[

          let g:GuiWindowFullScreen = 0

          function! s:GuiFullScreenToggle()
            if g:GuiWindowFullScreen == 0
              call rpcnotify(0, 'Gui', 'WindowFullScreen', 1)
            else
              call rpcnotify(0, 'Gui', 'WindowFullScreen', 0)
            endif
          endfunction

          command! GuiFullScreenToggle call s:GuiFullScreenToggle()

          ]], true)

        end

        -- Update which-key
        require("which-key").add({
          { "<F11>", "<cmd>GuiFullScreenToggle<cr>", desc = "Toggle Full Screen" }
        })

        --
        -- Main Configuration
        --

        require('config')
      '';

      extraPackages = with pkgs; [
        fd
        ccls
        cmake-language-server
        neovim-remote
        pyright
        ripgrep
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
      source = ./lua;
      recursive = true;
    };
  };
}
