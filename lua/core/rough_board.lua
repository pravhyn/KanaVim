local Layout = require("nui.layout")
local Popup = require("nui.popup")
-- local Input = require("nui.input")
-- local event = require("nui.utils.autocmd").event
local rough = {
        layout = nil,
        popup = nil,
        visible = false,
}
local function rough_board()
        -- already exists → just show
        if rough.layout and not rough.visible then
                print("already exists")
                rough.layout:show()
                rough.visible = true
                return
        end

        -- already visible → do nothing
        if rough.visible then
                print("hiding")
                rough.layout:hide()
                return
        end
        local temporary_buffer = Popup({

                border = {
                        style = "double",
                        text = {
                                top = "rough_board",
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

        rough.popup = temporary_buffer
        rough.layout = layout
        rough.visible = true
        local bufnr = temporary_buffer.bufnr

        -- close on <Esc>
        vim.keymap.set("n", "<Esc>", function()
                temporary_buffer:hide()
                rough.visible = false
        end, { noremap = true, buffer = bufnr })

        -- close on q
        vim.keymap.set("n", "<leader>q", function()
                temporary_buffer:unmount()
        end, { noremap = true, buffer = bufnr })

        -- copies entire board text into clipboard
        vim.keymap.set("n", "<localleader>p", function()
                vim.cmd([[ %y+ ]])
                vim.notify("Copied entire buffer to clipboard")
        end, { noremap = true, buffer = bufnr })
end

-- 🔥KEYMAP
vim.keymap.set("n", "<leader>cb", rough_board, { desc = "open rough_board" })
