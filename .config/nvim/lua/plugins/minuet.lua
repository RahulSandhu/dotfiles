-- AI ghost text
return {
	"milanglacier/minuet-ai.nvim",
	enabled = true,
	event = "InsertEnter",
	init = function()
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				vim.b.minuet_virtual_text_auto_trigger = true
			end,
		})
	end,
	config = function()
		require("minuet").setup({
			provider = "openai_compatible",
			request_timeout = 2.5,
			throttle = 400,
			debounce = 150,
			context_window = 12000,
			n_completions = 1,

			virtualtext = {
				auto_trigger_ft = { "*" },
				show_on_completion_menu = false,
			},

			provider_options = {
				openai_compatible = {
					api_key = "OPENROUTER_KEY",
					end_point = "https://openrouter.ai/api/v1/chat/completions",
					model = "deepseek/deepseek-v4.1-flash",
					name = "OpenRouter",
					optional = {
						max_tokens = 128,
						top_p = 0.9,
						provider = { sort = "throughput" },
						reasoning_effort = "none",
					},
				},
			},
		})
	end,
}
