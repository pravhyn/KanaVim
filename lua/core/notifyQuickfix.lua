-- lua/notify_to_qf.lua

local notify = require("notify")

vim.notify = function(msg, level, opts)
        -- still show the notification normally
        notify(msg, level, opts)

        -- only handle live errors
        if level ~= vim.log.levels.ERROR then
                return
        end

        -- extract first <file>:<line> occurrence
        local file, line = msg:match("([A-Za-z]:[/\\%w%._%-]+%.%w+):(%d+)") or msg:match("(%S+%.%w+):(%d+)")

        if file and line then
                vim.fn.setqflist({}, "a", {
                        title = "Notifications",
                        items = {
                                {
                                        filename = file,
                                        lnum = tonumber(line),
                                        col = 1,
                                        text = msg,
                                        type = "E",
                                },
                        },
                })
        else
                -- fallback: no file detected → still log text
                vim.fn.setqflist({}, "a", {
                        title = "Notifications",
                        items = {
                                {
                                        text = msg,
                                        type = "E",
                                },
                        },
                })
        end
end
