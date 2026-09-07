-- LSP
return {
	"neovim/nvim-lspconfig",
	enabled = true,
	dependencies = {
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
		{ "hrsh7th/cmp-nvim-lsp" },
	},
	config = function()
		-- Capabilities
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		local default_capabilities = require("cmp_nvim_lsp").default_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, default_capabilities)
		capabilities.textDocument.completion.completionItem.snippetSupport = true
		vim.lsp.config.default_capabilities = capabilities

		-- Mason
		require("mason").setup()

		require("mason-tool-installer").setup({
			ensure_installed = {
				-- LSP
				"lua_ls",
				"pyright",
				"r-languageserver",
				"marksman",
				"texlab",
				"sqlls",
				"matlab-language-server",
				"gopls",
				"clangd",
				"ltex-ls-plus",
				-- Formatters
				"stylua",
				"prettier",
				"ruff",
				"air",
				"gofumpt",
				"goimports",
				"latexindent",
				"clang-format",
				-- Linters
				"selene",
				"markdownlint",
				"golangci-lint",
				"cpplint",
			},
			auto_update = true,
			run_on_start = true,
		})

		require("mason-lspconfig").setup({
			automatic_enable = {
				"lua_ls",
				"pyright",
				"r_language_server",
				"marksman",
				"texlab",
				"sqlls",
				"matlab_ls",
				"gopls",
				"clangd",
				"ltex_plus",
			},
		})

		-- Lua LSP
		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
		})

		-- Python LSP
		vim.lsp.config("pyright", {
			root_markers = { ".venv", "pyrightconfig.json", "pyproject.toml", "setup.py", "setup.cfg" },
			on_init = function(client)
				local root_dir = client.config.root_dir
				if root_dir then
					local venv_python = root_dir .. "/.venv/bin/python"
					if vim.fn.executable(venv_python) == 1 then
						client.config.settings.python.pythonPath = venv_python
						return
					end
				end
				local system_python = vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
				client.config.settings.python.pythonPath = system_python
			end,
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						diagnosticMode = "openFilesOnly",
						useLibraryCodeForTypes = true,
					},
				},
			},
		})

		-- Go LSP
		vim.lsp.config("gopls", {
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
						shadow = true,
					},
					staticcheck = true,
					gofumpt = true,
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
				},
			},
		})

		-- C/C++ LSP
		vim.lsp.config("clangd", {
			cmd = { "clangd", "--background-index", "--header-insertion=never" },
			filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
			root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
		})

		-- Markdown LSP
		vim.lsp.config("marksman", {
			filetypes = { "markdown", "markdown.mdx", "quarto" },
			single_file_support = true,
		})

		-- MATLAB LSP
		vim.lsp.config("matlab_ls", {
			settings = {
				MATLAB = {
					installPath = vim.env.HOME .. "/.local/share/MATLAB/R2025b",
					matlabConnectionTiming = "onStart",
					indexWorkspace = false,
					telemetry = false,
				},
			},
			filetypes = { "matlab" },
		})

		-- LTeX+ (LanguageTool) for grammar/spelling in prose and git commits
		vim.lsp.config("ltex_plus", {
			settings = {
				ltex = {
					language = "en-US",
					checkFrequency = "edit",
				},
			},
		})
	end,
}
