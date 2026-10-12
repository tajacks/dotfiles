-- Must be set before plugins load
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Nothing here uses the remote plugin hosts
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- [[ Options ]]
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.textwidth = 120
vim.o.foldlevelstart = 99

-- Defaults for new files; guess-indent overrides them for existing ones
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2

-- Scheduled because reading the system clipboard slows startup
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- [[ Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics list' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ Plugins ]]
local function gh(repo)
  return 'https://github.com/' .. repo
end

-- Parsers must match the plugin's revision
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('pack-hooks', { clear = true }),
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd 'nvim-treesitter'
      end
      vim.cmd 'TSUpdate'
    end
  end,
})

vim.pack.add({
  gh 'folke/tokyonight.nvim',
  gh 'nvim-mini/mini.nvim',
  gh 'folke/which-key.nvim',
  gh 'nvim-neo-tree/neo-tree.nvim',
  gh 'nvim-lua/plenary.nvim', -- neo-tree dependency
  gh 'MunifTanjim/nui.nvim', -- neo-tree dependency
  gh 'NMAC427/guess-indent.nvim',
  { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },
  gh 'mason-org/mason.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' },
  gh 'folke/lazydev.nvim',
}, { confirm = false }) -- Install on a new machine without prompting

vim.keymap.set('n', '<leader>pu', vim.pack.update, { desc = 'Update plugins' })

-- [[ Appearance ]]
---@diagnostic disable-next-line: missing-fields
require('tokyonight').setup { styles = { comments = { italic = false } } }
vim.cmd.colorscheme 'tokyonight-night'

require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons() -- neo-tree asks for nvim-web-devicons

local statusline = require 'mini.statusline'
statusline.setup()
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
  return '%2l:%-2v'
end

-- [[ Finding things ]]
require('which-key').setup {
  delay = 0,
  spec = {
    { '<leader>s', group = 'Search' },
    { '<leader>p', group = 'Plugins' },
  },
}

require('mini.pick').setup()
require('mini.extra').setup()

local pick, extra = MiniPick.builtin, MiniExtra.pickers
vim.keymap.set('n', '<leader>sf', pick.files, { desc = 'Files' })
vim.keymap.set('n', '<leader>sg', pick.grep_live, { desc = 'Grep' })
vim.keymap.set('n', '<leader>sh', pick.help, { desc = 'Help' })
vim.keymap.set('n', '<leader>sk', extra.keymaps, { desc = 'Keymaps' })
vim.keymap.set('n', '<leader>sc', extra.commands, { desc = 'Commands' })
vim.keymap.set('n', '<leader>sd', extra.diagnostic, { desc = 'Diagnostics' })
vim.keymap.set('n', '<leader>s.', extra.oldfiles, { desc = 'Recent files' })
vim.keymap.set('n', '<leader>sr', pick.resume, { desc = 'Resume last search' })
vim.keymap.set('n', '<leader><leader>', pick.buffers, { desc = 'Open buffers' })
vim.keymap.set('n', '<leader>/', function()
  extra.buf_lines { scope = 'current' }
end, { desc = 'Lines in this buffer' })
vim.keymap.set('n', '<leader>sn', function()
  pick.files(nil, { source = { cwd = vim.fn.stdpath 'config' } })
end, { desc = 'Neovim config files' })

require('neo-tree').setup {
  filesystem = {
    filtered_items = {
      visible = true,
      show_hidden_count = true,
      hide_dotfiles = false,
      hide_gitignored = true,
    },
  },
}
vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle reveal<CR>', { desc = 'File explorer' })

-- [[ Manual ]]
-- doc/manual.txt is this config's own help page
local doc = vim.fn.stdpath 'config' .. '/doc'
local manual, tags = vim.uv.fs_stat(doc .. '/manual.txt'), vim.uv.fs_stat(doc .. '/tags')
if manual and (not tags or tags.mtime.sec < manual.mtime.sec) then
  vim.cmd.helptags(doc)
end
vim.keymap.set('n', '<leader>?', '<cmd>help manual<CR>', { desc = 'Manual' })

-- [[ Editing ]]
require('guess-indent').setup {}
require('mini.pairs').setup() -- Gleam only shows signature help inside a closed call

-- [[ External tools ]]
-- Mason installs these into Neovim's data directory and puts them on the PATH
require('mason').setup()

