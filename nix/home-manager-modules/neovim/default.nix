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
        size = 8;
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
          type = lib.types.ints.positive;
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

      plugins = with pkgs.vimPlugins; [
        SmartCase
        bufexplorer
        editorconfig-vim
        errormarker-vim
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

            require("which-key").register({
              ['<leader>f'] = {
                name = '+telescope',
                a = { '<cmd>Telescope live_grep<cr>', 'Telescope Grep Search' },
                b = { '<cmd>Telescope buffers<cr>', 'Telescope Buffer Search' },
                f = { '<cmd>Telescope find_files<cr>', 'Telescope File Search' },
                q = { '<cmd>Telescope command_history<cr>', 'Telescope Command History Search' },
              }
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

            require("which-key").register({
              ['<leader>m'] = {
                name = '+make',
                m = { '<cmd>AsyncRun -cwd=<root> -program=make<cr>', 'Make' },
                c = { '<cmd>AsyncStop<cr>', 'Cancel Make' }
              }
            });
          '';
        }

        {
          plugin = vim-flog;
          type = "lua";
          config = ''
            require("which-key").register({
              ['<leader>g'] = {
                name = '+git',
                v = { '<cmd>Flogsplit<cr>', 'Git Visualize Branch' },
                V = { '<cmd>Flogsplit -all<cr>', 'Git Visualize All Branches' }
              }
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

            require("which-key").register({
              ['<leader>g'] = {
                name = '+git',
                a = { '<cmd>Gwrite<cr>', 'Git Add File' },
                c = { '<cmd>Gcommit<cr>', 'Git Commit' },
                p = { '<cmd>Git add -p<cr>', 'Git Add Patch' },
                s = { '<cmd>Git<cr>', 'Git Status' },
              }
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
              require("which-key").register({
                ['<C-k>'] = { vim.lsp.buf.signature_help, "LSP Signature Help" },
                ['<space>'] = {
                  D = { vim.lsp.buf.type_definition, "LSP Type Definitions" },
                  ["ca"] = { vim.lsp.buf.code_action, "LSP Code Action" },
                  f = { vim.lsp.buf.format, "LSP Formatting" },
                  ["rn"] = { vim.lsp.buf.rename, "LSP Rename" },
                  w = {
                    a = { vim.lsp.buf.add_workspace_folder, "LSP Add Workspace Folder" },
                    l = { vim.lsp.buf.list_workspace_folders, "LSP List Workspace Folders" }
                  },
                },
                K = { vim.lsp.buf.hover, "LSP Hover" },
                g = {
                  D = { vim.lsp.buf.declaration, "LSP Declaration" },
                  d = { vim.lsp.buf.definition, "LSP Definition" },
                  i = { vim.lsp.buf.implementation, "LSP Implementation" },
                  r = { vim.lsp.buf.references, "LSP References" }
                }
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
            require("which-key").register({
              ['<space>e'] = { vim.diagnostic.open_float, 'Buffer Diagnostics' },
              ['[d'] = { vim.diagnostic.goto_prev, 'Previous Diagnostic' },
              [']d'] = { vim.diagnostic.goto_next, 'Next Diagnostic' },
              ['<space>q'] = { vim.diagnostic.setloclist, 'Add Buffer Diagnostics to Location List' }
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
                exe "<cmd>NERDTreeClose"
              else
                if (expand("%:t") != "")
                  exe "<cmd>NERDTreeFind"
                else
                  exe "<cmd>NERDTreeToggle"
                endif
              endif
            endfunction

            command! NERDTreeToggleInCurDir call s:NERDTreeToggleInCurDir()

            ]], true)

            -- Close after opening a file or bookmark
            vim.g.NERDTreeQuitOnOpen = 3

            -- Redefine :Ex
            vim.cmd('command! Ex NERDTreeToggleInCurDir')

            require("which-key").register({
              ['<leader>n'] = { '<cmd>NERDTreeToggleInCurDir<cr>', 'Toggle NERDTree' },
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
        require("which-key").register({
          ['<F11>'] = { '<cmd>GuiFullScreenToggle<cr>', 'Toggle Full Screen' }
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
        nodePackages.pyright
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
