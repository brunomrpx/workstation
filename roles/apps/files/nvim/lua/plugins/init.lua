return {
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override_by_extension = {
        ["yaml"] = { icon = "󰈙", color = "#938AA9", name = "Yaml" },
        ["yml"]  = { icon = "󰈙", color = "#938AA9", name = "Yml" },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "vim", "lua", "vimdoc", "html", "css", "python" },
    },
  },
}
