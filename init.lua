require("config.lazy")

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = false

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.autoindent = true

vim.g.mapleader = " "

-- Setup the LSP stuff
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}
})

local caps = require("cmp_nvim_lsp").default_capabilities()

require("lspconfig").clangd.setup({
	cmd = { "clangd", "--compile-commands-dir=build" },	
	capabilities = caps,
	on_attach = on_attach,
})

local notify = require("notify")

vim.keymap.set("n", "<leader>cd", function()
  local buf = vim.api.nvim_create_buf(false, true)

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.5)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local opts = {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
  }

  vim.api.nvim_open_win(buf, true, opts)

  vim.fn.termopen("mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..", {
    on_stdout = function(_, _, _)
      local win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_cursor(win, {vim.api.nvim_buf_line_count(0), 0})
    end,
    on_stderr = function(_, _, _)
      local win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_cursor(win, {vim.api.nvim_buf_line_count(0), 0})
    end,
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bd!<CR>", { silent = true, noremap = true })
end, { desc = "Configure CMake Debug Build in floating terminal" })

