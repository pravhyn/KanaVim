local selected_picker = "fzf"
-- 🔍 Live Grep
vim.keymap.set("n", "<leader>lg", function()
        require("snacks.picker").grep()
end, { desc = "Live Grep" })

-- 📁 Find Buffers
vim.keymap.set("n", "<leader>fb", function()
        require("fzf-lua").buffers()
end, { desc = "Find Buffers" })

-- 🕘 Find Recent Files
vim.keymap.set("n", "<leader>fr", function()
        require("fzf-lua").oldfiles()
end, { desc = "Find Recent Files" })

-- 📋 Find Registers
vim.keymap.set("n", "<leader>rg", function()
        require("fzf-lua").registers()
end, { desc = "Find Registers" })

-- 🧠 Help Tags
vim.keymap.set("n", "<leader>fh", function()
        require("snacks.picker").help()
end, { desc = "Help" })

vim.keymap.set("n", "<leader>fs", function()
        require("snacks.picker").explorer()
end, { desc = " Snacks Explorer" })

vim.keymap.set({ "n", "v" }, "<leader>cc", function()
        require("snacks.picker").commands()
end, { desc = "Commands" })
-- Assuming snacks.nvim is already loaded and configured
vim.keymap.set("n", "<Space><Space>", function()
        require("snacks.picker").smart()
end, { desc = "Snacks Smart Picker" })

vim.keymap.set("n", "<leader>ft", function()
        require("snacks.picker").notifications()
end, { desc = "Snacks: Notification History" })

vim.keymap.set("n", "<leader>fc", function()
        require("snacks.picker").command_history()
end, { desc = "Command History" })

vim.keymap.set("n", "<leader>lw", function()
        require("snacks.picker").grep_word()
end, { desc = "Grep the selected word" })

vim.keymap.set("n", "<leader>lb", function()
        require("snacks.picker").grep_buffers()
end, { desc = "Grep from buffers" })

vim.keymap.set("n", "<leader>ch", function()
        require("snacks.picker").cliphist()
end)

vim.keymap.set("n", "<leader>gt", function()
        require("snacks.picker").git_stash()
end)
-- Needs to add fzf pickers in this too
vim.keymap.set("n", "<leader>sp", function()
        require("snacks").picker()
end)

vim.keymap.set("n", "<leader>ff", function()
        require("snacks.picker").files()
end)

vim.keymap.set("n", "<leader>fp", function()
        require("snacks.picker")
end)
