-- plugins.lua — Lazy.nvim plugin spec
-- Modules: LSP, Catppuccin, Treesitter, autopairs, telescope, neotree, gitsigns

return {
  -- =========================================================
  -- Colorscheme (load first)
  -- =========================================================
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- latte | frappe | macchiato | mocha
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
        notify = true,
        mason = true,
      },
    },
  },

  -- =========================================================
  -- Plugin manager UI
  -- =========================================================
  { "folke/lazy.nvim", priority = 1000 },

  -- =========================================================
  -- LSP, completion, lsp-related
  -- =========================================================
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp", lazy = true },
      { "hrsh7th/cmp-buffer", lazy = true },
      { "hrsh7th/cmp-path", lazy = true },
      { "saadparwaiz1/cmp-async-path", lazy = true },
      { "L3MON4D3/LuaSnip", lazy = true },
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local lspconfig = require("lspconfig")
      local luasnip = require("luasnip")

      -- Default LSP servers installed by the bootstrap
      local servers = {
        "lua_ls",
        "pyright",
        "ts_ls",        -- typescript
        "bashls",
        "jsonls",
        "yamlls",
        "terraformls",
        "gopls",
        "rust_analyzer",
        "html",
        "cssls",
        "tailwindcss",
      }

      for _, server in ipairs(servers) do
        local ok, srv = pcall(require, "lspconfig." .. server)
        if ok then
          srv.setup({
            on_attach = function(_, bufnr)
              local function map(key, fn, desc)
                vim.keymap.set("n", key, fn, { buffer = bufnr, desc = "LSP: " .. desc })
              end
              map("gd", vim.lsp.buf.definition, "Goto definition")
              map("gD", vim.lsp.buf.declaration, "Goto declaration")
              map("gi", vim.lsp.buf.implementation, "Goto implementation")
              map("gr", vim.lsp.buf.references, "References")
              map("K", vim.lsp.buf.hover, "Hover")
              map("<leader>rn", vim.lsp.buf.rename, "Rename")
              map("<leader>ca", vim.lsp.buf.code_action, "Code action")
            end,
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
          })
        end
      end

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "async_path" },
          { name = "path" },
          { name = "buffer" },
        }),
      })
    end,
  },

  -- =========================================================
  -- Mason for LSP server installation
  -- =========================================================
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function() require("mason").setup() end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "pyright", "ts_ls", "bashls", "jsonls",
          "yamlls", "terraformls", "gopls", "rust_analyzer",
        },
      })
    end,
  },

  -- =========================================================
  -- Treesitter
  -- =========================================================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "python", "javascript", "typescript", "tsx",
          "bash", "json", "yaml", "html", "css", "go", "rust",
          "terraform", "dockerfile", "markdown", "gitcommit",
        },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { enable = true },
      })
    end,
  },

  -- =========================================================
  -- Autopairs
  -- =========================================================
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- =========================================================
  -- Telescope (fuzzy finder)
  -- =========================================================
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { truncate = 1 },
        },
      })
      telescope.load_extension("fzf")

      local builtin = require("telescope.builtin")
      local keymap = vim.keymap
      keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Files" })
      keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep" })
      keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help" })
      keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume last search" })
      keymap.set("n", "<leader>fc", builtin.commands, { desc = "Commands" })
      keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
    end,
  },

  -- =========================================================
  -- Neo-tree (file explorer)
  -- =========================================================
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "Neotree" },
    keys = { "<leader>e" },
    config = function()
      require("neo-tree").setup({
        window = {
          width = 35,
          mappings = {
            ["<C-t>"] = "open_tab_new",
          },
        },
        filesystem = {
          filtered_items = { hide_dotfiles = false, hide_gitignored = false },
        },
      })
    end,
  },

  -- =========================================================
  -- Gitsigns
  -- =========================================================
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add          = { text = " " },
        change       = { text = " " },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "" },
        untracked    = { text = "" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = "Git: " .. desc })
        end
        map("n", "]h", function() gs.next_hunk() end, "Next hunk")
        map("n", "[h", function() gs.prev_hunk() end, "Prev hunk")
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
      end,
    },
  },

  -- =========================================================
  -- Useful utilities
  -- =========================================================
  { "numToStr/Comment.nvim", opts = {} },
  { "tpope/vim-sleuth", event = "BufReadPost" },

  -- Format & lint
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        terraform = { "terraform_fmt" },
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local null_ls = require("null-ls")
      local b = null_ls.builtins
      null_ls.setup({
        sources = {
          b.formatting.stylua,
          b.formatting.black,
          b.formatting.prettier,
          b.diagnostics.eslint,
          b.diagnostics.shellcheck,
        },
      })
    end,
  },
}
