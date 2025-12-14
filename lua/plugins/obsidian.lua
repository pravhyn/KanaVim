return {
        {
                "obsidian-nvim/obsidian.nvim",
                version = "*",
                ft = "markdown",
                event = { "BufReadPre *.md", "BufNewFile *.md" },
                ---@module 'obsidian'
                ---@type obsidian.config
                opts = {
                        legacy_commands = false,
                        ui = {
                                enable = false,
                        },

                        completion = {
                                blink = true,
                        },
                        workspaces = {
                                {
                                        name = "KnowLedge",
                                        path = "~/Projects/obsidianVaults/Wisdom",
                                },
                        },

                        templates = {
                                subdir = "templates",
                                date_format = "%Y-%m-%d",
                                time_format = "%H:%M:%S",
                        },

                        picker = {
                                name = "snacks.pick",
                        },
                        notes_subdir = "zettel",
                },
        },
        -- {
        --
        --         "MeanderingProgrammer/render-markdown.nvim",
        --         dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
        --         -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' }, -- if you use standalone mini plugins
        --         -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        --         ---@module 'render-markdown'
        --         ---@type render.md.UserConfig
        --         opts = {
        --
        --                 -- latex = {
        --                 --         enabled = false,
        --                 -- },
        --         },
        -- },
        --
        -- For `plugins/markview.lua` users.
        {
                "OXY2DEV/markview.nvim",
                lazy = false,

                -- Completion for `blink.cmp`
                -- dependencies = { "saghen/blink.cmp" },
        },
}
