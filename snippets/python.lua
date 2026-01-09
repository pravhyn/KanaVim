local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
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
}
