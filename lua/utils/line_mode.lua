vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FF00FF", bold = true })

-- vim.api.nvim_create_autocmd("CmdlineEnter", {
--         callback = function()
--                 vim.defer_fn(function()
--                         vim.wo.relativenumber = false
--                         vim.wo.number = true
--                         vim.cmd("redraw")
--                 end, 10)
--         end,
-- })
-- vim.api.nvim_create_autocmd("CmdlineLeave", {
--         callback = function()
--                 -- print("🔙 CmdlineLeave triggered — restoring relative line numbers")
--                 vim.defer_fn(function()
--                         vim.wo.number = true
--                         vim.wo.relativenumber = true
--                 end, 10)
--         end,
-- })

local function is_scratch_buffer()
        local buftype = vim.bo.buftype
        local filetype = vim.bo.filetype
        -- buftype non-empty means special buffer (e.g., "nofile", "terminal")
        if buftype ~= "" then
                return true
        end
        -- Add known scratch filetypes here:
        local scratch_filetypes = {
                "lazy",
                "NvimTree",
                "packer", -- if you use packer UI
                "help",
                "qf", -- quickfix
                "dashboard",
                "fzf", -- fuzzy finder windows
                "terminal",
        }
        for _, ft in ipairs(scratch_filetypes) do
                if filetype == ft then
                        return true
                end
        end
        return false
end

vim.api.nvim_create_autocmd("CmdlineEnter", {
        callback = function()
                if is_scratch_buffer() then
                        return
                end
                vim.defer_fn(function()
                        vim.wo.relativenumber = false
                        vim.wo.number = true
                        vim.cmd("redraw")
                end, 10)
        end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
        callback = function()
                if is_scratch_buffer() then
                        return
                end
                vim.defer_fn(function()
                        vim.wo.number = true
                        vim.wo.relativenumber = true
                end, 10)
        end,
})
