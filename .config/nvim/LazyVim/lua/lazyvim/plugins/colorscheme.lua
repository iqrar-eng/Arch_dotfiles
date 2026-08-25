return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = (function()
        local state = vim.fn.stdpath("data") .. "/colorscheme"
        local ok, lines = pcall(vim.fn.readfile, state)
        return ok and lines[1] or "catppuccin-latte"
      end)(),
    },
  },

  {
    "catppuccin/nvim",
    lazy = false,
    priority = 1000, -- ensure it loads before everything else
    name = "catppuccin",
    opts = {
      auto_integrations = true,
      color_overrides = {
        latte = {
          -- flamingo, sapphire, overlay1 also are pre-built usable choices
          base = "#f8f8f6",
          mantle = "#f8f8f6",
          crust = "#ffffff",
        },
      },

      highlight_overrides = {
        -- Increase contrast, which is not enough by default:
        latte = function(colors)
          return {
            VM_Mono = { bg = "#000000", fg = "#ffffff" },
            VM_Insert = { bg = "#E6AF0E", fg = "#ffffff" },
            VM_Cursor = { bg = "#2DC427", fg = "#ffffff" },
            VM_Extend = { bg = "#E0F3FF", ctermbg = 250, ctermfg = 16, bold = true, fg = "none" },

            ["@property"] = { fg = "#ff0000" },
            ["@property.css"] = { fg = "#ff0000" }, -- CSS properties - sky blue
            ["@property.class.css"] = { fg = "#D000ED" }, -- Tag attribute - blue
            ["@property.id.css"] = { fg = "#2DC427" }, -- Tag attribute - blue

            ["@tag.attribute"] = { fg = "#D000ED" }, -- Tag attribute - blue

            ["@keyword.conditional"] = { fg = "#2DC427" },
            ["@keyword.repeat"] = { fg = "#005CFF" },
            ["@keyword.function"] = { fg = "#D000ED" },
            ["@keyword.import"] = { fg = "#D000ED" },
            ["@keyword.export"] = { fg = "#2DC427" },
            ["@keyword.return"] = { fg = "#D000ED" },
            ["@keyword.operator"] = { fg = "#8c8fa1" },
            ["@keyword"] = { fg = "#C7B700" },

            ["@boolean"] = { fg = "#2DC427" },
            ["type"] = { fg = "#fe640b" },
            ["@namespace"] = { fg = "#fe640b" },
            ["@float"] = { fg = "#D000ED" },
            ["@lsp.type.method"] = { fg = "#dd7878" },
            ["@variable.parameter"] = { fg = "#209fb5" },
            ["@number"] = { fg = "#D000ED" },
            ["@string"] = { fg = "#000000" },
            ["@comment"] = { fg = "#8c8fa1", italic = true },
            ["@markup.link.label"] = { fg = "#7287FE", underline = true, bold = true, sp = "#B7BDD9" },
            ["@my_markup.strong"] = { fg = "#D20F3A", underline = true, bold = true, sp = "#D5B7BF" },
            ["@my_markup.raw.markdown_inline"] = { fg = "#17929A", underline = true, bold = true, sp = "#B2C9CB" },
            ["@my_mdn_bad_code_example"] = { undercurl = true, sp = "#cfc8c8" },

            MatchParen = { fg = "#000000", bg = "#C9EAFF" },
            Substitute = { bg = "#D20F3A", fg = "#FFFFFE" },
            Search = { bg = "#FFFCC2", fg = "none" },
            Visual = { bg = "#E6E7EB", bold = true, cterm = { bold = true } },
            VisualNOS = { link = "Visual" },
            WinSeparator = { fg = "#D5B7BF", bg = colors.base },
            CursorLineNr = { fg = "#000000", bold = true },

            LspReferenceText = { bg = "#ffe8cc", bold = true },
            LspReferenceRead = { bg = "#D4E6FF" },
            LspSignatureActiveParameter = { bg = colors.crust },
            ["DiagnosticDeprecated"] = { cterm = { underline = true }, sp = "#590008", underline = true },
            DiagnosticVirtualTextInfo = { bg = "#F7FFFF", cterm = { italic = true }, fg = "#C4C4C4", italic = true },
            DiagnosticVirtualTextWarn = { bg = "#FFFDFC", cterm = { italic = true }, fg = "#C4C4C4", italic = true },
            DiagnosticVirtualTextError = { bg = "#FFFAFA", cterm = { italic = true }, fg = "#E3E3E3", italic = true },
            DiagnosticVirtualTextHint = { bg = "NONE", cterm = { italic = true }, fg = "#B9EAED", italic = true },

            SnacksIndent1 = { fg = "#00BFAE", bg = "none" },
            SnacksIndent2 = { fg = "#ea76cb", bg = "none" },
            SnacksIndent3 = { fg = "#ff5d00", bg = "none" },
            SnacksIndent4 = { fg = "#00CF1E", bg = "none" },
            SnacksIndent5 = { fg = "#8F8F8F", bg = "none" },
            SnacksIndent6 = { fg = "#C39900", bg = "none" },
            SnacksIndent7 = { fg = "#00CF1E", bg = "none" },
            SnacksIndent8 = { fg = "#ea76cb", bg = "none" },
            SnacksIndent9 = { fg = "#00BFAE", bg = "none" },
            SnacksIndent10 = { fg = "#ff5d00", bg = "none" },
            SnacksIndent11 = { fg = "#8F8F8F", bg = "none" },
            SnacksIndent12 = { fg = "#C39900", bg = "none" },

            RenderMarkdownCode = { bg = colors.crust },

            AerialLine = { link = "VisualNOS" },
          }
        end,
        mocha = function(colors)
          return {
            VM_Mono = { bg = "#cdd6f4", fg = "#1e1e2e" },
            VM_Insert = { bg = "#E6AF0E", fg = "#1e1e2e" },
            VM_Cursor = { bg = "#2DC427", fg = "#1e1e2e" },
            VM_Extend = { bg = "#1a3a5c", ctermbg = 236, ctermfg = 255, bold = true, fg = "none" },

            ["@property"] = { fg = "#ffa857", bold = true },

            ["@keyword.conditional"] = { fg = "#00FF00" },
            ["@keyword.repeat"] = { fg = "#FF7C00" },
            ["@keyword.operator"] = { fg = "#6c7086" },
            ["@keyword"] = { link = "@boolean" },
            ["@keyword.function"] = { fg = "#FF00FF" },

            ["@boolean"] = { fg = "#40FFFF" },
            ["type"] = { fg = "#fab387" },
            ["@string"] = { bold = true, fg = "#E8E3E3" },
            ["@markup.link.label"] = { fg = "#B4BEFF", underline = true, bold = true, sp = "#545557" },
            ["@my_markup.strong"] = { fg = "#F38BA9", underline = true, bold = true, sp = "#998E91" },
            ["@my_markup.raw.markdown_inline"] = { fg = "#00E6C0", underline = true, bold = true, sp = "#809792" },
            ["@my_mdn_bad_code_example"] = { undercurl = true, sp = "#4A3F3F" },

            MatchParen = { fg = "#ffffff", bg = "#356aa3" },
            Substitute = { bg = "#E64553", fg = "#ffffff" },
            Search = { bg = "#c7aa2a", fg = "#000000" },
            CurSearch = { bg = "#911c3d", fg = "#ffffff" },
            WinSeparator = { fg = "#911c3d", bg = colors.base },
            CursorLineNr = { fg = "#FFFFFF", bold = true },

            LspReferenceText = { bg = "#5A4328", bold = true },
            LspReferenceRead = { bg = "#1A3A73" },
            LspSignatureActiveParameter = { bg = colors.mantle },
            ["DiagnosticDeprecated"] = { cterm = { underline = true }, sp = "#f38ba8", underline = true },
            DiagnosticVirtualTextInfo = { bg = "NONE", fg = "#8f8f8f", italic = true },
            DiagnosticVirtualTextWarn = { bg = "NONE", fg = "#3f3f3f", italic = true },
            DiagnosticVirtualTextError = { bg = "NONE", fg = "#3f3f3f", italic = true },
            DiagnosticVirtualTextHint = { bg = "NONE", fg = "#3f3f3f", italic = true },

            RenderMarkdownCode = { bg = "#181826", bold = true },

            SnacksPicker = { bg = colors.base },

            SnacksIndent1 = { fg = "#00E6C0", bg = "none" },
            SnacksIndent2 = { fg = "#E636E6", bg = "none" },
            SnacksIndent3 = { fg = "#f7823e", bg = "none" },
            SnacksIndent4 = { fg = "#00E620", bg = "none" },
            SnacksIndent5 = { fg = "#a3a0a0", bg = "none" },
            SnacksIndent6 = { fg = "#CCE600", bg = "none" },
            SnacksIndent7 = { fg = "#00E620", bg = "none" },
            SnacksIndent8 = { fg = "#E636E6", bg = "none" },
            SnacksIndent9 = { fg = "#00E6C0", bg = "none" },
            SnacksIndent10 = { fg = "#f7823e", bg = "none" },
            SnacksIndent11 = { fg = "#a3a0a0", bg = "none" },
            SnacksIndent12 = { fg = "#CCE600", bg = "none" },
          }
        end,
        all = function(colors)
          return {
            FlashLabel = { link = "Substitute" },
            FlashCurrent = { link = "IncSearch" },
            FlashMatch = { link = "Search" },

            AerialLine = { link = "VisualNOS" },

            RenderMarkdownH1Bg = { link = "SnacksIndent1" },
            RenderMarkdownH2Bg = { link = "SnacksIndent2" },
            RenderMarkdownH3Bg = { link = "SnacksIndent3" },
            RenderMarkdownH4Bg = { link = "SnacksIndent4" },
            RenderMarkdownH5Bg = { link = "SnacksIndent5" },
            RenderMarkdownH6Bg = { link = "SnacksIndent6" },
            RenderMarkdownCodeInline = { bg = colors.base },

            DiagnosticUnnecessary = { link = "none" },

            ["@tag.builtin"] = { link = "SnacksIndent3" },
            ["@tag"] = { link = "SnacksIndent3" },

            CursorLine = { link = "Visual" },
          }
        end,
      },
    },
  },
}
