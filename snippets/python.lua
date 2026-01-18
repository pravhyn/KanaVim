local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local c = ls.choice_node

local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

return {
        s(
                "adefs",
                fmt(
                        [[
async def {}(self{}):
    {}
]],
                        {
                                i(1, "method_name"),
                                i(2, ""),
                                i(3, "pass"),
                        }
                )
        ),

        s("ifni", {
                t("if not isinstance("),
                i(1, "obj"),
                t(", "),
                i(2, "Type"),
                t("):"),
                t({ "", "    " }),
                i(3),
        }),
        s("ifis", {
                t("if isinstance("),
                i(1, "obj"),
                t(", "),
                i(2, "Type"),
                t("):"),
                t({ "", "    " }),
                i(3),
        }),

        c(2, {
                t("dict"),
                t("list"),
                t("str"),
                t("int"),
        }),
}
