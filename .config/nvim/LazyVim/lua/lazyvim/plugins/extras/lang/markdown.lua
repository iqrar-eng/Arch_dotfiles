LazyVim.on_very_lazy(function()
  vim.filetype.add({
    extension = { mdx = "markdown.mdx" },
  })
end)
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      anti_conceal = {
        enabled = false,
      },
      code = { width = "block" },
      win_options = {
        conceallevel = {
          rendered = 2,
        },
        concealcursor = {
          rendered = "n",
        },
      },
      quote = { icon = "🭪" },
      heading = {
        sign = false,
        position = "inline",
        width = "block",
        icons = { "▊ ", "▊ ", "▊ ", "▊ ", "▊ ", "▊ " },
      },
      pipe_table = {
        padding = 0,
      },
      patterns = {
        markdown = {
          disable = false,
        },
      },
    },
    ft = { "markdown", "markdown.mdx", "html", "norg", "rmd", "org", "codecompanion" },
    config = function(_, opts)
      require("render-markdown").setup(opts)
    end,
  },
}
