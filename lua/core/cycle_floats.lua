local function is_floating(win)
        return vim.api.nvim_win_get_config(win).relative ~= ""
end

local function get_floats()
        local floats = {}

        for _, win in ipairs(vim.api.nvim_list_wins()) do
                local cfg = vim.api.nvim_win_get_config(win)
                if cfg.relative ~= "" then
                        local buf = vim.api.nvim_win_get_buf(win)
                        if vim.bo[buf].buflisted then
                                table.insert(floats, win)
                        end
                end
        end

        return floats
end
local function cycle_floats()
        local floats = get_floats()
        if #floats == 0 then
                return
        end

        local cur = vim.api.nvim_get_current_win()

        for i, win in ipairs(floats) do
                if win == cur then
                        local next = floats[i + 1] or floats[1]
                        vim.api.nvim_set_current_win(next)
                        return
                end
        end

        -- if current window is NOT a float, jump to first float
        vim.api.nvim_set_current_win(floats[1])
end
-- FIX: works fine but my idleClock (shitty work) has problem working with it
vim.keymap.set("n", "<leader>zf", cycle_floats, {
        desc = "Cycle floating windows",
})
