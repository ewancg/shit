{ lib, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

    colorschemes.gruvbox = {
      enable = true;
      settings = {
        terminal_colors = false;
      };
    };
    # colorschemes.catppuccin = {
    #   enable = true;
    #   settings = { 
    #     transparent_background = true;
    #     transparent_panel = true;
    #     color_overrides = {
    #       mocha = {
    #         base = "#000000";
    #       };
    #     };
    #     flavour = "mocha";
    #     disable_underline = false;
    #     term_colors = true;
    #     styles = {
    #       booleans = [
    #         "bold"
    #         "italic"
    #       ];
    #       conditionals = [ "bold" ];
    #     };
    #     integrations = {
    #       cmp = true;
    #       gitsigns = true;
    #       nvimtree = true;
    #       treesitter = true;
    #       notify = true;
    #       mini = {
    #         enabled = true;
    #         indentscope_color = "";
    #       };
    #     };
    #   };
    # };

    plugins = {
      # Dependencies
      web-devicons.enable = true;

      # Sidebar
      neo-tree.enable = true;
      # Status bar
      lualine.enable = true;
      # Buffer line (by cursor)
      bufferline.enable = true;

      nix.enable = true;
      # Rust
      rustaceanvim.enable = true;
      # Automatic test runner
      bacon.enable = true;

      # ocamllex package dependency - broken 3/31/25
      # Generic code model support
      # treesitter.enable = true;

      lsp = {
        servers.ocamlls = {
          enable = false;
          package = null;
        };
      };
    };

    # extraPlugins = with pkgs.vimPlugins; [
    #       # nav bar
    #       neo-tree-nvim
    #       vim-nix
    #       LazyVim
    #       bufferline-nvim
    #       cmp-buffer
    #       cmp-nvim-lsp
    #       cmp-path
    #       cmp_luasnip
    #       conform-nvim
    #       catppuccin-nvim
    #       dashboard-nvim
    #       dressing-nvim
    #       flash-nvim
    #       friendly-snippets
    #       gitsigns-nvim
    #       indent-blankline-nvim
    #       lualine-nvim
    #       neoconf-nvim
    #       neodev-nvim
    #       noice-nvim
    #       nui-nvim
    #       nvim-cmp
    #       nvim-lint
    #       nvim-lspconfig
    #       nvim-notify
    #       nvim-spectre
    #       nvim-treesitter
    #       nvim-treesitter-context
    #       nvim-treesitter-textobjects
    #       nvim-ts-autotag
    #       nvim-ts-context-commentstring
    #       nvim-web-devicons
    #       persistence-nvim
    #       plenary-nvim
    #       telescope-fzf-native-nvim
    #       telescope-nvim
    #       todo-comments-nvim
    #       tokyonight-nvim
    #       trouble-nvim
    #       vim-illuminate
    #       vim-startuptime
    #       which-key-nvim
    #       # { name = "LuaSnip"; path = luasnip; }
    #       # { name = "catppuccin"; path = catppuccin-nvim; }
    #       # { name = "mini.ai"; path = mini-nvim; }
    #       # { name = "mini.bufremove"; path = mini-nvim; }
    #       # { name = "mini.comment"; path = mini-nvim; }
    #       # { name = "mini.indentscope"; path = mini-nvim; }
    #       # { name = "mini.pairs"; path = mini-nvim; }
    #       # { name = "mini.surround"; path = mini-nvim; }
    # ];
  };
}
