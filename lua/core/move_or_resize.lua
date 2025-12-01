local function current_width_pct()
        local win = vim.api.nvim_get_current_win()
        local w = vim.api.nvim_win_get_width(win)
        local total = vim.o.columns
        return (w / total) * 100
end

local function current_height_pct()
        local win = vim.api.nvim_get_current_win()
        local h = vim.api.nvim_win_get_height(win)
        local total = vim.o.lines
        return (h / total) * 100
end

local function nearest(current_size)
        if current_size <= 69.999 then
                return 0.7
        end
        if current_size >= 72 then
                return 0.85
        end
end
local function smart_win_nav_or_resize(dir)
        local win_before = vim.api.nvim_get_current_win()

        if dir == "m" then
                local current_buffer_width = current_width_pct()
                local win = vim.api.nvim_get_current_win()
                local total = vim.o.columns
                local calc_size = nearest(current_buffer_width)
                vim.api.nvim_win_set_width(win, math.floor(total * calc_size))

                local current_buffer_height = current_height_pct()
                win = vim.api.nvim_get_current_win()
                total = vim.o.lines
                calc_size = nearest(current_buffer_height)
                vim.api.nvim_win_set_height(win, math.floor(total * calc_size))
        end

        -- Try to move
        vim.cmd("wincmd " .. dir)

        local win_after = vim.api.nvim_get_current_win()

        -- If we didn't move, resize instead
        if win_before == win_after then
                if dir == "h" then
                        local current_buffer_width = current_width_pct()
                        local win = vim.api.nvim_get_current_win()
                        local total = vim.o.columns
                        local calc_size = nearest(current_buffer_width)
                        vim.api.nvim_win_set_width(win, math.floor(total * calc_size))
                        -- vim.cmd("vertical resize +5")
                elseif dir == "l" then
                        local current_buffer_width = current_width_pct()
                        local win = vim.api.nvim_get_current_win()
                        local total = vim.o.columns
                        local calc_size = nearest(current_buffer_width)
                        vim.api.nvim_win_set_width(win, math.floor(total * calc_size))
                        -- vim.cmd("vertical resize +5")
                elseif dir == "j" then
                        local current_buffer_height = current_height_pct()
                        local win = vim.api.nvim_get_current_win()
                        local total = vim.o.lines
                        local calc_size = nearest(current_buffer_height)
                        vim.api.nvim_win_set_height(win, math.floor(total * calc_size))
                        -- vim.cmd("resize +3")
                elseif dir == "k" then
                        local current_buffer_height = current_height_pct()
                        local win = vim.api.nvim_get_current_win()
                        local total = vim.o.lines
                        local calc_size = nearest(current_buffer_height)
                        vim.api.nvim_win_set_height(win, math.floor(total * calc_size))
                        -- vim.cmd("resize +3")
                end
        end
end

vim.keymap.set("n", "<C-w>h", function()
        smart_win_nav_or_resize("h")
end)
vim.keymap.set("n", "<C-w>l", function()
        smart_win_nav_or_resize("l")
end)
vim.keymap.set("n", "<C-w>j", function()
        smart_win_nav_or_resize("j")
end)
vim.keymap.set("n", "<C-w>k", function()
        smart_win_nav_or_resize("k")
end)
vim.keymap.set("n", "<C-w>m", function()
        smart_win_nav_or_resize("m")
end)
