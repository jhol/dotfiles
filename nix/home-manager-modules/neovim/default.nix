{ lib, pkgs, config, ... }:
let
  cfg = config.modules.jhol-dotfiles.neovim;
in
{
  options.modules.jhol-dotfiles.neovim = let
    default.font = {
      name = "SauceCodePro Nerd Font";
      size = 8;
    };
  in {
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
        type = lib.types.enum [ "antialias" "subpixelantialias" "alias" ];
        default = "subpixelantialias";
        description = lib.mdDoc ''
          The Neovide font anti-aliasing method.
        '';
      };

      fontHinting = lib.mkOption {
        type = lib.types.enum [ "full" "normal" "slight" "none" ];
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
        bufexplorer
        editorconfig-vim
        vim-flog
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
          plugin = fzf-vim;
          type = "lua";
          config = ''
            --
            -- fzf
            --

            vim.api.nvim_set_keymap('n', '<leader>ff', '<Cmd>Files<CR>', { noremap = false })
            vim.api.nvim_set_keymap('n', '<leader>fg', '<Cmd>GFiles<CR>', { noremap = false })
            vim.api.nvim_set_keymap('n', '<leader>fs', '<Cmd>GFiles?<CR>', { noremap = false })
            vim.api.nvim_set_keymap('n', '<leader>fb', '<Cmd>Buffers<CR>', { noremap = false })
            vim.api.nvim_set_keymap('n', '<leader>fl', '<Cmd>BLines<CR>', { noremap = false })
            vim.api.nvim_set_keymap('n', '<leader>fL', '<Cmd>Lines<CR>', { noremap = false })
            vim.api.nvim_set_keymap('n', '<leader>fa', '<Cmd>Ag<CR>', { noremap = false })

            -- Update which-key
            local wk = require("which-key")

            wk.register({
              ['<leader>f'] = {
                name = '+fzf',
                f = { '<Cmd>Files<CR>', 'FZF File Search' },
                g = { '<Cmd>GFiles<CR>', 'FZF Git File Search' },
                s = { '<Cmd>GFiles?<CR>', 'FZF Git Status Search' },
                b = { '<Cmd>Buffers<CR>', 'FZF Buffer Search' },
                l = { '<Cmd>BLines<CR>', 'FZF Buffer Search' },
                L = { '<Cmd>Lines<CR>', 'FZF All Buffers Search' },
                f = { '<Cmd>Ag<CR>', 'FZF Silver Searcher Ag Search' }
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

            vim.api.nvim_set_keymap("n", "<leader>mm", "<Cmd>AsyncRun -cwd=<root> -program=make<CR>", { noremap = false })
            vim.api.nvim_set_keymap("n", "<leader>mc", "<Cmd>AsyncStop<CR>", { noremap = false })

            -- Update which-key
            local wk = require("which-key")

            wk.register({
              ['<leader>m'] = {
                name = '+make',
                m = { '<Cmd>AsyncRun -cwd=<root> -program=make<CR>', 'Make' },
                c = { '<Cmd>AsyncStop<CR>', 'Cancel Make' }
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

            vim.api.nvim_set_keymap('n', '<leader>ga', '<Cmd>Gwrite<CR>', { noremap = false })
            vim.api.nvim_set_keymap('n', '<leader>gc', '<Cmd>Gcommit<CR>', { noremap = false })
            vim.api.nvim_set_keymap('n', '<leader>gs', '<Cmd>Git<CR>', { noremap = false })
            vim.api.nvim_set_keymap('n', '<leader>gv', '<Cmd>Flogsplit<CR>', { noremap = false })
            vim.api.nvim_set_keymap('n', '<leader>gV', '<Cmd>Flogsplit -all<CR>', { noremap = false })

            -- Update which-key
            local wk = require("which-key")

            wk.register({
              ['<leader>g'] = {
                name = '+git',
                a = { '<Cmd>Gwrite<CR>', 'Git Add File' },
                c = { '<Cmd>Gcommit<CR>', 'Git Commit' },
                s = { '<Cmd>Git<CR>', 'Git Status' },
                v = { '<Cmd>Flogsplit<CR>', 'Git Visualize Branch' },
                V = { '<Cmd>Flogsplit -all<CR>', 'Git Visualize All Branches' }
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
          plugin = (pkgs.vimUtils.buildVimPluginFrom2Nix {
            pname = "vim-cmake";
            version = "2021-06-25";
            src = pkgs.fetchFromGitHub {
              owner = "vhdirk";
              repo = "vim-cmake";
              rev = "d4a6d1836987b933b064ba8ce5f3f0040a976880";
              sha256 = "1xhak5cdnh0mg0w1hy0y4pgwaz9gcw1x1pbxidfxz0w903d0x5zw";
            };
            meta.homepage = "https://github.com/vhdirk/vim-cmake/";
          });
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
          plugin = pkgs.vimUtils.buildVimPluginFrom2Nix {
            pname = "which-key.nvim";
            version = "2023-06-19";
            src = pkgs.fetchFromGitHub {
              owner = "folke";
              repo = "which-key.nvim";
              rev = "d871f2b664afd5aed3dc1d1573bef2fb24ce0484";
              sha256 = "00078wm0j2d2yzfqr1lvc7iawkzznbfzf7gq3c0g497pzhvhgl2q";
            };
            meta.homepage = "https://github.com/folke/which-key.nvim/";
          };
          type = "lua";
          config = ''
            vim.api.nvim_set_option("timeoutlen", 300)
            require("which-key").setup({})
          '';
        }

        {
          plugin = nvim-base16;
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

        nvim-web-devicons

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
            vim.api.nvim_set_keymap('n', '<space>e', '<Cmd>lua vim.diagnostic.open_float()<CR>', opts)
            vim.api.nvim_set_keymap('n', '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
            vim.api.nvim_set_keymap('n', ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', opts)
            vim.api.nvim_set_keymap('n', '<space>q', '<Cmd>lua vim.diagnostic.setloclist()<CR>', opts)

            lsp_on_attach = function(client, bufnr)
              -- Enable completion triggered by <c-x><c-o>
              vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

              -- Mappings.
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<Cmd>lua vim.lsp.buf.format()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)

              -- Use LSP as the handler for omnifunc
              vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

              -- Update which-key
              local wk = require("which-key")

              wk.register({
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
            local wk = require("which-key")

            wk.register({
              ['<space>e'] = { vim.diagnostic.open_float, 'Buffer Diagnostics' },
              ['[d'] = { vim.diagnostic.goto_prev, 'Previous Diagnostic' },
              [']d'] = { vim.diagnostic.goto_next, 'Next Diagnostic' },
              ['<space>q'] = { vim.diagnostic.setloclist, 'Add Buffer Diagnostics to Location List' }
            })
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

        vim.api.nvim_set_keymap('n', '<F11>', '<Cmd>GuiFullScreenToggle<CR>', { noremap = false })

        -- Update which-key
        local wk = require("which-key")

        wk.register({
          ['<F11>'] = { '<Cmd>GuiFullScreenToggle<CR>', 'Toggle Full Screen' }
        })

        --
        -- Main Configuration
        --

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
      source = ./lua;
      recursive = true;
    };
  };
}
