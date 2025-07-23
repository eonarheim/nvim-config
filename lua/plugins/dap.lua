OS = {}

---The file system path separator for the current platform.
OS.separator = "\\"

---Split string into a table of strings using a separator.
---Found here https://www.reddit.com/r/neovim/comments/su0em7/comment/hx96ur0/?utm_source=share&utm_medium=web3x
---@param inputString string The string to split.
---@param sep string The separator to use.
---@return table table A table of strings.
OS.split = function(inputString, sep)
	local fields = {}

	local pattern = string.format("([^%s]+)", sep)
	local _ = string.gsub(inputString, pattern, function(c)
		fields[#fields + 1] = c
	end)

	return fields
end

---Joins arbitrary number of paths together.
---Found here https://www.reddit.com/r/neovim/comments/su0em7/comment/hx96ur0/?utm_source=share&utm_medium=web3x
---@param ... string The paths to join.
---@return string
OS.join_path = function(...)
	local args = { ... }
	if #args == 0 then
		return ""
	end

	local all_parts = {}
	if type(args[1]) == "string" and args[1]:sub(1, 1) == OS.separator then
		all_parts[1] = ""
	end

	for _, arg in ipairs(args) do
		arg_parts = OS.split(arg, OS.separator)
		vim.list_extend(all_parts, arg_parts)
	end
	return vim.fs.normalize(table.concat(all_parts, OS.separator))
end
return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"rcarriga/nvim-dap-ui",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		dapui.setup()

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<leader>dc", dap.continue, {})

		vim.keymap.set("n", "<F5>", function()
			dap.continue()
		end)
		vim.keymap.set("n", "<F10>", function()
			dap.step_over()
		end)
		vim.keymap.set("n", "<F11>", function()
			dap.step_into()
		end)
		vim.keymap.set("n", "<F12>", function()
			dap.step_out()
		end)
		vim.keymap.set("n", "<Leader>b", function()
			dap.toggle_breakpoint()
		end)
		vim.keymap.set("n", "<Leader>B", function()
			dap.set_breakpoint()
		end)
		vim.keymap.set("n", "<Leader>lp", function()
			dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
		end)
		vim.keymap.set("n", "<Leader>dr", function()
			dap.repl.open()
		end)
		vim.keymap.set("n", "<Leader>dl", function()
			dap.run_last()
		end)
		vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
			require("dap.ui.widgets").hover()
		end)
		vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
			require("dap.ui.widgets").preview()
		end)
		vim.keymap.set("n", "<Leader>df", function()
			local widgets = require("dap.ui.widgets")
			widgets.centered_float(widgets.frames)
		end)
		vim.keymap.set("n", "<Leader>ds", function()
			local widgets = require("dap.ui.widgets")
			widgets.centered_float(widgets.scopes)
		end)

		local masonbin = OS.join_path(vim.fn.stdpath("data"), "mason", "bin")
		-- vim.fn.input(OS.join_path(masonbin, 'OpenDebugAD7' .. '.cmd'))

		dap.adapters.cppdbg = {
			id = "cppdbg",
			type = "executable",
			command = OS.join_path(masonbin, "OpenDebugAD7" .. ".cmd"),
			options = {
				detached = false,
			},
		}

		dap.configurations.cpp = {
			{
				name = "Launch file",
				type = "cppdbg",
				request = "launch",
				program = function()
					local filepath = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					return filepath
				end,
				-- miMode = "gdb",
				-- miDebuggerPath = "gdb.exe",
				cwd = "${workspaceFolder}",
				stopAtEntry = true,
				setupCommands = {
					{
						text = "-enable-pretty-printing",
						description = "enable pretty printing",
						ignoreFailures = false,
					},
				},
			},
			{
				name = "Attach to gdbserver :1234",
				type = "cppdbg",
				request = "launch",
				MIMode = "gdb",
				miDebuggerServerAddress = "localhost:1234",
				miDebuggerPath = "gdb.exe",
				cwd = "${workspaceFolder}",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
			},
		}

		dap.configurations.c = dap.configurations.cpp
	end,
}
