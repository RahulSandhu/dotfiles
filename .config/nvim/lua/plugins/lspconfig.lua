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
				"rust_analyzer",
				-- Formatters
				"stylua",
				"prettier",
				"ruff",
				"gofumpt",
				"goimports",
				"latexindent",
				-- Linters
				"selene",
				"markdownlint",
				"golangci-lint",
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
				"rust_analyzer",
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

		-- Rust LSP
		vim.lsp.config("rust_analyzer", {
			settings = {
				["rust-analyzer"] = {
					cargo = {
						features = "all",
					},
					diagnostics = {
						enable = true,
						experimental = {
							enable = true,
						},
					},
					checkOnSave = true,
					check = {
						command = "clippy",
					},
					inlayHints = {
						bindingModeHints = { enable = false },
						chainingHints = { enable = true },
						closingBraceHints = { enable = true },
						closureReturnTypeHints = { enable = "never" },
						lifetimeElisionHints = { enable = "never" },
						parameterHints = { enable = true },
						reborrowHints = { enable = "never" },
						typeHints = { enable = true },
					},
					procMacro = {
						enable = true,
					},
				},
			},
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
	end,
}
