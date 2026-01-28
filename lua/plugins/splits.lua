return {
        -- "hiattp/splitwise.nvim",
        -- commit = "658a1c29575e2f2c27e86a56867f983edeb2795e",
        --
        -- event = "VeryLazy", -- or "BufReadPost" if you want it earlier
        -- config = function()
        --         require("splitwise").setup({
        --                 create_default_keymaps = false,
        --         })
        --         vim.keymap.set("n", "<C-H>", require("splitwise").move_left, { desc = "Splitwise left" })
        --         vim.keymap.set("n", "<C-L>", require("splitwise").move_right, { desc = "Splitwise right" })
        -- end,
        --

        "nvim-focus/focus.nvim",
        version = false,
        config = function()
                -- local focusmap = function(direction)
                --         vim.keymap.set("n", "<Leader>" .. direction, function()
                --                 require("focus").split_command(direction)
                --         end, { desc = string.format("Create or move to split (%s)", direction) })
                -- end
                --
                -- -- Use `<Leader>h` to split the screen to the left, same as command FocusSplitLeft etc
                -- focusmap("h")
                -- focusmap("j")
                -- focusmap("k")
                -- focusmap("l")
        end,
}
