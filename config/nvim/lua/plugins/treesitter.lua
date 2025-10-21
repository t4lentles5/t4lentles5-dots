return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      -- 🔹 Configuración y scripting en Linux
      "bash", -- incluye sh
      "fish",
      "toml",
      "yaml",
      "dockerfile",
      "gitignore",

      -- 🔹 Lua & Vim
      "lua",
      "vim",
      "vimdoc",

      -- 🔹 Lenguajes comunes en desarrollo general
      "python",
      "c",
      "cpp",
      "rust",
      "go",

      -- 🔹 Documentación y utilidades
      "markdown",
      "markdown_inline",
      "regex",
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
  },
}
