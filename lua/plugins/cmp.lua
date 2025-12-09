-- return {
--   -- LuaSnip snippet engine
--   {
--     "L3MON4D3/LuaSnip",
--     version = "v2.*",
--     build = "make install_jsregexp",
--     dependencies = {
--       "rafamadriz/friendly-snippets",
--       "saadparwaiz1/cmp_luasnip",
--     },
--     config = function()
--       require("luasnip.loaders.from_vscode").lazy_load()
--     end,
--   },

--   -- nvim-cmp completion engine
--   {
--     "hrsh7th/nvim-cmp",
--     dependencies = {
--       "saadparwaiz1/cmp_luasnip",
--       "hrsh7th/cmp-buffer",
--       "hrsh7th/cmp-path",
--       "hrsh7th/cmp-nvim-lsp",
--     },
--     config = function()
--       local cmp = require("cmp")
--       local luasnip = require("luasnip")

--       cmp.setup({
--         snippet = {
--           expand = function(args)
--             luasnip.lsp_expand(args.body)
--           end,
--         },
--         mapping = cmp.mapping.preset.insert({
--           ["<C-b>"] = cmp.mapping.scroll_docs(-4),
--           ["<C-f>"] = cmp.mapping.scroll_docs(4),
--           ["<C-Space>"] = cmp.mapping.complete(),
--           ["<C-e>"] = cmp.mapping.abort(),
--           ["<CR>"] = cmp.mapping.confirm({ select = true }),
--           ["<Tab>"] = cmp.mapping(function(fallback)
--             if cmp.visible() then
--               cmp.select_next_item()
--             elseif luasnip.expand_or_jumpable() then
--               luasnip.expand_or_jump()
--             else
--               fallback()
--             end
--           end, { "i", "s" }),
--           ["<S-Tab>"] = cmp.mapping(function(fallback)
--             if cmp.visible() then
--               cmp.select_prev_item()
--             elseif luasnip.jumpable(-1) then
--               luasnip.jump(-1)
--             else
--               fallback()
--             end
--           end, { "i", "s" }),
--         }),
--         sources = cmp.config.sources({
--           { name = "nvim_lsp" },
--           { name = "luasnip" }, -- This is crucial for snippets to appear
--           { name = "buffer" },
--           { name = "path" },
--         }),
--       })
--     end,
--   },
-- }
local trigger_text = ";"

