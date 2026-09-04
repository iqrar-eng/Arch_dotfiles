local M = {}

---@param increment boolean
---@param g? boolean
function M.dial(increment, g)
  local mode = vim.fn.mode(true)
  local is_visual = mode == "v" or mode == "V" or mode == "\22"
  local func = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
  local group = vim.g.dials_by_ft[vim.bo.filetype] or "default"
  return require("dial.map")[func](group)
end

---@param increment boolean
---@param g? boolean
function M.dial_charwise(increment, g)
  local mode = vim.fn.mode(true)
  local is_visual = mode == "v" or mode == "V" or mode == "\22"
  local func = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
  return require("dial.map")[func]("my_charwise")
end

---@param increment boolean
---@param g? boolean
function M.dial_misc(increment, g)
  local mode = vim.fn.mode(true)
  local is_visual = mode == "v" or mode == "V" or mode == "\22"
  local func = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
  return require("dial.map")[func]("my_misc")
end

return {
  "monaqa/dial.nvim",
  recommended = true,
  desc = "Increment and decrement numbers, dates, and more",
  -- stylua: ignore
  keys = {
    { "<C-a>", function() return M.dial(true) end, expr = true, desc = "Increment", mode = {"n", "v", "s"} },
    { "<C-x>", function() return M.dial(false) end, expr = true, desc = "Decrement", mode = {"n", "v", "s"} },
    { "g<C-a>", function() return M.dial(true, true) end, expr = true, desc = "Increment", mode = {"n", "x"} },
    { "g<C-x>", function() return M.dial(false, true) end, expr = true, desc = "Decrement", mode = {"n", "x"} },

    { "<M-a>", function() return M.dial_charwise(true) end, expr = true, desc = "Increment (charwise)", mode = {"n", "x", "s"} },
    { "<M-x>", function() return M.dial_charwise(false) end, expr = true, desc = "Decrement (charwise)", mode = {"n", "x", "s"} },
    { "g<M-a>", function() return M.dial_charwise(true, true) end, expr = true, desc = "Increment (charwise)", mode = {"n", "x"} },
    { "g<M-x>", function() return M.dial_charwise(false, true) end, expr = true, desc = "Decrement (charwise)", mode = {"n", "x"} },

    { "<M-s>", function() return M.dial_misc(true) end, expr = true, desc = "Increment (misc)", mode = {"n", "x", "s"} },
    { "<M-d>", function() return M.dial_misc(false) end, expr = true, desc = "Decrement (misc)", mode = {"n", "x", "s"} },
    { "g<M-s>", function() return M.dial_misc(true, true) end, expr = true, desc = "Increment (misc)", mode = {"n", "x"} },
    { "g<M-d>", function() return M.dial_misc(false, true) end, expr = true, desc = "Decrement (misc)", mode = {"n", "x"} },
  },
  -- stylua: ignore
  opts = function()
    local augend = require("dial.augend")
    local function const(elements, opts)
      return augend.constant.new(vim.tbl_extend("force", {
        elements = elements,
        word = false,
        preserve_case = true,
        cyclic = true,
      }, opts or {}))
    end

    -- single-char increment/decrement, always targeted by <M-a> <M-x>
    local alphabets      = const(vim.split("abcdefghijklmnopqrstuvwxyz", ""), {})
    local bracket_curly   = const({ "{", "}" })
    local bracket_square  = const({ "[", "]" })
    local bracket_angle   = const({ "<", ">" })
    local bracket_round   = const({ "(", ")" })
    local numbers   = const({ "-1","0","1","2","3","4","5","6","7","8","9" })

    -- word-wise pairs
    local doubleParens          = const({ "((", "))" })
    local doubleSquare          = const({ "[[", "]]" })
    local doubleCurly           = const({ "{{", "}}" })
    local doubleAngle           = const({ "<<", ">>" })
    local comparison            = const({ "<=", ">=" })
    local curlyRound            = const({ "({", "})" })
    local equality              = const({ "==", "!=" })
    local strictEquality        = const({ "===", "!==" })
    local AND_OR_operators      = const({ "&&", "||" })
    local home_end              = const({ "home", "end" })
    local left_right            = const({ "left", "right" })
    local up_down               = const({ "up", "down" })
    local and_or                = const({ "and", "or" })
    local min_max               = const({ "max", "min" })
    local next_previous         = const({ "next", "previous" })
    local before_after          = const({ "after", "before" })
    local alt_ctrl_shift        = const({ "alt", "ctrl", "shift" })
    local number_words_with_th  = const({ "first","second","third","fourth","fifth","sixth","seventh","eighth","ninth","tenth","eleventh","twelfth","thirteenth","fourteenth","fifteenth","sixteenth","seventeenth","eighteenth","nineteenth","twentieth","last" })
    local number_words          = const({ "zero","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen","sixteen","seventeen","eighteen","nineteen","twenty" }, { word = true })
    local months                = const({ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", }, { word = true })
    local months_full           = const({ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", }, { word = true })

    return {
      dials_by_ft = {
        vue = "vue",
        javascript = "typescript",
        typescript = "typescript",
        typescriptreact = "typescript",
        javascriptreact = "typescript",
        ["markdown.mdx"] = "markdown",
        json = "json",
        markdown = "markdown",
      },
      groups = {
        default = {
          augend.integer.alias.hex,
          augend.integer.alias.decimal_int,

          augend.date.alias["%Y/%m/%d"],
          augend.constant.alias.en_weekday,
          augend.constant.alias.en_weekday_full,
          months,
          months_full,

          augend.constant.alias.bool,
          augend.constant.alias.Bool,
          doubleParens,
          doubleSquare,
          doubleCurly,
          doubleAngle,
          comparison,
          curlyRound,
          equality,
          strictEquality,
          AND_OR_operators,
          home_end,
          left_right,
          up_down,
          and_or,
          min_max,
          next_previous,
          before_after,
          alt_ctrl_shift,
          number_words_with_th,
          number_words,
        },
        my_charwise = {
          bracket_round,
          bracket_angle,
          bracket_square,
          bracket_curly,
          alphabets,
          numbers,
        },
        my_misc = {
          augend.case.new{
            types = {
              "camelCase",
              "PascalCase",
              "snake_case",
              "kebab-case",
              "SCREAMING_SNAKE_CASE",
            },
          },

          -- conflicts if put in default table
          augend.hexcolor.new { case = "lower" },
          augend.decimal_fraction.new{},
        },
        vue = {
          augend.constant.new({ elements = { "let", "const" } }),
        },
        typescript = {
          augend.constant.new({ elements = { "let", "const" } }),
        },
        markdown = {
          augend.constant.new({
            elements = { "[ ]", "[x]" },
            word = false,
            cyclic = true,
          }),
          augend.misc.alias.markdown_header,
        },
        json = {
          augend.semver.alias.semver,
        },
      },
    }
  end,
  config = function(_, opts)
    for name, group in pairs(opts.groups) do
      if name ~= "default" and name ~= "my_charwise" and name ~= "my_misc" then
        vim.list_extend(group, opts.groups.default)
      end
    end
    require("dial.config").augends:register_group(opts.groups)
    vim.g.dials_by_ft = opts.dials_by_ft
  end,
}
