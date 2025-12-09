local code = require("utils.code")
local M = {}

local uv = vim.uv
local fn = vim.fn

-- Paths
local ROOT = fn.getcwd()
local TEST_DIR = ROOT .. "/js_nvim"
local CONFIG_PATH = TEST_DIR .. "/config.json"
local RUN_FILE = TEST_DIR .. "/run.ts"

-- Utils -----------------------------------------------------

local function ensure_dir(path)
        if not uv.fs_stat(path) then
                uv.fs_mkdir(path, 493) -- 755
        end
end

local function read_file(path)
        local fd = uv.fs_open(path, "r", 438)
        if not fd then
                return nil
        end
        local stat = uv.fs_fstat(fd)
        local data = uv.fs_read(fd, stat.size, 0)
        uv.fs_close(fd)
        return data
end

local function write_file(path, content)
        local tmp = path .. ".tmp"
        local fd = uv.fs_open(tmp, "w", 438)
        if not fd then
                return false
        end

        uv.fs_write(fd, content, 0)
        uv.fs_close(fd)
        uv.fs_rename(tmp, path)
        return true
end

-- Config ----------------------------------------------------

local function load_or_create_config()
        ensure_dir(TEST_DIR)

        if not uv.fs_stat(CONFIG_PATH) then
                local dom = fn.input("Path to domString file (ts): ")
                local json = vim.json.encode({ domFile = dom, runtime = "tsx" })
                write_file(CONFIG_PATH, json)
        end

        local txt = read_file(CONFIG_PATH)
        return vim.json.decode(txt)
end

-- Runner Generator ------------------------------------------

local function generate_runner(fn_code, dom_path)
        return string.format(
                [[
import { JSDOM } from "jsdom";
import { domString } from "%s";

%s

const dom = new JSDOM(domString);
const document = dom.window.document;

const result = (typeof test === "function" ? test(document) : null);
console.log("RESULT:", result);
]],
                dom_path,
                fn_code
        )
end

-- Quickfix from stderr --------------------------------------

local function to_quickfix(lines)
        local items = {}
        for _, l in ipairs(lines) do
                table.insert(items, {
                        filename = RUN_FILE,
                        lnum = 1,
                        text = l,
                })
        end
        vim.fn.setqflist(items, "r")
        vim.cmd("copen")
end

-- Main Entry -----------------------------------------------
function M.run()
        local fn_code = Buf.get_visual_selection()
        if fn_code == "" then
                print("No visual selectwon")
                return
        end

        code.repace_text(fn_code, "return true", "console.log('true')")

        local cfg = load_or_create_config()

        local content = generate_runner(fn_code, cfg.domFile)
        write_file(RUN_FILE, content)

        local stderr = {}

        fn.jobstart({ "npx", "tsx", RUN_FILE }, {
                stdout_buffered = true,
                stderr_buffered = true,

                on_stdout = function(_, data)
                        if data then
                                for _, l in ipairs(data) do
                                        if l ~= "" then
                                                print(l)
                                        end
                                end
                        end
                end,

                on_stderr = function(_, data)
                        if data then
                                for _, l in ipairs(data) do
                                        if l ~= "" then
                                                table.insert(stderr, l)
                                        end
                                end
                        end
                end,

                on_exit = function(_, code)
                        if #stderr > 0 then
                                to_quickfix(stderr)
                        else
                                print("DOM test OK")
                        end
                end,
        })
end

-- Keymap ----------------------------------------------------

vim.keymap.set("v", "<leader>dt", function()
        M.run()
end, { desc = "Run DOM test on selection" })

-- return M
