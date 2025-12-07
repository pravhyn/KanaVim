return {
        "MagicDuck/grug-far.nvim",
        config = function()
                require("grug-far").setup({})

                vim.keymap.set({ "n", "v" }, "<leader>sr", function()
                        require("grug-far").open()
                end, { desc = "GrugFar: open search UI" })

                vim.keymap.set("v", "<leader>sv", function()
                        require("grug-far").open({ within = true })
                end, { desc = "GrugFarWithin: search in visual selection" })
        end,
}
