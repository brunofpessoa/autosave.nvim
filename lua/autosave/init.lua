local M = {}

M.opts = {
    included_dirs = {},
    excluded_dirs = {},
    delay = 500,
    show_notifications = false,
    messages = {
        success = "File successfully saved: %s",
        failure = "Failed to save file: %s\nError: %s",
    },
}

local save_list = {}
local timer = vim.uv.new_timer()

local function add_to_save_list(file, buf)
    save_list[file] = buf
end

local function is_in_save_list(file)
    return save_list[file] ~= nil
end

local function is_in_excluded_dir(file)
    for _, excluded_dir in pairs(M.opts.excluded_dirs) do
        if file:find(vim.fn.expand(excluded_dir)) then
            return true
        end
    end
end

local function get_current_file_and_buffer()
    local buf = vim.api.nvim_get_current_buf()
    local file_path = vim.api.nvim_buf_get_name(buf)

    if not file_path then
        return
    end

    if not vim.api.nvim_buf_get_option(buf, "modifiable") then
        return
    end

    return buf, file_path
end

local function save_files()
    for file, buf in pairs(save_list) do
        vim.api.nvim_buf_call(buf, function()
            local success, err = pcall(vim.api.nvim_command, string.format("silent! write %s", file))
            if M.opts.show_notifications then
                local msg = success and
                    string.format(M.opts.messages.success, file) or
                    string.format(M.opts.messages.failure, file, err)
                vim.notify(msg, success and vim.log.levels.INFO or vim.log.levels.ERROR, { title = "Autosave" })
            end
        end)
    end
    save_list = {}
end

local function schedule_save()
    if timer then
        timer:stop()
    end
    timer:start(M.opts.delay, 0, function()
        timer:stop()
        vim.schedule(save_files)
    end)
end

local function run()
    local buf, file = get_current_file_and_buffer()
    if not file or not buf then
        return
    end

    for _, dir in pairs(M.opts.included_dirs) do
        if file:find(vim.fn.expand(dir)) and not is_in_excluded_dir(file) then
            if not is_in_save_list(file) then
                add_to_save_list(file, buf)
            end
        end
    end

    if next(save_list) ~= nil then
        schedule_save()
    end
end

local function setup_autocmd()
    vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
        group = vim.api.nvim_create_augroup("autosave_files", { clear = true }),
        callback = run,
        desc = "Auto save files when leaving insert mode or changing text in normal mode",
    })
end

function M.setup(opts)
    M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
    setup_autocmd()
end

return M
