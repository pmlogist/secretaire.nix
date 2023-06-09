{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixd.url = "github:nix-community/nixd";
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = {parts, ...} @ inputs:
    parts.lib.mkFlake {inherit inputs;} {
      systems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux"];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        node2nixPackages = pkgs.callPackage ./node2nix-packages {};

        dependencies = with pkgs; [
          # Shell
          ripgrep
          fzy
          zoxide
          git
          curl

          # LSP
          zk # markdown
          gopls
          lua-language-server
          # nixd # nix
          yaml-language-server
          nodePackages.typescript-language-server
          nodePackages.vscode-langservers-extracted # json, html, css
          nodePackages.svelte-language-server
          nodePackages."@astrojs/language-server"
          nodePackages."@tailwindcss/language-server"

          # Php
          php82Packages.phpcs
          php82Packages.phpcbf
          phpactor

          rnix-lsp

          rustywind

          nixd

          # Linter / Formatter
          stylua
          alejandra
          statix
          shfmt
          nodePackages.eslint_d
          node2nixPackages."@fsouza/prettierd"
          node2nixPackages."dockerfile-language-server-nodejs"
          node2nixPackages."blade-formatter"
        ];
      in rec {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            inputs.nixd.overlays.default
            (import ./packages.nix)
          ];
        };

        formatter = pkgs.alejandra;

        packages.secretaire = pkgs.wrapNeovim pkgs.neovim-unwrapped {
          viAlias = true;
          vimAlias = true;
          withNodeJs = false;
          withPython3 = false;
          withRuby = false;
          extraMakeWrapperArgs = ''--prefix PATH : "${pkgs.lib.makeBinPath dependencies}"'';
          configure = {
            customRC = "luafile ~/.config/nvim/init.lua";
            packages.myPlugins = with pkgs.vimPlugins; {
              start = with pkgs.vimPlugins;
              with pkgs.nodePackages; [
                # For plugins

                plenary-nvim

                neodev-nvim
                nvim-lspconfig

                nvim-treesitter.withAllGrammars # better code coloring
                playground # treesitter playground
                nvim-treesitter-textobjects # jump around and select based on syntax (class, function, etc.)
                nvim-treesitter-context # keep current block header (func defn or whatever) on first line

                null-ls-nvim

                telescope-nvim

                # Autocompletion
                nvim-cmp # generic autocompleter
                cmp-nvim-lsp # use lsp as source for completions
                cmp-nvim-lua # makes vim config editing better with completions
                cmp-buffer # any text in open buffers
                cmp-path # complete paths
                cmp-cmdline # completing in :commands
                cmp-emoji # complete :emojis:
                cmp-nvim-lsp-signature-help # help complete function call by showing args
                cmp-npm # complete node packages in package.json
                nvim-autopairs # balances parens as you type
                nvim-ts-autotag # balance or rename html

                luasnip # snippets driver
                cmp_luasnip # snippets completion

                oil-nvim
                # Session management
                persistence-nvim
                lspkind-nvim

                # UI
                indent-blankline-nvim-lua
                mini-indentscope-nvim

                noice-nvim

                neodev-nvim

                lualine-nvim

                neo-tree-nvim
                nvim-web-devicons

                gitsigns-nvim
                dressing-nvim

                alpha-nvim

                nvim-autopairs
                nvim-ts-autotag

                nvim-colorizer-lua
              ];
            };
          };
        };

        packages.default = packages.secretaire;

        apps.secretaire = {
          type = "app";
          program = "${packages.secretaire}/bin/nvim";
        };

        apps.default = apps.secretaire;

        devShells.default = pkgs.mkShell {
          packages = [packages.secretaire pkgs.nodePackages.node2nix] ++ dependencies;
        };
      };
    };
}
