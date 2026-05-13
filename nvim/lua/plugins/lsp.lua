return {
  { "williamboman/mason.nvim", config = true },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "marksman" },
        automatic_installation = true,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      vim.lsp.config("pyright", {
        settings = {
          python = { analysis = { autoImportCompletions = true } },
        },
      })
      vim.lsp.config("ruff", {
        init_options = {
          settings = {
            fixAll = true,
            organizeImports = true,
          },
        },
      })

      vim.lsp.enable({ "pyright", "ruff", "rust_analyzer", "marksman" })

      -- ty: Astral type checker (not yet in nvim-lspconfig, registered manually)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function(args)
          vim.lsp.start({
            name = "ty",
            cmd = { "ty", "server" },
            root_dir = vim.fs.root(args.buf, { "pyproject.toml", "ruff.toml", ".git" })
              or vim.fn.fnamemodify(args.file, ":p:h"),
          })
        end,
      })
    end,
  },
}
