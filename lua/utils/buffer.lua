---@class Buf
M = M or {}

local uv = vim.uv
local fn = vim.fn

-- buffer name only (no path, no extension)
function M.name(buf)
        buf = buf or 0
        local full = vim.api.nvim_buf_get_name(buf)
        if full == "" then
                return ""
        end
        return vim.fn.fnamemodify(full, ":t:r")
end

--- checks if bufnr exists or not
---@param buf number -- bufnr to check
---@return boolean
function M.buf_exist(buf)
        if vim.api.nvim_buf_is_valid(buf) then
                return true
        end

        return false
end

--- use for checking fileTypes
---@param buf? integer -- Optional Buf no (0 = current Buffer)
---@return string --- ex "python", "lua"
function M.ft(buf)
        buf = buf or 0
        return vim.bo[buf].filetype or ""
end
function M.filename(buf)
        buf = buf or 0
        local full = vim.api.nvim_buf_get_name(buf)
        return full ~= "" and vim.fn.fnamemodify(full, ":t") or ""
end

function M.get_visual_selection()
        local _, ls, cs = unpack(vim.fn.getpos("'<"))
        local _, le, ce = unpack(vim.fn.getpos("'>"))

        local lines = vim.fn.getline(ls, le)
        if #lines == 0 then
                return ""
        end

        lines[#lines] = string.sub(lines[#lines], 1, ce)
        lines[1] = string.sub(lines[1], cs)

        return table.concat(lines, "\n")
end

function M.ensure_dir(path)
        if not uv.fs_stat(path) then
                uv.fs_mkdir(path, 493) -- 755
        end
end

function M.read_file(path)
        local fd = uv.fs_open(path, "r", 438)
        if not fd then
                return nil
        end
        local stat = uv.fs_fstat(fd)
        local data = uv.fs_read(fd, stat.size, 0)
        uv.fs_close(fd)
        return data
end

function M.write_file(path, content)
        local fd = uv.fs_open(path, "w", 438)
        if not fd then
                return false
        end

        uv.fs_write(fd, content, 0)
        uv.fs_close(fd)
        return true
end

return M
