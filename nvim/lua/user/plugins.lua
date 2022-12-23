--[[ Command Aliasing ]]--
local execute = vim.api.nvim_command
local fn = vim.fn
local fmt = string.format

local pack_path = fn.stdpath("data") .. "/site/pack"
-- Ensures a plugin from github.com/<user>/<repo> is cloned in the pack_path directory
local function ensure (user, repo)
  local install_path = fmt("%s/packer/start/%s", pack_path, repo)
  if fn.empty(fn.glob(install_path)) > 0 then
    execute(fmt("!git clone https://github.com/%s/%s %s", user, repo, install_path))
    execute(fmt("packadd %s", repo))
  end
end


-- Plugin manager has to be installed to manage plugins...
ensure("wbthomason", "packer.nvim")

require('packer').startup(function(use)
  -- All plugins to be installed should be included here

  -- Manage plugin manager with plugin manager
  use {'wbthomason/packer.nvim'}

  --[[ ELIXIR ]]--

  -- LSP Support for elxir-ls
  use {'neovim/nvim-lspconfig'}

  -- CMP for autocomplete
  use {'hrsh7th/nvim-cmp'}

  -- Completion sources
  use {'hrsh7th/cmp-nvim-lsp'}
  use {'hrsh7th/cmp-buffer'}
  use {'hrsh7th/cmp-path'}
  use {'hrsh7th/cmp-cmdline'}

  -- Snippet engine 
  use {'hrsh7th/vim-vsnip'}
  use {'hrsh7th/cmp-vsnip'}

  -- Syntax highlighting and more
  use {'elixir-editors/vim-elixir'}

  --[[ END ELIXIR ]]--
  
  --[[ Theme ]]--
  use {'Mofiqul/dracula.nvim'}

  --[[ Directory Browsing ]]--
  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', 
    },
    tag = 'nightly' 
  }
end)
