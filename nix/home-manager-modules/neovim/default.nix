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
      (neovim-qt.override { neovim = config.programs.nixvim.build.package; })
    ];

    programs.nixvim = {
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      defaultEditor = true;

      opts = {
        cmdheight = 1;
        hidden = true;
        backup = false;
        writebackup = false;
        signcolumn = "yes";
        updatetime = 300;
        undofile = true;
        colorcolumn = "120";
        mouse = "a";
        foldmethod = "indent";
        foldnestmax = 10;
        foldenable = false;
        foldlevel = 2;
        shell = "zsh";
        timeoutlen = 300;
        number = true;
        relativenumber = true;
      };

      globals = {
        # Disable netrw (nvim-tree takes over)
        loaded_netrw = 1;
        loaded_netrwPlugin = 1;

        # AsyncRun
        asyncrun_auto = "make";
        asyncrun_open = 10;
        asyncrun_rootmarks = [
          "build"
          "_build"
          ".git"
        ];
        asyncrun_status = "";

        # localvimrc
        localvimrc_persistent = 1;
        localvimrc_sandbox = 0;



      };

      keymaps = [
        # Disable Help
        { mode = ""; key = "<F1>"; action = ""; options.noremap = true; }

        # Disable XON/XOFF
        { mode = ""; key = "<C-q>"; action = ""; options.noremap = true; }
        { mode = ""; key = "<C-s>"; action = ""; options.noremap = true; }

        # Clear search highlight
        { mode = "n"; key = "z/"; action = "<cmd>nohlsearch<cr>"; options.desc = "Clear search highlight"; }

        # Buffer management
        { mode = "n"; key = "<leader>bd"; action = "<cmd>bp|bd #<cr>"; options.desc = "Close buffer, keep split"; }
        { mode = "n"; key = "<leader>bh"; action = "<cmd>Bdelete hidden<cr>"; options.desc = "Close hidden buffers"; }
        { mode = "n"; key = "<leader>bn"; action = "<cmd>Bdelete nameless<cr>"; options.desc = "Close nameless buffers"; }

        # Quickfix
        { mode = "n"; key = "<leader>qo"; action = "<cmd>copen<cr>"; options.desc = "Open quickfix list"; }
        { mode = "n"; key = "<leader>qc"; action = "<cmd>cclose<cr>"; options.desc = "Close quickfix list"; }

        # Terminal escape
        { mode = "t"; key = "<C-Space>"; action = "<C-\\><C-n>"; options.desc = "Exit terminal mode"; }

        # Window navigation
        { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Go to the left window"; }
        { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Go to the down window"; }
        { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Go to the up window"; }
        { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Go to the right window"; }

        # Window resizing
        { mode = "n"; key = "<A-h>"; action = "<C-w><"; options.desc = "Decrease width"; }
        { mode = "n"; key = "<A-j>"; action = "<C-w>+"; options.desc = "Increase height"; }
        { mode = "n"; key = "<A-k>"; action = "<C-w>-"; options.desc = "Decrease height"; }
        { mode = "n"; key = "<A-l>"; action = "<C-w>>"; options.desc = "Increase width"; }
        { mode = "n"; key = "<A-w>"; action = "<C-w>w"; options.desc = "Switch windows"; }

        # Focus command
        { mode = "n"; key = "<leader>F"; action = "<cmd>Focus<cr>"; options.desc = "Focus (close side panels)"; }

        # Full screen toggle
        { mode = "n"; key = "<F11>"; action = "<cmd>GuiFullScreenToggle<cr>"; options.desc = "Toggle Full Screen"; }

        # Diagnostics
        { mode = "n"; key = "<space>e"; action = "<cmd>lua vim.diagnostic.open_float()<cr>"; options = { silent = true; desc = "Buffer Diagnostics"; }; }
        { mode = "n"; key = "[d"; action = "<cmd>lua vim.diagnostic.jump({count=-1, float=true})<cr>"; options = { silent = true; desc = "Previous Diagnostic"; }; }
        { mode = "n"; key = "]d"; action = "<cmd>lua vim.diagnostic.jump({count=1, float=true})<cr>"; options = { silent = true; desc = "Next Diagnostic"; }; }
        { mode = "n"; key = "<space>q"; action = "<cmd>lua vim.diagnostic.setloclist()<cr>"; options = { silent = true; desc = "Diagnostics to Location List"; }; }

        # AsyncRun (generic make)
        { mode = "n"; key = "<leader>mm"; action = "<cmd>AsyncRun -cwd=<root> -program=make<cr>"; options.desc = "Make"; }
        { mode = "n"; key = "<leader>mc"; action = "<cmd>AsyncStop<cr>"; options.desc = "Cancel Make"; }

        # Fugitive
        { mode = "n"; key = "<leader>ga"; action = "<cmd>Gwrite<cr>"; options.desc = "Git Add File"; }
        { mode = "n"; key = "<leader>gc"; action = "<cmd>Git commit<cr>"; options.desc = "Git Commit"; }
        { mode = "n"; key = "<leader>gd"; action = "<cmd>Git diff<cr>"; options.desc = "Git Diff"; }
        { mode = "n"; key = "<leader>gg"; action = "<cmd>Git config set commit.gpgsign false<cr>"; options.desc = "Disable GPG signing"; }
        { mode = "n"; key = "<leader>gG"; action = "<cmd>Git config unset commit.gpgsign<cr>"; options.desc = "Restore GPG signing"; }
        { mode = "n"; key = "<leader>gl"; action = "<cmd>Git log --decorate<cr>"; options.desc = "Git Log"; }
        { mode = "n"; key = "<leader>gp"; action = "<cmd>Git add -p<cr>"; options.desc = "Git Add Patch"; }
        { mode = "n"; key = "<leader>gs"; action = "<cmd>Git<cr>"; options.desc = "Git Status"; }
        { mode = "n"; key = "<leader>gra"; action = "<cmd>Git rebase --abort<cr>"; options.desc = "Git Rebase Abort"; }
        { mode = "n"; key = "<leader>grc"; action = "<cmd>Git rebase --continue<cr>"; options.desc = "Git Rebase Continue"; }

        # Flog
        { mode = "n"; key = "<leader>gv"; action = "<cmd>Flogsplit<cr>"; options.desc = "Git Visualize Branch"; }
        { mode = "n"; key = "<leader>gV"; action = "<cmd>Flogsplit -all<cr>"; options.desc = "Git Visualize All Branches"; }

        # NvimTree
        { mode = "n"; key = "<leader>n"; action = "<cmd>NvimTreeFindFileToggle<cr>"; options.desc = "Toggle NvimTree"; }

        # Undotree
        { mode = "n"; key = "<leader>u"; action = "<cmd>UndotreeToggle<cr>"; options.desc = "Toggle undotree"; }

        # Treesitter text objects (swap)
        { mode = "n"; key = "g>"; action.__raw = "function() require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner') end"; options.desc = "Swap Next"; }
        { mode = "n"; key = "g<"; action.__raw = "function() require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner') end"; options.desc = "Swap Previous"; }

        # CMake
        { mode = "n"; key = "<leader>cg"; action = "<cmd>CMakeGenerate<cr>"; options.desc = "CMake Generate"; }
        { mode = "n"; key = "<leader>cm"; action = "<cmd>CMakeBuild<cr>"; options.desc = "CMake Build"; }
        { mode = "n"; key = "<leader>cr"; action = "<cmd>CMakeRun<cr>"; options.desc = "CMake Run"; }
        { mode = "n"; key = "<leader>cd"; action = "<cmd>CMakeDebug<cr>"; options.desc = "CMake Debug"; }
        { mode = "n"; key = "<leader>cc"; action = "<cmd>CMakeStopExecutor<cr>"; options.desc = "CMake Cancel"; }
        { mode = "n"; key = "<leader>ct"; action = "<cmd>CMakeSelectBuildTarget<cr>"; options.desc = "Select Build Target"; }
        { mode = "n"; key = "<leader>cl"; action = "<cmd>CMakeSelectLaunchTarget<cr>"; options.desc = "Select Launch Target"; }
        { mode = "n"; key = "<leader>cb"; action = "<cmd>CMakeSelectBuildType<cr>"; options.desc = "Select Build Type"; }
      ];

      colorschemes.base16 = {
        enable = true;
        colorscheme = {
          base00 = "#000000";
          base01 = "#282828";
          base02 = "#383838";
          base03 = "#585858";
          base04 = "#b8b8b8";
          base05 = "#d8d8d8";
          base06 = "#e8e8e8";
          base07 = "#f8f8f8";
          base08 = "#ab4642";
          base09 = "#dc9656";
          base0A = "#f7ca88";
          base0B = "#a1b56c";
          base0C = "#86c1b9";
          base0D = "#7cafc2";
          base0E = "#ba8baf";
          base0F = "#a16946";
        };
      };

      highlightOverride = {
        LineNrAbove = { fg = "#585858"; bold = false; };
        LineNr = { fg = "#585858"; bold = true; };
        LineNrBelow = { fg = "#585858"; bold = false; };
        Error = { bg = "#572321"; };
        ColorColumn = { bg = "#282828"; };
      };

      plugins.telescope = {
        enable = true;
        keymaps = {
          "<leader>fa" = { action = "live_grep"; options.desc = "Telescope Grep Search"; };
          "<leader>fb" = { action = "buffers"; options.desc = "Telescope Buffer Search"; };
          "<leader>ff" = { action = "find_files"; options.desc = "Telescope File Search"; };
          "<leader>fq" = { action = "command_history"; options.desc = "Telescope Command History"; };
        };
      };

      plugins.treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };

      plugins.treesitter-textobjects = {
        enable = true;
      };

      plugins.lsp = {
        enable = true;
        servers = {
          cmake.enable = true;
          pyright.enable = true;
        };
        keymaps = {
          silent = true;
          lspBuf = {
            K = { action = "hover"; desc = "LSP Hover"; };
            gd = { action = "definition"; desc = "LSP Definition"; };
            gD = { action = "declaration"; desc = "LSP Declaration"; };
            gi = { action = "implementation"; desc = "LSP Implementation"; };
            gr = { action = "references"; desc = "LSP References"; };
            "<C-k>" = { action = "signature_help"; desc = "LSP Signature Help"; };
            "<space>D" = { action = "type_definition"; desc = "LSP Type Definition"; };
            "<space>ca" = { action = "code_action"; desc = "LSP Code Action"; };
            "<space>f" = { action = "format"; desc = "LSP Format"; };
            "<space>rn" = { action = "rename"; desc = "LSP Rename"; };
            "<space>wa" = { action = "add_workspace_folder"; desc = "LSP Add Workspace Folder"; };
            "<space>wr" = { action = "remove_workspace_folder"; desc = "LSP Remove Workspace Folder"; };
          };
        };
        onAttach = ''
          vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = bufnr })
        '';
      };

      plugins.lualine = {
        enable = true;
        settings = {
          options = {
            icons_enabled = true;
            theme = "base16";
            component_separators = { left = ""; right = ""; };
            section_separators = { left = ""; right = ""; };
            globalstatus = false;
          };
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [ "branch" "diff" "diagnostics" ];
            lualine_c = [ "filename" ];
            lualine_x = [ "encoding" "fileformat" "filetype" ];
            lualine_y = [ "progress" ];
            lualine_z = [ "location" ];
          };
          inactive_sections = {
            lualine_a = [ ];
            lualine_b = [ ];
            lualine_c = [ "filename" ];
            lualine_x = [ "location" ];
            lualine_y = [ ];
            lualine_z = [ ];
          };
        };
      };

      plugins.which-key = {
        enable = true;
        settings.spec = [
          { __unkeyed-1 = "<leader>f"; group = "telescope"; }
          { __unkeyed-1 = "<leader>b"; group = "buffer"; }
          { __unkeyed-1 = "<leader>m"; group = "make"; }
          { __unkeyed-1 = "<leader>g"; group = "git"; }
          { __unkeyed-1 = "<leader>gr"; group = "git rebase"; }
          { __unkeyed-1 = "<leader>c"; group = "cmake"; }
        ];
      };

      plugins.fugitive.enable = true;
      plugins.sleuth.enable = true;
      plugins.undotree.enable = true;

      plugins.nvim-tree = {
        enable = true;
        settings = {
          actions.open_file.quit_on_open = true;
          sync_root_with_cwd = true;
          respect_buf_cwd = true;
          update_focused_file = {
            enable = true;
            update_root.enable = true;
          };
          view.width = 30;
          renderer.group_empty = true;
        };
      };

      extraPlugins = with pkgs.vimPlugins; [
        asyncrun-vim
        close-buffers-vim
        cmake-tools-nvim
        focus-nvim
        mini-icons
        mkdir-nvim
        openscad-nvim
        vim-autosource
        vim-flog
        vim-gas
        vim-localvimrc
        vim-nix
        vim-qml
        project-nvim
      ];

      extraPackages = with pkgs; [
        fd
        ccls
        neovim-remote
        nodejs
        (python3.withPackages (ps: with ps; [ pynvim ]))
        ripgrep
        tree-sitter
      ];

      extraConfigLuaPre = ''
        --
        -- GUI Configuration
        --

        -- Font (neovim-qt)
        if (vim.fn.exists('GuiFont') == 1) then
          vim.cmd('GuiFont ${cfg.neovim-qt.fontName}:h${builtins.toString cfg.neovim-qt.fontSize}')
        end

        -- Disable the GUI tab-line
        vim.rpcnotify(0, 'Gui', 'Option', 'Tabline', 0)

        -- Neovide Configuration
        if vim.g.neovide then
          vim.o.guifont = '${cfg.neovide.fontName}:h${builtins.toString cfg.neovide.fontSize}:#e-${cfg.neovide.fontAntiAliasing}:#h-${cfg.neovide.fontHinting}';
          vim.g.neovide_refresh_rate = 60;
          vim.g.neovide_cursor_animation_length = 0.01;
          vim.g.neovide_hide_mouse_when_typing = true;
        end

        -- Full Screen Toggle
        if vim.g.neovide then
          vim.api.nvim_exec2([[
            function! s:GuiFullScreenToggle()
              let g:neovide_fullscreen=!g:neovide_fullscreen
            endfunction
            command! GuiFullScreenToggle call s:GuiFullScreenToggle()
          ]], {})
        else
          vim.api.nvim_exec2([[
            let g:GuiWindowFullScreen = 0
            function! s:GuiFullScreenToggle()
              if g:GuiWindowFullScreen == 0
                call rpcnotify(0, 'Gui', 'WindowFullScreen', 1)
              else
                call rpcnotify(0, 'Gui', 'WindowFullScreen', 0)
              endif
            endfunction
            command! GuiFullScreenToggle call s:GuiFullScreenToggle()
          ]], {})
        end
      '';

      extraConfigLua = ''
        --
        -- Undo directory
        --
        vim.o.undodir = string.format("%s/.vim/undo", vim.env.HOME)

        -- Auto-create parent directories on save
        vim.api.nvim_create_autocmd("BufWritePre", {
          callback = function(ev)
            local dir = vim.fn.fnamemodify(ev.match, ":p:h")
            if vim.fn.isdirectory(dir) == 0 then
              vim.fn.mkdir(dir, "p")
            end
          end,
        })

        --
        -- cmake-tools.nvim
        --
        require("cmake-tools").setup({
          cmake_command = "cmake",
          cmake_regenerate_on_save = true,
          cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
          cmake_build_directory = "build",
          cmake_soft_link_compile_commands = true,
          cmake_executor = {
            name = "quickfix",
            opts = {},
            default_opts = {
              quickfix = {
                show = "always",
                position = "belowright",
                size = 10,
                auto_close_when_success = true,
              },
            },
          },
          cmake_runner = {
            name = "terminal",
            opts = {},
            default_opts = {
              terminal = {
                split_direction = "horizontal",
                split_size = 11,
              },
            },
          },
          cmake_notifications = {
            runner = { enabled = true },
            executor = { enabled = true },
          },
        })

        -- Redefine :Ex
        vim.cmd('command! Ex NvimTreeFindFileToggle')

        --
        -- project.nvim
        --
        require("project").setup({
          detection_methods = { "lsp", "pattern" },
          patterns = { ".git", "Makefile", "CMakeLists.txt" },
          scope_chdir = "global",
          silent_chdir = true,
        })

        -- undotree
        vim.g.undotree_SetFocusWhenToggle = 1

        --
        -- focus.nvim
        --
        require("focus").setup({
          ui = {
            number = false,
            relativenumber = false,
            cursorline = false,
            signcolumn = false,
          },
          autoresize = {
            minwidth = 20,
            maxwidth = 128,
          },
        })

        --
        -- Focus command
        --
        vim.api.nvim_exec2([[
          function! s:Focus()
            :cclose
            for buf in filter(
                \ range(1, bufnr('$')),
                \ 'bufexists(v:val)
                \ && (
                \     getbufvar(v:val, "fugitive_type") != ""
                \  || getbufvar(v:val, "&filetype") ==# "floggraph"
                \    )')
              silent execute 'bwipeout' buf
            endfor
            NvimTreeClose
            UndotreeHide
          endfunction
          command! Focus call s:Focus()
        ]], {})

        --
        -- neovim-remote
        --
        if vim.fn.has('nvim') == 1 then
          vim.env.NVIM_LISTEN_ADDRESS = vim.v.servername
          vim.env.GIT_EDITOR = 'nvr -cc split --remote-wait'
        end

        -- termguicolors (disable in tmux)
        vim.o.termguicolors = (not vim.env.TMUX and vim.fn.has('termguicolors') == 1)

        -- Terminal colors (Tango palette, set after colorscheme to prevent override)
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

        -- Hide line numbers in terminal buffers
        vim.api.nvim_create_autocmd("TermOpen", {
          callback = function()
            vim.wo.number = false
            vim.wo.relativenumber = false
          end,
        })
      '';
    };
  };
}
