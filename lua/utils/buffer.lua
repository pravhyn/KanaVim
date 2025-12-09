---@class Buf
Buf = Buf or {}

local uv = vim.uv
local fn = vim.fn

-- buffer name only (no path, no extension)
function Buf.name(buf)
        buf = buf or 0
        local full = vim.api.nvim_buf_get_name(buf)
        if full == "" then
                return ""
        end
        return vim.fn.fnamemodify(full, ":t:r")
end

--- use for checking fileTypes
---@param buf? integer -- Optional Buf no (0 = current Buffer)
---@return string --- ex "python", "lua"
function Buf.ft(buf)
        buf = buf or 0
        return vim.bo[buf].filetype or ""
end
function Buf.filename(buf)
        buf = buf or 0
        local full = vim.api.nvim_buf_get_name(buf)
        return full ~= "" and vim.fn.fnamemodify(full, ":t") or ""
end

function Buf.get_visual_selection()
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

function Buf.ensure_dir(path)
        if not uv.fs_stat(path) then
                uv.fs_mkdir(path, 493) -- 755
        end
end

function Buf.read_file(path)
        local fd = uv.fs_open(path, "r", 438)
        if not fd then
                return nil
        end
        local stat = uv.fs_fstat(fd)
        local data = uv.fs_read(fd, stat.size, 0)
        uv.fs_close(fd)
        return data
end

function Buf.write_file(path, content)
        local fd = uv.fs_open(path, "w", 438)
        if not fd then
                return false
        end

        uv.fs_write(fd, content, 0)
        uv.fs_close(fd)
        return true
end
