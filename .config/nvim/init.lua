-- general options

vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.linebreak = true
vim.opt.breakindent = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.fillchars = "vert: "

vim.opt.mouse = ""
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 8
vim.opt.hlsearch = false

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"

vim.opt.updatetime = 50
vim.opt.timeoutlen = 300

-- general keymaps
vim.g.mapleader = " "
vim.keymap.set("n", "<C-s>", vim.cmd.up)
vim.keymap.set("n", "<leader>c", ":tabnew term://")
vim.keymap.set("n", "<tab>", "gt")
vim.keymap.set("n", "<s-tab>", "gT")
-- swap gf,gF with <C-w> ones
--vim.keymap.set("n", "gf", "<C-w>gf", {noremap = true}) -- why does this have no effect?
vim.keymap.set("n", "gf", "<C-w>gf")
vim.keymap.set("n", "<C-w>gf", "gf")
vim.keymap.set("n", "gF", "<C-w>gF")
vim.keymap.set("n", "<C-w>gF", "gF")

-- make v_gF behave as expected, not like v_gf
-- file:100
vim.api.nvim_create_user_command(
	"GF",
	function(cmd)
		local v_start = vim.fn.getpos("'<")
		local v_end = vim.fn.getpos("'>")
		local text = table.concat(vim.api.nvim_buf_get_text(0, v_start[2] - 1, v_start[3] - 1, v_end[2] - 1, v_end[3] - 1, {}))
		-- FIXME: use vim.o.isfname somehow
		local split = vim.gsplit(text, ":", {})
		local file = split()
		if file == nil then file = text end
		local line_str = split()
		if line_str == nil then
			line_str = ""
		else
			line_str = "+"..tonumber(line_str)
		end
		-- can't do vim.cmd.tabfind with +line yet
		-- https://github.com/neovim/neovim/issues/21687
		vim.cmd("tabfind "..line_str.." "..file)
		--vim.cmd.lua("vim.print(\""..line_str.." "..file.."\")")
	end,
	{ range = true }
)
vim.keymap.set("v", "gF", vim.cmd.GF)


-- buffer specific options and keymaps

vim.api.nvim_create_autocmd("TermOpen", {
	pattern = { "*" },
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.keymap.set("n", "<leader>e", function() vim.cmd("bd!") end, { buffer = 0 })
		vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = 0 })
	end
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "rust" },
	callback = function()
		vim.keymap.set("n", "<leader>r", function()
			vim.cmd.up()
			vim.cmd.tabnew("term://cargo run --quiet")
		end, { buffer = 0, silent = 1 })
		vim.keymap.set("n", "<leader>t", function()
			vim.cmd.up()
			vim.cmd.tabnew("term://cargo test")
		end, { buffer = 0, silent = 1 })
	end
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "java" },
	callback = function()
		vim.opt_local.expandtab = true
	end
})


-- netrw
vim.keymap.set("n", "<leader>d", vim.cmd.Ex)
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3


-- for my nvim-remote script
vim.api.nvim_create_user_command(
	"Tabnew",
	function(cmd)
		if cmd.args == "" then return end
		if vim.fn.bufname() == "" then
			vim.cmd.edit(cmd.args)
		else
			vim.cmd.tabnew(cmd.args)
		end
	end,
	{ nargs = "*", complete = "file" }
)
vim.g.grep_colors = "sl=37"


-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- plugins
require("lazy").setup({
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	"Mofiqul/vscode.nvim",
	"jiangmiao/auto-pairs",
	"HiPhish/rainbow-delimiters.nvim",
	"mbbill/undotree",
	{ "nvim-treesitter/nvim-treesitter", build = vim.cmd.TSUpdate },
	--{ "nvim-telescope/telescope.nvim", tag = "0.1.2", dependencies = { "nvim-lua/plenary.nvim" } },
	"tpope/vim-fugitive",
	--{ "francoiscabrol/ranger.vim", dependencies = { "rbgrouleff/bclose.vim" } },
	--{
	--	"VonHeikemen/lsp-zero.nvim",
	--	branch = "v2.x",
	--	dependencies = {
	--		-- LSP Support
	--		{ "neovim/nvim-lspconfig" },             -- Required
	--		{ "williamboman/mason.nvim" },           -- Optional
	--		{ "williamboman/mason-lspconfig.nvim" }, -- Optional

	--		-- Autocompletion
	--		{ "hrsh7th/nvim-cmp" },     -- Required
	--		{ "hrsh7th/cmp-nvim-lsp" }, -- Required
	--		{ "L3MON4D3/LuaSnip" },     -- Required
	--	}
	--},
	--"lervag/vimtex"
})


-- vimtex
vim.g.vimtex_syntax_enabled = 0


-- catppuccin
require("catppuccin").setup({
    transparent_background = true,
    term_colors = false,
	no_italic = true,
    integrations = {
		treesitter = true,
		rainbow_delimiters = true,
		semantic_tokens = true,
    },
	custom_highlights = function(colors)
		return {
			netrwTreeBar = { fg = colors.surface0 }
		}
	end
})

vim.cmd.colorscheme("catppuccin")


-- undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
vim.g.undotree_RelativeTimestamp = 0


-- telescope
--require("telescope").setup({
--	pickers = { find_files = { hidden = true } }
--})
--
--vim.keymap.set("n", "<leader>f", require("telescope.builtin").find_files)
--vim.keymap.set("n", "<leader>g", require("telescope.builtin").treesitter)


-- treesitter
require('nvim-treesitter.configs').setup({
	ensure_installed = {
		"lua", "vim", "vimdoc",
		"c", "cpp", "rust", "zig",
		"glsl", "wgsl",
		"javascript", "html", "css",
		"java",
		"markdown"
	},
	sync_install = false,
	auto_install = false,

	highlight = {
		enable = true,

		-- Disable slow treesitter highlight for large files
		disable = function(lang, buf)
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,

		additional_vim_regex_highlighting = false,
	},
})


-- lsp
--local lsp = require("lsp-zero").preset({})
--
--lsp.on_attach(function(client, bufnr)
--  vim.opt.signcolumn = "yes"
--  -- see :help lsp-zero-keybindings
--  lsp.default_keymaps({buffer = bufnr})
--end)
--
--lsp.ensure_installed({
--	"clangd",
--	"rust_analyzer",
--	"lua_ls",
--})
--
--lsp.set_sign_icons({
--	error = 'x',
--	warn  = '!',
--	hint  = '*',
--	info  = '>'
--})
--
--vim.diagnostic.config({
--	virtual_text = false,
--	update_in_insert = true,
--})
--
--require("lspconfig").rust_analyzer.setup({
--	settings = { ["rust-analyzer"] = {
--		cargo = { target = "wasm32-unknown-unknown" },
--		checkOnSave = { command = "clippy" }
--	}}
--})
--
--require("lspconfig").lua_ls.setup({
--	settings = { Lua = { diagnostics = { globals = { "vim" } } } }
--})
--
--require("lspconfig").clangd.setup({
--	cmd = {"clangd", "--background-index=false", "--header-insertion=never"},
--})
--
--lsp.setup()
