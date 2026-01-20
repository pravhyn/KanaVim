local M = {}
-- local Input = require("nui.input")
local Layout = require("nui.layout")
local Popup = require("nui.popup")

local result_box = Popup({
        enter = true,
        border = {
                style = "single",
                text = {
                        -- top = "Lol",
                        -- top_align = "left",
                },
        },
})

function M.confirm_box(cmd)
        local layout = Layout(
                {
                        relative = "editor",
                        position = "50%",
                        size = {
                                width = 100,
                                height = 30,
                        },
                },
                Layout.Box({
                        Layout.Box(result_box, { size = "100%" }),
                        -- Layout.Box(result_box, { size = "90%" }),
                }, { dir = "col" })
        )

        local on_exit = function(obj)
                local question = { "Y to confirm" }

                vim.api.nvim_buf_set_lines(result_box.bufnr, 0, -1, false, results)
        end

        local obj = vim.system(cmd, { text = true }):wait()
        local stdout = obj.stdout

        if obj.code == 0 then
                local str_list = { "Y to confirm" }
                if stdout == nil then
                        stdout = "empty"
                end

                for line in string.gmatch(stdout, "//n") do
                        table.insert(str_list, line)
                end

                vim.api.nvim_buf_set_lines(result_box.bufnr, 0, -1, false, str_list)
        end

        if stdout ~= "empty" or nil then
                vim.notify("There is nothing to stage")
        else
                layout:mount()
                local msg = vim.fn.input("Commit Message: ")
                if msg == nil or msg == "" then
                        vim.notify("Empty commit message. Commit abored")
                        return
                end

                local result = vim.fn.system({ "git", "commit", "-m", msg })

                if result.code ~= 0 then
                        vim.notify(result)
                else
                        vim.notify("commit staged")
                end
        end

        result_box:map("n", "<Esc>", function()
                result_box:unmount()
        end, { noremap = true })

        -- result_box:map("n", "Y", function()
        -- end, { noremap = true })
end

M.confirm_box({ "git", "diff", "--staged" })
