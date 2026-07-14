local install_languages = {
	"bash",
	"c",
	"c_sharp",
	"javascript",
	"typescript",
	"diff",
	"css",
	"html",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"query",
	"vim",
	"vimdoc",
}

return { -- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	branch = "main",
	lazy = false,
	main = "nvim-treesitter.config",
	init = function()
		local already_installed = require("nvim-treesitter.config").get_installed()
		local needs_install = vim.iter(install_languages)
			:filter(function(lang)
				return not vim.tbl_contains(already_installed, lang)
			end)
			:totable()
		if #needs_install > 0 then
			require("nvim-treesitter").install(needs_install)
		end
	end,
	config = function(_, opts)
		require("nvim-treesitter.config").setup(opts)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function()
				local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
				if not lang then
					return
				end

				-- check if treesitter knows the filetype
				if not require("nvim-treesitter.parsers")[lang] then
					return
				end

				local installed = require("nvim-treesitter.config").get_installed()
				if not vim.tbl_contains(installed, lang) then
					require("nvim-treesitter").install({ lang })
					return
				end

				vim.treesitter.start()
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
