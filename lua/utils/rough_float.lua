local buf_modules = require("utils.buffer")

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
        elseif side == "bottom" then
                return {
                        relative = "editor",
                        row = math.floor(height * 0.65),
                        col = 0,
                        width = width,
                        height = math.floor(height * 0.35),
                }
        else
                return {
                        relative = "editor",
                        row = 0,
                        col = 0,
                        width = width,
                        height = height,
                }
        end
end

local buf = nil
local win = nil
local bufctr = false
---opens a new floating window
---@class FloatingWinOpts
---@field side "left"|"right"|"top"|"bottom" @default "center"
---@field title string
local function open_floating_window(opts)
        opts = opts or {}
        local side = opts.side or "center"

        -- if already exists then
        if buf and vim.api.nvim_buf_is_valid(buf) then
                -- vim.api.nvim_win_set_config(win, get_config(side))
                -- vim.api.nvim_set_current_win(win)

                win = vim.api.nvim_open_win(
                        buf, -- buffer
                        true,
                        vim.tbl_extend("force", {
                                style = "minimal",
                                border = "rounded",
                                focusable = true,
                        }, get_config(side))
                )

                return
        end

        buf = vim.api.nvim_create_buf(true, true)
        vim.treesitter.start(0, "python") -- or lua, c, etc

        win = vim.api.nvim_open_win(
                buf, -- buffer
                true,
                vim.tbl_extend("force", {
                        style = "minimal",
                        border = "rounded",
                        focusable = true,
                }, get_config(side))
        )
end

local function close()
        if win and vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
                -- win = nil
        end
end

local function move(side)
        if buf == nil then
                print("buf is nil can't move bitch")
        end

        vim.api.nvim_win_set_config(0, get_config(side))
end
--  for testing it as of now
vim.keymap.set("n", "<leader>rb", function()
        local opts = {
                side = "right",
                -- source = {
                --         "lol",
                --         "lol_2",
                -- },
                -- -- source = 0,
                title = "rough",
        }
        open_floating_window(opts)
        -- table.insert(content_lines, c_lines)
end, { desc = "Floating: open" })

vim.keymap.set("n", "<leader>[h", function()
        move("left")
end, { desc = "Floating: left" })

vim.keymap.set("n", "<leader>[l", function()
        move("right")
end, { desc = "Floating: right" })

vim.keymap.set("n", "<leader>[k", function()
        move("top")
end, { desc = "Floating: top" })

vim.keymap.set("n", "<leader>[j", function()
        move("bottom")
end, { desc = "Floating: bottom" })

vim.keymap.set("n", "q", function()
        -- if buf == nil then
        --         print("buf is nil")
        --         return
        -- end
        -- if bufctr then
        --         vim.api.nvim_buf_delete(buf, { force = true, unload = false })
        -- end
        -- close()
        local bufnr = buf_modules.hide_float()
end, { desc = "Floating: close" })

vim.keymap.set("n", "<leader><CR>", function() end, { desc = "Hide the buffer" })
