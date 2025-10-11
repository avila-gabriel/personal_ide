return {
	"stevearc/conform.nvim",
	main = "conform",
	event = { "BufWritePre" },
	ft = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json" },
	opts = {
		formatters_by_ft = {
			javascript = { "biome" },
			typescript = { "biome" },
			javascriptreact = { "biome" },
			typescriptreact = { "biome" },
			json = { "biome" },
		},
		formatters = {
			biome = {
				command = "biome",
				args = { "format", "--stdin-file-path", "$FILENAME" },
				stdin = true,
			},
		},
		format_on_save = function(bufnr)
			local ft = vim.bo[bufnr].filetype
			local ok = ({
				javascript = true,
				typescript = true,
				javascriptreact = true,
				typescriptreact = true,
				json = true,
			})[ft]
			if not ok then
				return
			end
			return { lsp_fallback = false, timeout_ms = 1000 }
		end,
	},
	config = function(_, opts)
		require("conform").setup(opts)
	end,
}
