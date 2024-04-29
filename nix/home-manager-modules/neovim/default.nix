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
                a = { '<Cmd>Telescope live_grep<CR>', 'Telescope Grep Search' },
                b = { '<Cmd>Telescope buffers<CR>', 'Telescope Buffer Search' },
                f = { '<Cmd>Telescope find_files<CR>', 'Telescope File Search' },
                q = { '<Cmd>Telescope command_history<CR>', 'Telescope Command History Search' },
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
                m = { '<Cmd>AsyncRun -cwd=<root> -program=make<CR>', 'Make' },
                c = { '<Cmd>AsyncStop<CR>', 'Cancel Make' }
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
                v = { '<Cmd>Flogsplit<CR>', 'Git Visualize Branch' },
                V = { '<Cmd>Flogsplit -all<CR>', 'Git Visualize All Branches' }
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
                a = { '<Cmd>Gwrite<CR>', 'Git Add File' },
                c = { '<Cmd>Gcommit<CR>', 'Git Commit' },
                p = { '<Cmd>Git add -p<CR>', 'Git Add Patch' },
                s = { '<Cmd>Git<CR>', 'Git Status' },
              }
            });
          '';
        }

        {
          plugin = neogit;
          type = "lua";
          config = ''
            --
            -- Neogit
            --

            local neogit = require("neogit")

            neogit.setup {
              disable_hint = false,
              disable_context_highlighting = false,
              disable_signs = false,
              disable_insert_on_commit = "auto",

              filewatcher = {
                interval = 1000,
                enabled = true,
              },

              graph_style = "unicode",

              git_services = {
                ["github.com"] = "https://github.com/$${owner}$${repository}/compare/$${branch_name}?expand=1",
                ["bitbucket.org"] = "https://bitbucket.org/$${owner}/$${repository}/pull-requests/new?source=$${branch_name}&t=1",
                ["gitlab.com"] = "https://gitlab.com/$${owner}/$${repository}/merge_requests/new?merge_request[source_branch]=$${branch_name}",
              },

              telescope_sorter = function()
                return require("telescope").extensions.fzf.native_fzf_sorter()
              end,

              remember_settings = true,
              use_per_project_settings = true,
              ignored_settings = {
                "NeogitPushPopup--force-with-lease",
                "NeogitPushPopup--force",
                "NeogitPullPopup--rebase",
                "NeogitCommitPopup--allow-empty",
                "NeogitRevertPopup--no-edit",
              },

              highlight = {
                italic = true,
                bold = true,
                underline = true
              },

              use_default_keymaps = true,
              auto_refresh = true,
              sort_branches = "-committerdate",
              kind = "auto",
              disable_line_numbers = true,

              console_timeout = 2000,
              auto_show_console = true,
              status = {
                recent_commit_count = 10,
              },
              commit_editor = {
                kind = "auto",
              },
              commit_select_view = {
                kind = "tab",
              },
              commit_view = {
                kind = "vsplit",
                verify_commit = os.execute("which gpg") == 0, -- Can be set to true or false, otherwise we try to find the binary
              },
              log_view = {
                kind = "tab",
              },
              rebase_editor = {
                kind = "auto",
              },
              reflog_view = {
                kind = "tab",
              },
              merge_editor = {
                kind = "auto",
              },
              tag_editor = {
                kind = "auto",
              },
              preview_buffer = {
                kind = "split",
              },
              popup = {
                kind = "split",
              },
              signs = {
                -- { CLOSED, OPENED }
                hunk = { "", "" },
                item = { ">", "v" },
                section = { ">", "v" },
              },
              integrations = {
                telescope = nil,
                diffview = nil,
                fzf_lua = nil,
              },
              sections = {
                -- Reverting/Cherry Picking
                sequencer = {
                  folded = false,
                  hidden = false,
                },
                untracked = {
                  folded = false,
                  hidden = false,
                },
                unstaged = {
                  folded = false,
                  hidden = false,
                },
                staged = {
                  folded = false,
                  hidden = false,
                },
                stashes = {
                  folded = true,
                  hidden = false,
                },
                unpulled_upstream = {
                  folded = true,
                  hidden = false,
                },
                unmerged_upstream = {
                  folded = false,
                  hidden = false,
                },
                unpulled_pushRemote = {
                  folded = true,
                  hidden = false,
                },
                unmerged_pushRemote = {
                  folded = false,
                  hidden = false,
                },
                recent = {
                  folded = true,
                  hidden = false,
                },
                rebase = {
                  folded = true,
                  hidden = false,
                },
              },
              mappings = {
                commit_editor = {
                  ["q"] = "Close",
                  ["<c-c><c-c>"] = "Submit",
                  ["<c-c><c-k>"] = "Abort",
                },
                rebase_editor = {
                  ["p"] = "Pick",
                  ["r"] = "Reword",
                  ["e"] = "Edit",
                  ["s"] = "Squash",
                  ["f"] = "Fixup",
                  ["x"] = "Execute",
                  ["d"] = "Drop",
                  ["b"] = "Break",
                  ["q"] = "Close",
                  ["<cr>"] = "OpenCommit",
                  ["gk"] = "MoveUp",
                  ["gj"] = "MoveDown",
                  ["<c-c><c-c>"] = "Submit",
                  ["<c-c><c-k>"] = "Abort",
                },
                finder = {
                  ["<cr>"] = "Select",
                  ["<c-c>"] = "Close",
                  ["<esc>"] = "Close",
                  ["<c-n>"] = "Next",
                  ["<c-p>"] = "Previous",
                  ["<down>"] = "Next",
                  ["<up>"] = "Previous",
                  ["<tab>"] = "MultiselectToggleNext",
                  ["<s-tab>"] = "MultiselectTogglePrevious",
                  ["<c-j>"] = "NOP",
                },
                popup = {
                  ["?"] = "HelpPopup",
                  ["A"] = "CherryPickPopup",
                  ["D"] = "DiffPopup",
                  ["M"] = "RemotePopup",
                  ["P"] = "PushPopup",
                  ["X"] = "ResetPopup",
                  ["Z"] = "StashPopup",
                  ["b"] = "BranchPopup",
                  ["c"] = "CommitPopup",
                  ["f"] = "FetchPopup",
                  ["l"] = "LogPopup",
                  ["m"] = "MergePopup",
                  ["p"] = "PullPopup",
                  ["r"] = "RebasePopup",
                  ["v"] = "RevertPopup",
                  ["w"] = "WorktreePopup",
                },
                status = {
                  ["q"] = "Close",
                  ["I"] = "InitRepo",
                  ["1"] = "Depth1",
                  ["2"] = "Depth2",
                  ["3"] = "Depth3",
                  ["4"] = "Depth4",
                  ["<tab>"] = "Toggle",
                  ["x"] = "Discard",
                  ["s"] = "Stage",
                  ["S"] = "StageUnstaged",
                  ["<c-s>"] = "StageAll",
                  ["u"] = "Unstage",
                  ["U"] = "UnstageStaged",
                  ["$"] = "CommandHistory",
                  ["#"] = "Console",
                  ["Y"] = "YankSelected",
                  ["<c-r>"] = "RefreshBuffer",
                  ["<enter>"] = "GoToFile",
                  ["<c-v>"] = "VSplitOpen",
                  ["<c-x>"] = "SplitOpen",
                  ["<c-t>"] = "TabOpen",
                  ["{"] = "GoToPreviousHunkHeader",
                  ["}"] = "GoToNextHunkHeader",
                },
              },
            }

            require("which-key").register({
              ['<leader>g'] = {
                name = '+git',
                n = { '<Cmd>Neogit<CR>', 'Show Neogit' },
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

            require("which-key").register({
              ['<leader>n'] = { '<Cmd>NERDTreeToggleInCurDir<CR>', 'Toggle NERDTree' },
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
          ['<F11>'] = { '<Cmd>GuiFullScreenToggle<CR>', 'Toggle Full Screen' }
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