return {
        {
                "saghen/blink.cmp",
                lazy = false,
                version = "1.*",
                dependencies = {
                        "moyiz/blink-emoji.nvim",
                        -- "Kaiser-Yang/blink-cmp-dictionary",
                        -- {
                        -- 	"folke/lazydev.nvim",
                        -- 	ft = "lua",
                        -- 	config = true,
                        -- },
                },
                event = { "InsertEnter" },
                build = "cargo build --release",
                opts = {
                        snippets = {
                                preset = "luasnip",
                                expand = function(snippet)
                                        require("luasnip").lsp_expand(snippet)
                                end,

                                active = function(filter)
                                        if filter and filter.direction then
                                                return require("luasnip").jumpable(filter.direction)
                                        end
                                        return require("luasnip").in_snippet()
                                end,
                                jump = function(direction)
                                        require("luasnip").jump(direction)
                                end,
                        }, -- delegates expansion to LuaSnip
                        sources = {
                                default = { "lazydev", "lsp", "path", "snippets", "buffer", "emoji" },

                                providers = {

                                        lazydev = {
                                                name = "LazyDev",
                                                module = "lazydev.integrations.blink",
                                                -- make lazydev completions top priority (see `:h blink.cmp`)
                                                score_offset = 100,
                                        },

                                        lsp = {
                                                name = "lsp",
                                                enabled = true,
                                                module = "blink.cmp.sources.lsp",
                                                -- menu = "[LSP]",
                                                min_keyword_length = 0,
                                                -- When linking markdown notes, I would get snippets and text in the
                                                -- suggestions, I want those to show only if there are no LSP
                                                -- suggestions
                                                --
                                                -- Enabled fallbacks as this seems to be working now
                                                -- Disabling fallbacks as my snippets wouldn't show up when editing
                                                -- lua files
                                                -- fallbacks = { "snippets", "buffer" },
                                                score_offset = 90, -- the higher the number, the higher the priority
                                        },
                                        path = {
                                                name = "Path",
                                                module = "blink.cmp.sources.path",
                                                score_offset = 25,
                                                -- When typing a path, I would get snippets and text in the
                                                -- suggestions, I want those to show only if there are no path
                                                -- suggestions
                                                fallbacks = { "snippets", "buffer" },
                                                -- min_keyword_length = 2,
                                                opts = {
                                                        trailing_slash = false,
                                                        label_trailing_slash = true,
                                                        get_cwd = function(context)
                                                                local buffer_dir =
                                                                        vim.fn.expand(("#%d:p:h"):format(context.bufnr))
                                                                local cwd = vim.fn.getcwd()

                                                                -- Prefer buffer's directory if it's valid
                                                                if vim.fn.isdirectory(buffer_dir) == 1 then
                                                                        return buffer_dir
                                                                else
                                                                        return cwd
                                                                end
                                                        end,
                                                        show_hidden_files_by_default = true,
                                                },
                                        },
                                        buffer = {
                                                name = "Buffer",
                                                enabled = true,
                                                max_items = 3,
                                                module = "blink.cmp.sources.buffer",
                                                min_keyword_length = 2,
                                                score_offset = 15, -- the higher the number, the higher the priority
                                        },
                                        -- https://github.com/moyiz/blink-emoji.nvim
                                        emoji = {
                                                module = "blink-emoji",
                                                name = "Emoji",
                                                score_offset = 93, -- the higher the number, the higher the priority
                                                min_keyword_length = 2,
                                                opts = { insert = true }, -- Insert emoji (default) or complete its name
                                        },

                                        snippets = {
                                                name = "snippets",
                                                enabled = true,
                                                max_items = 15,
                                                min_keyword_length = 2,
                                                module = "blink.cmp.sources.snippets",
                                                score_offset = 100,

                                                should_show_items = function()
                                                        local col = vim.api.nvim_win_get_cursor(0)[2]
                                                        local before_cursor =
                                                                vim.api.nvim_get_current_line():sub(1, col)
                                                        return before_cursor:match(trigger_text .. "%w*$") ~= nil
                                                end,

                                                transform_items = function(_, items)
                                                        local line = vim.api.nvim_get_current_line()
                                                        local col = vim.api.nvim_win_get_cursor(0)[2]
                                                        local before_cursor = line:sub(1, col)
                                                        local start_pos, end_pos = before_cursor:find(
                                                                trigger_text .. "[^" .. trigger_text .. "]*$"
                                                        )
                                                        if start_pos then
                                                                for _, item in ipairs(items) do
                                                                        if not item.trigger_text_modified then
                                                                                item.trigger_text_modified = true
                                                                                item.textEdit = {
                                                                                        newText = item.insertText
                                                                                                or item.label,
                                                                                        range = {
                                                                                                start = {
                                                                                                        line = vim.fn.line(
                                                                                                                "."
                                                                                                        )
                                                                                                                - 1,
                                                                                                        character = start_pos
                                                                                                                - 1,
                                                                                                },
                                                                                                ["end"] = {
                                                                                                        line = vim.fn.line(
                                                                                                                "."
                                                                                                        )
                                                                                                                - 1,
                                                                                                        character = end_pos,
                                                                                                },
                                                                                        },
                                                                                }
                                                                        end
                                                                end
                                                        end
                                                        return items
                                                end,
                                        },
                                        -- dictionary = {
                                        -- 	module = "blink-cmp-dictionary",
                                        -- 	name = "Dict",
                                        -- 	score_offset = 20, -- the higher the number, the higher the priority
                                        -- 	-- https://github.com/Kaiser-Yang/blink-cmp-dictionary/issues/2
                                        -- 	enabled = true,
                                        -- 	max_items = 8,
                                        -- 	min_keyword_length = 3,
                                        -- 	opts = {
                                        -- 		-- -- The dictionary by default now uses fzf, make sure to have it
                                        -- 		-- -- installed
                                        -- 		-- -- https://github.com/Kaiser-Yang/blink-cmp-dictionary/issues/2
                                        -- 		--
                                        -- 		-- Do not specify a file, just the path, and in the path you need to
                                        -- 		-- have your .txt files
                                        -- 		dictionary_directories = {
                                        -- 			vim.fn.expand("C:/Users/prave/dictionaries"),
                                        -- 		},
                                        -- 		dictionary_files = {
                                        -- 			vim.fn.expand("C:/Users/prave/dictionaries/en.utf-8.add"),
                                        -- 		},
                                        --
                                        -- 		-- --  NOTE: To disable the definitions uncomment this section below
                                        -- 		--
                                        -- 		-- separate_output = function(output)
                                        -- 		--   local items = {}
                                        -- 		--   for line in output:gmatch("[^\r\n]+") do
                                        -- 		--     table.insert(items, {
                                        -- 		--       label = line,
                                        -- 		--       insert_text = line,
                                        -- 		--       documentation = nil,
                                        -- 		--     })
                                        -- 		--   end
                                        -- 		--   return items
                                        -- 		-- end,
                                },
                        },
                        keymap = {
                                preset = "enter",
                                ["<Tab>"] = { "snippet_forward", "fallback" },
                                ["<S-Tab>"] = { "snippet_backward", "fallback" },

                                ["<Up>"] = { "select_prev", "fallback" },
                                ["<Down>"] = { "select_next", "fallback" },
                                ["<C-p>"] = { "select_prev", "fallback" },
                                ["<C-n>"] = { "select_next", "fallback" },

                                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                                ["<C-f>"] = { "scroll_documentation_down", "fallback" },

                                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                                ["<C-e>"] = { "hide", "fallback" },
                        },
                        fuzzy = { implementation = "prefer_rust_with_warning" },
                        signature = { enabled = true },
                        appearance = {
                                nerd_font_variant = "mono",
                        },
                        -- menu = {
                        --   border = "single",
                        -- },
                        -- documentation = {
                        --   auto_show = true,
                        --   window = {
                        --     border = "single",
                        --   },
                        -- },
                },
        },
}
