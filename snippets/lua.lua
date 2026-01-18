local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local c = ls.choice_node

local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

return {
        s(
                "km",
                fmt(
                        [[
vim.keymap.set("{}", "{}", function()
  {}
end, {{ desc = "{}" }})
      ]],
                        {
                                i(1, "n"), -- mode
                                i(2, "<leader>"), -- lhs
                                i(3), -- body
                                i(4, "Description"), -- desc
                        }
                )
        ),
}
