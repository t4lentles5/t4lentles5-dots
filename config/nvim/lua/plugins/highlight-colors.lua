return {
  "brenoprata10/nvim-highlight-colors",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    render = "virtual",
    virtual_symbol = "󱓻",
    virtual_symbol_position = "inline",
    enable_named_colors = true,
    enable_tailwind = true,
    enable_hex = true,
    enable_rgb = true,
    enable_hsl = true,
  },
  init = function()
    vim.opt.termguicolors = true
  end,
}
