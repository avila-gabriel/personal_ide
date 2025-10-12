local M = {}

local AU = vim.api.nvim_create_augroup("DiagBridge", { clear = true })

local function send(ev, payload)
	local ch = vim.g._diag_sink_chan
	if ch then
		vim.rpcnotify(ch, ev, payload)
	end
end

local function all_diags()
	local acc = {}
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		acc[b] = vim.diagnostic.get(b)
	end
	return acc
end

local function focused_here()
	local bufnr = vim.api.nvim_get_current_buf()
	local cur = vim.api.nvim_win_get_cursor(0)
	local lnum, col = cur[1] - 1, cur[2]
	local diags = vim.diagnostic.get(bufnr, { lnum = lnum })
	local hit
	for _, d in ipairs(diags) do
		local sL = d.lnum or lnum
		local eL = d.end_lnum or sL
		local sC = d.col or 0
		local eC = d.end_col or (sL == eL and sC + 1 or sC)
		if lnum >= sL and lnum <= eL and col >= sC and col < eC then
			hit = d
			break
		end
	end
	return { bufnr = bufnr, lnum = lnum, col = col, diag = hit }
end

function M.set_sink(chan) -- set the channel id from your host
	vim.g._diag_sink_chan = chan
	return true
end

function M.enable() -- register autocmds (idempotent)
	vim.api.nvim_clear_autocmds({ group = AU })

	vim.api.nvim_create_autocmd("DiagnosticChanged", {
		group = AU,
		callback = function()
			send("diagnostics:update", all_diags())
		end,
	})

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		group = AU,
		callback = function()
			send("diagnostics:here", focused_here())
		end,
	})

	return true
end

function M.disable() -- optional: turn off events
	vim.api.nvim_clear_autocmds({ group = AU })
	return true
end

return M
