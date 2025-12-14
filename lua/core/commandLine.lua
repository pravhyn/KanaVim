-- keymap to execute a temporary buffer to paste the commands from ai to run
local Layout = require("nui.layout")
local Popup = require("nui.popup")
-- local Input = require("nui.input")
-- local event = require("nui.utils.autocmd").event

local function command_line_runner()
        local temporary_buffer = Popup({

                border = {
                        style = "double",
                        text = {
                                top = "CommandLine Runner",
                                top_align = "center",
                        },
                },
                enter = true,
        })

        local layout = Layout(
                {
                        relative = "editor",
                        position = "50%",
                        size = {
                                width = 150,
                                height = 30,
                        },
                },
                Layout.Box({
                        Layout.Box(temporary_buffer, { size = "100%" }),
                })
        )

        layout:mount()
        local bufnr = temporary_buffer.bufnr

        -- close on <Esc>
        vim.keymap.set("n", "<Esc>", function()
                temporary_buffer:unmount()
        end, { noremap = true, buffer = bufnr })

        -- close on q
        vim.keymap.set("n", "q", function()
                temporary_buffer:unmount()
        end, { noremap = true, buffer = bufnr })

        -- run command under cursor
        vim.keymap.set("n", "<localleader>rn", function()
                local current_line = vim.api.nvim_get_current_line()
                current_line = current_line:gsub("^:", "")
                vim.cmd(current_line)
        end, { noremap = true, buffer = bufnr })
end

-- 🔥KEYMAP
vim.keymap.set("n", "<leader>co", command_line_runner, { desc = "Open Command Box" })
