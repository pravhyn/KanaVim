local M = {}

--- opens the file as buffer
---@param path string accepts absolute path strings, and opens the file as buffer
local function open_path(path)
        if not path or path == "" then
                return
        end

        -- strip Windows CR if still present
        path = path:gsub("\r", "")

        -- normalize slashes (optional but nice)
        path = vim.fn.fnamemodify(path, ":p")

        vim.cmd("edit " .. vim.fn.fnameescape(path))
end

--- returns absolute path as string
---@param path string accepts absolute path strings, and opens the file as buffer
local function notify_path(path)
        if not path or path == "" then
                return
        end

        path = path:gsub("\r", "")
        path = vim.fn.fnamemodify(path, ":p")

        vim.notify(path, vim.log.levels.INFO, {
                title = "Selected path",
        })
end

--- opens the file in file explorer
---@param path string accepts absolute path strings, and opens the file in File explorer
local function open_in_file_explorer(path)
        if not path or path == "" then
                return
        end

        -- sanitize
        path = path:gsub("\r", "")
        path = vim.fn.fnamemodify(path, ":p")

        local target = path

        -- if it's a file, open parent directory
        if vim.fn.filereadable(path) == 1 then
                target = vim.fn.fnamemodify(path, ":h")
        end

        -- Windows
        if vim.fn.has("win32") == 1 then
                vim.fn.jobstart({ "explorer", target }, { detach = true })

        -- macOS
        elseif vim.fn.has("mac") == 1 then
                vim.fn.jobstart({ "open", target }, { detach = true })

        -- Linux / BSD
        else
                vim.fn.jobstart({ "xdg-open", target }, { detach = true })
        end
end
return M
