local M = {}

-- Table to store cursor positions and visited status for each buffer
local cursor_positions = {}
local visited_buffers = {}

-- Save the current cursor position and window's scroll position for the buffer
local function save_cursor()
	local bufnr = vim.api.nvim_get_current_buf()
	local line = vim.fn.line(".")
	local col = vim.fn.col(".")
	local topline = vim.fn.line("w0")
	cursor_positions[bufnr] = { line = line, col = col, topline = topline }
end

-- Restore the saved cursor position and window's scroll position for the buffer
local function restore_cursor()
	local bufnr = vim.api.nvim_get_current_buf()
	if not visited_buffers[bufnr] then
		-- Mark the buffer as visited and do not restore the cursor position
		visited_buffers[bufnr] = true
		return
	end
	local pos = cursor_positions[bufnr]
	if not pos then
		return
	end

	-- Restore cursor position
	vim.api.nvim_win_set_cursor(0, { pos.line, pos.col - 1 })
	-- Restore window scroll position
	vim.fn.winrestview({ topline = pos.topline })
end

-- Clean up entries when buffer is deleted
local function clean_up_buffer()
	local bufnr = vim.api.nvim_get_current_buf()
	cursor_positions[bufnr] = nil
	visited_buffers[bufnr] = nil
end

-- Set up autocommands
function M.setup()
	vim.api.nvim_create_autocmd("BufLeave", {
		callback = function()
			save_cursor()
		end,
	})
	vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
		callback = function()
			restore_cursor()
		end,
	})
	vim.api.nvim_create_autocmd("BufDelete", {
		callback = function()
			clean_up_buffer()
		end,
	})
end

return M
