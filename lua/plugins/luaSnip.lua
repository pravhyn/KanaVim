local IN_WINDOWS = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
return {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        dependencies = { "rafamadriz/friendly-snippets" },
        -- build = IN_WINDOWS and  or "make install_jsregexp",

        build = 'make install_jsregexp CC="C:/ProgramData/mingw64/mingw64/bin/x86_64-w64-mingw32-gcc.exe"',
        -- build = 'make install_jsregexp CC=clang SHELL="C:/Program Files/Git/bin/sh.exe"',
        -- SHELL="C:/Program Files/Git/bin/sh.exe"',

        opts = {
                history = true,
                update_events = "TextChanged,TextChangedI",
                enable_autosnippets = true,
        },
        config = function(_, opts)
                local luasnip = require("luasnip")

                -- local ls = require("luasnip")
                --
                -- local t = ls.text_node
                -- local i = ls.insert_node
                -- local f = ls.function_node
                -- local s = ls.snippet
                -- local l = require("luasnip.extras").lambda
                --
                -- -- args is a table, where 1 is the text in Placeholder 1, 2 the text in
                -- -- placeholder 2,...
                -- local function copy(args)
                --         return args[1]
                -- end
                --
                -- ls.add_snippets("all", {
                --         -- trigger is `fn`, second argument to snippet-constructor are the nodes to insert into the buffer on expansion.
                --         s("fn", {
                --                 -- Simple static text.
                --                 t("//Parameters: "),
                --                 -- function, first parameter is the function, second the Placeholders
                --                 -- whose text it gets as input.
                --                 f(copy, 2),
                --                 t({ "", "function " }),
                --                 -- Placeholder/Insert.
                --                 i(1),
                --                 t("("),
                --                 -- Placeholder with initial text.
                --                 i(2, "int foo"),
                --                 -- Linebreak
                --                 t({ ") {", "\t" }),
                --                 -- Last Placeholder, exit Point of the snippet.
                --                 i(0),
                --                 t({ "", "}" }),
                --         }),
                --
                --         s("transform", {
                --                 i(1, "initial text"),
                --                 t({ "", "" }),
                --                 -- lambda nodes accept an l._1,2,3,4,5, which in turn accept any string transformations.
                --                 -- This list will be applied in order to the first node given in the second argument.
                --                 l(l._1:match("[^i]*$"):gsub("i", "o"):gsub(" ", "_"):upper(), 1),
                --         }),
                --
                --         s("trigger", { t("Wow! Text!") }),
                -- }, {
                --         key = "all",
                -- })

                luasnip.config.set_config(opts)
                require("luasnip.loaders.from_vscode").lazy_load()
                require("luasnip.loaders.from_lua").lazy_load({ paths = "C:/Users/prave/AppData/Local/nvim/snippets" })
        end,
}
