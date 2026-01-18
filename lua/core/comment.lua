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
        local col = vim.fn.col(".") -- 1-based
        local line = vim.fn.getline(".")

        -- character before cursor
        local prev = col > 1 and line:sub(col - 1, col - 1) or ""

        -- Only expand at start or after whitespace
        if col == 1 or prev:match("%s") then
                local cs = vim.bo.commentstring
                if not cs or cs == "" then
                        return ";;"
                end

                -- extract comment leader
                local leader = cs:match("^(.-)%s*%%s") or cs
                return leader .. " "
        end

        return ";;"
end, { expr = true, desc = "Universal inline comment with safety" })
