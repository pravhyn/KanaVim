local function get_project_root()
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        if git_root and git_root ~= "" then
                return git_root
        end
        return vim.fn.getcwd()
end

local function smart_gf()
        local target = vim.fn.expand("<cfile>")
        if target == "" then
                vim.notify("No file under cursor", vim.log.levels.WARN)
                return
        end

        -- Convert lua module path → file path
        if not target:match("/") and target:match("%.") then
                target = target:gsub("%.", "/") .. ".lua"
        end

        local root = get_project_root()

        -- Force into lua/ directory (Lazy convention)
        local full_path = root .. "/lua/" .. target
        full_path = vim.fn.fnamemodify(full_path, ":p")

        -- ✅ If exists → open
        if vim.loop.fs_stat(full_path) then
                vim.cmd("edit " .. vim.fn.fnameescape(full_path))
                return
        end

        -- ❓ Ask before creation
        vim.ui.select({ "Yes", "No" }, {
                prompt = "Create missing file?\n" .. full_path,
        }, function(choice)
                if choice ~= "Yes" then
                        vim.notify("Canceled", vim.log.levels.INFO)
                        return
                end

                -- Create parent dirs
                vim.fn.mkdir(vim.fn.fnamemodify(full_path, ":h"), "p")

                -- Create file
                local fd = io.open(full_path, "w")
                if fd then
                        fd:close()
                end

                vim.cmd("edit " .. vim.fn.fnameescape(full_path))
        end)
end

vim.keymap.set("n", "gf", smart_gf, { desc = "Smart gf (root-based, lazy-safe)" })
