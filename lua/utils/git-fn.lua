local M = {}
-- local Input = require("nui.input")
local Layout = require("nui.layout")
local Popup = require("nui.popup")

local function create_ui()
        local popup = Popup({
                enter = true,
                border = {
                        style = "single",
                        text = {
                                top = "[Y to Commit]",
                                top_align = "center",
                        },
                },
        })

        local layout = Layout(
                {
                        relative = "editor",
                        position = "50%",
                        size = { width = 100, height = 30 },
                },
                Layout.Box({
                        Layout.Box(popup, { size = "100%" }),
                }, { dir = "col" })
        )

        return popup, layout
end
-- local result_box = Popup({
--         enter = true,
--         border = {
--                 style = "single",
--                 text = {
--                         top = "[Y to Commit]",
--                         top_align = "center",
--                 },
--         },
-- })
-- local layout = Layout(
--         {
--                 relative = "editor",
--                 position = "50%",
--                 size = {
--                         width = 100,
--                         height = 30,
--                 },
--         },
--         Layout.Box({
--                 Layout.Box(result_box, { size = "100%" }),
--                 -- Layout.Box(result_box, { size = "90%" }),
--         }, { dir = "col" })
-- )
function M.confirm_box(cmd)
        local result_box, layout = create_ui()
        local on_exit = function(obj)
                local str_list = {}
                if obj.code ~= 0 then
                        vim.notify("Error while git diff --staged")
                        return
                end

                if obj.stdout == "" then
                        vim.notify("There is nothing to commit")
                        return
                else
                        local stdout = obj.stdout

                        for line in string.gmatch(stdout, "([^\n]+)") do
                                table.insert(str_list, line)
                        end

                        vim.schedule(function()
                                vim.api.nvim_buf_set_lines(result_box.bufnr, 0, -1, false, str_list)
                                layout:mount()

                                vim.bo[result_box.bufnr].filetype = "diff"

                                result_box:map("n", "<Esc>", function()
                                        result_box:unmount()
                                end, { noremap = true })

                                result_box:map("n", "q", function()
                                        result_box:unmount()
                                end, { noremap = true })

                                result_box:map("n", "Y", function()
                                        local msg = vim.fn.input("Commit Message: ")
                                        if msg == nil or msg == "" then
                                                vim.notify("Empty commit message. Commit abored")
                                                return
                                        end

                                        local result = vim.fn.system({ "git", "commit", "-m", msg })

                                        result_box:unmount()
                                        if vim.v.shell_error ~= 0 then
                                                vim.notify("Commit failed", vim.log.levels.ERROR)
                                        else
                                                vim.notify("commit staged")
                                        end
                                end, { noremap = true })
                        end)
                end
        end

        local obj = vim.system(cmd, { text = true }, on_exit)
end

-- result_box:map("n", "Y", function()
-- end, { noremap = true })

-- M.confirm_box({ "git", "diff", "--staged" })

vim.keymap.set("n", "<leader>hc", function()
        M.confirm_box({ "git", "diff", "--staged" })
end, {
        desc = "show staged diff → commit",
})
