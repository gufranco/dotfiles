vim.g.mapleader = ","
vim.g.maplocalleader = ","

local config_root = vim.fn.expand("~/.dotfiles/nvim")
local undo_dir = config_root .. "/undodir"
local swap_dir = config_root .. "/swap"

for _, dir in ipairs({ undo_dir, swap_dir }) do
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p", tonumber("0700", 8))
  end
end

local options = {
  encoding = "utf-8",
  fileencoding = "utf-8",
  fileformats = "unix,dos,mac",
  updatetime = 100,
  errorbells = false,
  visualbell = false,
  modeline = false,
  signcolumn = "yes",
  joinspaces = false,
  splitbelow = true,
  splitright = true,
  virtualedit = "block",
  clipboard = "unnamedplus",
  undofile = true,
  undodir = undo_dir,
  swapfile = true,
  directory = swap_dir .. "//",
  cursorline = true,
  colorcolumn = "80",
  number = true,
  relativenumber = true,
  list = true,
  termguicolors = true,
  background = "dark",
  expandtab = true,
  shiftwidth = 2,
  tabstop = 2,
  smartindent = true,
  ignorecase = true,
  smartcase = true,
  scrolloff = 8,
}

for key, value in pairs(options) do
  vim.opt[key] = value
end

vim.opt.shortmess:append("c")

if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
  vim.opt.grepformat = "%f:%l:%c:%m"
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local on_lsp_attach = function(event)
  local map = function(keys, fn, desc)
    vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = desc })
  end

  map("gd", vim.lsp.buf.definition, "Go to definition")
  map("gr", vim.lsp.buf.references, "References")
  map("gy", vim.lsp.buf.type_definition, "Type definition")
  map("gi", vim.lsp.buf.implementation, "Implementation")
  map("K", vim.lsp.buf.hover, "Documentation")
  map("gh", vim.lsp.buf.hover, "Documentation")
  map("[g", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
  map("]g", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
  map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
  map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
  map("<leader>cs", vim.lsp.buf.document_symbol, "Document symbols")
end

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        integrations = {
          cmp = true,
          gitsigns = true,
          treesitter = true,
          mason = true,
          native_lsp = { enabled = true },
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { theme = "catppuccin", globalstatus = true } },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "bash",
        "css",
        "diff",
        "dockerfile",
        "git_config",
        "gitcommit",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "python",
        "ruby",
        "rust",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { winopts = { preview = { default = "bat" } } },
    keys = {
      { "<C-p>", "<cmd>FzfLua files<cr>", desc = "Files" },
      { "<leader>f", "<cmd>FzfLua live_grep<cr>", desc = "Ripgrep search" },
      { "<leader>b", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>h", "<cmd>FzfLua oldfiles<cr>", desc = "File history" },
      { "<leader>gf", "<cmd>FzfLua git_files<cr>", desc = "Git files" },
      { "<leader>t", "<cmd>FzfLua grep<cr><cmd>TODO<cr>", desc = "Search TODOs" },
      { "<leader>cc", "<cmd>FzfLua commands<cr>", desc = "Commands" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        vim.keymap.set("n", "[c", function() gitsigns.nav_hunk("prev") end, { buffer = bufnr })
        vim.keymap.set("n", "]c", function() gitsigns.nav_hunk("next") end, { buffer = bufnr })
      end,
    },
  },

  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { { "<C-g>", "<cmd>LazyGit<cr>", desc = "Open lazygit" } },
  },

  { "tpope/vim-fugitive" },
  { "tpope/vim-surround" },
  { "tpope/vim-repeat" },
  { "tpope/vim-unimpaired" },
  { "mbbill/undotree", keys = { { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" } } },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      { "mason-org/mason-lspconfig.nvim", opts = { ensure_installed = { "lua_ls", "ts_ls", "bashls", "jsonls", "yamlls" } } },
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", { callback = on_lsp_attach })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },
}, {
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = false },
  change_detection = { notify = false },
})

local map = vim.keymap.set

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "Y", "y$", { desc = "Yank to end of line" })
map("v", "<", "<gv", { desc = "Indent left, keep selection" })
map("v", ">", ">gv", { desc = "Indent right, keep selection" })
map("n", "<A-j>", "<cmd>move .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>move .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":move '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":move '<-2<cr>gv=gv", { desc = "Move selection up" })

map("n", "<leader>v", "<cmd>edit ~/.dotfiles/nvim/init.lua<cr>", { desc = "Edit config" })
map("n", "<leader>s", "<cmd>source ~/.dotfiles/nvim/init.lua<cr>", { desc = "Source config" })
map("n", "<leader>cl", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })
