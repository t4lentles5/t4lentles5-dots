local colors = vim.g.qs_colors
  or {
    bg = "#030107",
    bgSecondary = "#12121b",
    fg = "#d1d1d1",
    muted = "#484d69",
    cyan = "#72cbff",
    purple = "#a77ef5",
    red = "#e52e4f",
    yellow = "#f0a32f",
    blue = "#5b70db",
    green = "#86c93f",
  }

-- Clear highlights
vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.g.colors_name = "default"

local hl = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local is_light = vim.o.background == "light"

-- Terminal Colors
vim.g.terminal_color_0 = colors.bg
vim.g.terminal_color_8 = colors.muted
vim.g.terminal_color_1 = colors.red
vim.g.terminal_color_9 = colors.red
vim.g.terminal_color_2 = colors.green
vim.g.terminal_color_10 = colors.green
vim.g.terminal_color_3 = colors.yellow
vim.g.terminal_color_11 = colors.yellow
vim.g.terminal_color_4 = colors.blue
vim.g.terminal_color_12 = colors.blue
vim.g.terminal_color_5 = colors.purple
vim.g.terminal_color_13 = colors.purple
vim.g.terminal_color_6 = colors.cyan
vim.g.terminal_color_14 = colors.cyan
vim.g.terminal_color_7 = colors.fg
vim.g.terminal_color_15 = colors.fg

-- Editor UI
hl("Normal", { fg = colors.fg, bg = colors.bg })
hl("NormalFloat", { fg = colors.fg, bg = colors.bgSecondary })
hl("FloatBorder", { fg = colors.purple, bg = colors.bgSecondary })
hl("ColorColumn", { bg = colors.bgSecondary })
hl("CursorLine", { bg = colors.bgSecondary })
hl("CursorLineNr", { fg = colors.purple, bold = true })
hl("LineNr", { fg = colors.muted })
hl("VertSplit", { fg = colors.bgSecondary, bg = colors.bgSecondary })
hl("WinSeparator", { fg = colors.bgSecondary })
hl("Pmenu", { fg = colors.fg, bg = colors.bgSecondary })
hl("PmenuSel", { fg = is_light and colors.fg or colors.bg, bg = colors.purple, bold = true })
hl("Search", { fg = colors.bg, bg = colors.yellow })
hl("IncSearch", { fg = colors.bg, bg = colors.purple })
hl("StatusLine", { fg = colors.fg, bg = colors.bgSecondary })
hl("StatusLineNC", { fg = colors.muted, bg = colors.bgSecondary })
hl("Visual", { bg = is_light and "#ddd6f3" or "#2a2a37" })
hl("MatchParen", { fg = colors.cyan, bold = true })
hl("NonText", { fg = colors.bgSecondary })
hl("SpecialKey", { fg = colors.muted })
hl("Folded", { fg = colors.muted, bg = colors.bgSecondary })

-- Standard Syntax
hl("Comment", { fg = colors.muted, italic = true })
hl("Constant", { fg = colors.yellow })
hl("String", { fg = colors.green })
hl("Character", { fg = colors.green })
hl("Number", { fg = colors.yellow })
hl("Boolean", { fg = colors.yellow })
hl("Float", { fg = colors.yellow })

hl("Identifier", { fg = colors.fg })
hl("Function", { fg = colors.blue })

hl("Statement", { fg = colors.purple })
hl("Conditional", { fg = colors.purple })
hl("Repeat", { fg = colors.purple })
hl("Label", { fg = colors.purple })
hl("Operator", { fg = colors.cyan })
hl("Keyword", { fg = colors.purple })
hl("Exception", { fg = colors.red })

hl("PreProc", { fg = colors.red })
hl("Include", { fg = colors.red })
hl("Define", { fg = colors.purple })
hl("Macro", { fg = colors.purple })
hl("PreCondit", { fg = colors.red })

