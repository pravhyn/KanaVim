return {
        {
                "echasnovski/mini.move",
                config = function()
                        require("mini.move").setup()
                end,
        },
        {
                "echasnovski/mini.files",
                version = false, -- always use latest
                config = function()
                        require("mini.files").setup({
                                windows = {
                                        preview = true, -- enables preview window
                                        width_focus = 30,
                                        width_preview = 40,
                                },
                                options = {
                                        use_as_default_explorer = false, -- avoids hijacking netrw
                                },
                        })

                        -- Optional: Keymap to open mini.files in current directory
                        vim.keymap.set("n", "<leader>fm", function()
                                require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
                        end, { desc = "Open MiniFiles in current buffer's directory" })
                end,
        },

        {
                "echasnovski/mini.ai",
                version = "*",
                lazy = false, -- or true if you prefer lazy loading
                config = function()
                        require("mini.ai").setup()
                end,
        },

        {
                "nvim-mini/mini.pairs",
                version = false,

                modes = { insert = true, command = false, terminal = false },
        },
        { "nvim-mini/mini.comment", version = false },
        {
                "nvim-mini/mini.surround",
                version = false,
                config = function()
                        require("mini.surround").setup({
                                mappings = {
                                        add = "gs", -- Add surrounding Note: ys is a terrible idea, ruins y experience
                                        delete = "ds", -- Delete surrounding
                                        find = "<leader>sf", -- Find surrounding (right)
                                        find_left = "<leader>sF", -- Find surrounding (left)
                                        highlight = "<leader>sh", -- Highlight surrounding
                                        replace = "cs", -- Replace surrounding

                                        suffix_last = "l", -- Suffix for "prev" method
                                        suffix_next = "n", -- Suffix for "next" method
                                },
                        })
                end,
        },
        {
                "nvim-mini/mini.operators",
                config = function()
                        require("mini.operators").setup({})
                end,
        },
        { "nvim-mini/mini.splitjoin", version = false },
        { "nvim-mini/mini.align", version = false },
        {
                "nvim-mini/mini.test",
                version = false,
                config = function()
                        require("mini.test").setup({

                                collect = {
                                        -- Temporarily emulate functions from 'busted' testing framework
                                        -- (`describe`, `it`, `before_each`, `after_each`, and more)
                                        emulate_busted = true,

                                        -- Function returning array of file paths to be collected.
                                        -- Default: all Lua files in 'tests' directory starting with 'test_'.
                                        find_files = function()
                                                return vim.fn.globpath("tests", "**/test_*.lua", true, true)
                                        end,

                                        -- Predicate function indicating if test case should be executed
                                        filter_cases = function(case)
                                                return true
                                        end,
                                },

                                -- Options for execution of test cases. See `:h MiniTest.execute()`.
                                execute = {
                                        -- Table with callable fields `start()`, `update()`, and `finish()`
                                        reporter = nil,

                                        -- Whether to stop execution after first error
                                        stop_on_error = false,
                                },

                                -- Path (relative to current directory) to script which handles project
                                -- specific test running
                                script_path = "scripts/minitest.lua",

                                -- Whether to disable showing non-error feedback
                                silent = false,
                        })
                end,
        },
}
