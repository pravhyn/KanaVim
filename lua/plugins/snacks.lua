return {
        "folke/snacks.nvim",
        opts = {
                notifier = { enabled = true },
                image = { enabled = true },
                bigfile = { enabled = true },
                explorer = { enabled = true },
                indent = { enabled = true },
                input = { enabled = true },
                quickfile = { enabled = true },
                statuscolumn = { enabled = false },

                words = { enabled = false },
                rename = { enabled = false },
                zen = { enabled = false },
                dashboard = {
                        enabled = true,
                        sections = {

                                { section = "header" },

                                {
                                        section = "projects",
                                        limit = 5,
                                        cwd = false,
                                },
                                {
                                        section = "recent_files",
                                        limit = 8,
                                },
                                {
                                        section = "session",
                                },
                                {
                                        section = "keys",
                                        gap = 1,
                                        padding = 1,
                                },
                        },
                },
                animate = {
                        enabled = false,
                        -- -@type snacks.animate.Duration|number,
                        duration = 20, -- ms per step
                        easing = "linear",
                        fps = 60, -- frames per second. Global setting for all animations
                },

                picker = {
                        enabled = true,
                },
                trouble = {
                        enabled = true,
                },
        },
}
