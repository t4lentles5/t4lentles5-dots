return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      on_colors = function(c)
        if vim.o.background == "dark" then
          c.bg = "#121218"
          c.bg_dark = "#181822"
          c.bg_float = "#181822"
          c.bg_popup = "#181822"
          c.bg_sidebar = "#181822"
          c.bg_statusline = "#121218"
          c.bg_highlight = "#181822"
        end
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
    end,
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "ellisonleao/gruvbox.nvim", priority = 1000 },
  { "shaunsingh/nord.nvim", priority = 1000 },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    lazy = false,
    opts = {
      variant = "auto", -- Follow background
    },
  },
  { "rebelot/kanagawa.nvim", priority = 1000 },
  { "sainnhe/everforest", priority = 1000 },
  { "navarasu/onedark.nvim", priority = 1000 },
  { "Shatur/neovim-ayu", priority = 1000 },
}
