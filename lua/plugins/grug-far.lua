return {
        "MagicDuck/grug-far.nvim",
        config = function()
                require("grug-far").setup({})

                -- normal modes just opens it, visual will prefill the search string with visual selection
                vim.keymap.set({ "n", "v" }, "<leader>sr", function()
                        require("grug-far").open()
                end, { desc = "GrugFar: open search UI" })

                --
                vim.keymap.set("v", "<leader>sv", function()
                        vim.cmd("GrugFarWithin")
                end, { desc = "GrugFarWithin: search in visual selection" })
        end,
}
