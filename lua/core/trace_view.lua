local M = {}

local buf = nil
local win = nil

local content_lines = {}

local function ensure_buf() -- ensure if before is created or not
        if buf and vim.api.nvim_buf_is_valid(buf) then
                return buf
        end

        buf = vim.api.nvim_get_current_buf()

        -- buf = vim.api.nvim_create_buf(true, false)
        -- vim.bo[buf].buftype = "nofile"
        -- vim.bo[buf].bufhidden = "wipe"
        -- vim.bo[buf].swapfile = false
        -- vim.bo[buf].modifiable = false
        -- vim.bo[buf].readonly = true
        -- vim.bo[buf].filetype = "traceview"

        return buf
end

local function get_config(side)
        local ui = vim.api.nvim_list_uis()[1]
        local width = ui.width
        local height = ui.height

        if side == "left" then
                return {
                        relative = "editor",
                        row = 0,
                        col = 0,
                        width = math.floor(width * 0.4),
                        height = height,
                }
        elseif side == "right" then
                return {
                        relative = "editor",
                        row = 0,
                        col = math.floor(width * 0.6),
                        width = math.floor(width * 0.4),
                        height = height,
                }
        elseif side == "top" then
                return {
                        relative = "editor",
                        row = 0,
                        col = 0,
                        width = width,
                        height = math.floor(height * 0.35),
                }
        else -- bottom
                return {
                        relative = "editor",
                        row = math.floor(height * 0.65),
                        col = 0,
                        width = width,
                        height = math.floor(height * 0.35),
                }
        end
end

function M.open(side)
        side = side or "right"
        local b = ensure_buf()

        if win and vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_set_config(win, get_config(side))
                vim.api.nvim_set_current_win(win)
                return
        end

        win = vim.api.nvim_open_win(
                b,
                true,
                vim.tbl_extend("force", {
                        style = "minimal",
                        border = "rounded",
                        focusable = true,
                }, get_config(side))
        )
        -- local joined_lines = table.concat(content_lines, ",")

        -- local c_buf = vim.api.nvim_get_current_buf() --  returns c_buf id
end

function M.close()
        if win and vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
                win = nil
        end
end

function M.set_lines(lines)
        local b = ensure_buf()
        vim.bo[b].modifiable = true
        vim.api.nvim_buf_set_lines(b, 0, -1, false, lines)
        vim.bo[b].modifiable = false
end

-- local trace = require("trace_view")

vim.keymap.set("n", "<leader>[t", function()
        -- table.insert(content_lines, c_lines)
        M.open("right")
end, { desc = "Trace view: open" })

vim.keymap.set("n", "<leader>[h", function()
        M.open("left")
end, { desc = "Trace view: left" })

vim.keymap.set("n", "<leader>[l", function()
        M.open("right")
end, { desc = "Trace view: right" })

vim.keymap.set("n", "<leader>[k", function()
        M.open("top")
end, { desc = "Trace view: top" })

vim.keymap.set("n", "<leader>[j", function()
        M.open("bottom")
end, { desc = "Trace view: bottom" })

vim.keymap.set("n", "q", function()
        M.close()
end, { desc = "Trace view: close" })
