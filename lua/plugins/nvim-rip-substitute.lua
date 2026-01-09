return {
        {
                "chrisgrieser/nvim-rip-substitute",
                cmd = "RipSubstitute",
                opts = {},
                keys = {
                        {
                                "<leader>rs",
                                function()
                                        require("rip-substitute").sub()
                                end,
                                mode = { "n", "x" },
                                desc = " rip substitute",
                        },
                },
        },
        {
                "bennypowers/nvim-regexplainer",
                dependencies = {
                        "nvim-treesitter/nvim-treesitter",
                        "MunifTanjim/nui.nvim",
                },
                opts = {
                        display = {
                                mode = "popup",
                        },
                },
        },
}
