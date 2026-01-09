return {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
                "MunifTanjim/nui.nvim",
                "rcarriga/nvim-notify",
        },
        opts = {
                lsp = {
                        signature = {
                                auto_open = { enabled = false },
                        },
                },

                cmdline = {
                        view = "cmdline_popup",
                },
                messages = {
                        view = "mini",
                },
        },
}
