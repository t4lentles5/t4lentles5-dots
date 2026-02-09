return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      on_colors = function(c)
        c.bg = "#121218"
        c.bg_dark = "#181822"
        c.bg_float = "#181822"
        c.bg_popup = "#181822"
        c.bg_sidebar = "#181822"
        c.bg_statusline = "#121218"
        c.bg_highlight = "#181822"
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
}