hl("Type", { fg = colors.cyan })
hl("StorageClass", { fg = colors.purple })
hl("Structure", { fg = colors.purple })
hl("Typedef", { fg = colors.cyan })

hl("Special", { fg = colors.cyan })
hl("SpecialChar", { fg = colors.yellow })
hl("Tag", { fg = colors.red })
hl("Delimiter", { fg = colors.muted })
hl("SpecialComment", { fg = colors.muted })
hl("Debug", { fg = colors.red })

hl("Underlined", { underline = true })
hl("Error", { fg = colors.red, bold = true })
hl("Todo", { fg = colors.yellow, bold = true })

-- Treesitter
hl("@variable", { fg = colors.fg })
hl("@variable.builtin", { fg = colors.red })
hl("@variable.member", { fg = colors.cyan })
hl("@property", { fg = colors.cyan })
hl("@parameter", { fg = colors.yellow })

hl("@function", { fg = colors.blue })
hl("@function.builtin", { fg = colors.blue, bold = true })
hl("@function.call", { fg = colors.cyan })
hl("@method", { fg = colors.blue })
hl("@method.call", { fg = colors.cyan })
hl("@constructor", { fg = colors.cyan })

hl("@keyword", { fg = colors.purple })
hl("@keyword.function", { fg = colors.purple })
hl("@keyword.return", { fg = colors.purple })
hl("@keyword.conditional", { fg = colors.purple })
hl("@keyword.repeat", { fg = colors.purple })
hl("@keyword.import", { fg = colors.red })
hl("@keyword.export", { fg = colors.red })
hl("@keyword.coroutine", { fg = colors.red })
hl("@keyword.operator", { fg = colors.cyan })
hl("@keyword.modifier", { fg = colors.purple })

hl("@type", { fg = colors.cyan })
hl("@type.builtin", { fg = colors.cyan })
hl("@type.qualifier", { fg = colors.purple })
hl("@interface", { fg = colors.cyan })

hl("@constant", { fg = colors.yellow })
hl("@constant.builtin", { fg = colors.yellow })
hl("@constant.macro", { fg = colors.yellow })

hl("@string", { fg = colors.green })
hl("@comment", { fg = colors.muted, italic = true })
hl("@attribute", { fg = colors.yellow }) -- Decorators

-- Punctuation
hl("@punctuation.delimiter", { fg = colors.muted })
hl("@punctuation.bracket", { fg = colors.muted })
hl("@punctuation.special", { fg = colors.cyan })

-- Tags
hl("@tag", { fg = colors.red })
hl("@tag.builtin", { fg = colors.red })
hl("@tag.attribute", { fg = colors.yellow })
hl("@tag.delimiter", { fg = colors.muted })

-- Diagnostics
hl("DiagnosticError", { fg = colors.red })
hl("DiagnosticWarn", { fg = colors.yellow })
hl("DiagnosticInfo", { fg = colors.blue })
hl("DiagnosticHint", { fg = colors.cyan })

-- Plugins
hl("GitSignsAdd", { fg = colors.green })
hl("GitSignsChange", { fg = colors.yellow })
hl("GitSignsDelete", { fg = colors.red })
hl("IblIndent", { fg = colors.bgSecondary })
hl("TelescopeBorder", { fg = colors.bgSecondary, bg = colors.bg })
hl("TelescopePromptBorder", { fg = colors.purple, bg = colors.bg })

-- LSP
hl("@lsp.type.interface", { link = "@interface" })
hl("@lsp.type.parameter", { link = "@parameter" })
hl("@lsp.type.type", { link = "@type" })
hl("@lsp.type.class", { link = "@type" })
hl("@lsp.type.enum", { link = "@type" })
hl("@lsp.type.enumMember", { link = "@constant" })
hl("@lsp.type.function", { link = "@function.call" })
hl("@lsp.type.method", { link = "@method.call" })
hl("@lsp.type.property", { link = "@property" })
hl("@lsp.type.variable", { link = "@variable" })
hl("@lsp.type.decorator", { link = "@attribute" })
