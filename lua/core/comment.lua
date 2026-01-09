vim.keymap.set("n", "<C-g>l", "gcc", { remap = true, silent = true })
vim.keymap.set("v", "<C-g>l", "gc", { remap = true, silent = true })
vim.keymap.set("n", "<C-g>j", function()
        vim.cmd("normal gcc")
        vim.cmd("normal j")
end, { silent = true })
vim.keymap.set("n", "<C-g>k", function()
        vim.cmd("normal gcc")
        vim.cmd("normal k")
end, { silent = true })

vim.keymap.set("i", ";;", function()
        local col = vim.fn.col(".") - 1
        local line = vim.fn.getline(".")
        local before = line:sub(col - 1, col) or ""

        -- Only expand if the char before ;; is whitespace or start of line
        if col == 1 or before:match("%s") then
                local cs = vim.bo.commentstring
                if cs == "" then
                        return ";;"
                end
                local left = cs:match("^(.-)%%s") or cs
                return " " .. left .. " "
        else
                return ";;"
        end
end, { expr = true, desc = "Universal inline comment with safety" })