-- The JSON and YAML servers run on Node. Without it those files get treesitter only.
local has_node = vim.fn.executable 'node' == 1 and vim.fn.executable 'npm' == 1

local tools = {
  'tree-sitter-cli', -- Builds treesitter parsers
  'lua-language-server',
  'stylua',
}
if has_node then
  vim.list_extend(tools, { 'json-lsp', 'yaml-language-server' })
end
require('mason-tool-installer').setup { ensure_installed = tools }

-- [[ Treesitter ]]
-- Neovim bundles parsers for Lua, Markdown, Vimscript and help files
local treesitter = require 'nvim-treesitter'
local parsers = { 'json', 'yaml', 'gleam' }
vim.treesitter.language.register('json', 'jsonc')

local function treesitter_attach(buf)
  local language = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
  -- Fails until the parser has been built
  if not language or not vim.treesitter.language.add(language) then
    return
  end
  vim.treesitter.start(buf, language)
  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win][0].foldmethod = 'expr'
    vim.wo[win][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  end
end

local function treesitter_install()
  treesitter.install(parsers):await(function()
    -- Makes Neovim notice a parser directory created during this session
    vim.o.runtimepath = vim.o.runtimepath
    -- Buffers opened before their parser was built
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and not vim.treesitter.highlighter.active[buf] then
        treesitter_attach(buf)
      end
    end
  end)
end

if vim.fn.executable 'tree-sitter' == 1 then
  treesitter_install()
else
  -- First launch: Mason is still installing the CLI
  vim.api.nvim_create_autocmd('User', {
    pattern = 'MasonToolsUpdateCompleted',
    once = true,
    callback = treesitter_install,
  })
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-attach', { clear = true }),
  pattern = { 'json', 'jsonc', 'yaml', 'gleam' },
  callback = function(args)
    treesitter_attach(args.buf)
  end,
})

-- [[ Language servers ]]
-- Neovim's default LSP keymaps: grn rename, gra code action, grr references,
-- gri implementation, grt type definition, gO document symbols, K hover
vim.keymap.set('n', 'grd', vim.lsp.buf.definition, { desc = 'vim.lsp.buf.definition()' })

vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  virtual_text = { source = 'if_many', spacing = 2 },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  },
}

vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.stylua.toml', 'stylua.toml', '.git' },
  settings = { Lua = { format = { enable = false } } }, -- stylua formats
})

vim.lsp.config('stylua', {
  cmd = { 'stylua', '--lsp' },
  filetypes = { 'lua' },
  root_markers = { '.stylua.toml', 'stylua.toml', '.editorconfig' },
})

vim.lsp.config('jsonls', {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  init_options = { provideFormatter = true },
})

vim.lsp.config('yamlls', {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml' },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = { format = { enable = true } },
  },
})

-- The server is part of the Gleam toolchain, which Mason does not provide
vim.lsp.config('gleam', {
  cmd = { 'gleam', 'lsp' },
  filetypes = { 'gleam' },
  root_markers = { 'gleam.toml', '.git' },
})

local servers = { 'lua_ls', 'stylua' }
if has_node then
  vim.list_extend(servers, { 'jsonls', 'yamlls' })
end
if vim.fn.executable 'gleam' == 1 then
  table.insert(servers, 'gleam')
end
vim.lsp.enable(servers)

-- Teaches lua_ls the Neovim API. Must come after lua_ls is enabled.
require('lazydev').setup {
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
}

local function format(buf)
  if #vim.lsp.get_clients { bufnr = buf, method = 'textDocument/formatting' } > 0 then
    vim.lsp.buf.format { bufnr = buf, timeout_ms = 1000 }
  end
end

vim.keymap.set('n', '<leader>f', function()
  format(0)
end, { desc = 'Format buffer' })

vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('format-on-save', { clear = true }),
  pattern = { '*.lua', '*.gleam' },
  callback = function(args)
    format(args.buf)
  end,
})

-- [[ Completion ]]
require('blink.cmp').setup {
  keymap = { preset = 'default' },
  sources = {
    default = { 'lsp', 'path', 'buffer', 'lazydev' },
    providers = {
      lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
    },
  },
  fuzzy = { implementation = 'lua' },
  signature = { enabled = true },
}

-- vim: ts=2 sts=2 sw=2 et
