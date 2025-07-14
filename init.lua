vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.inccommand = "split"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.completeopt = { "menu", "menuone", "noinsert" }

vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)


vim.diagnostic.config({
  virtual_lines = true,
  -- virtual_text = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",
      [vim.diagnostic.severity.WARN] = "WarningMsg",
    },
  },
})

vim.lsp.config('*', {
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true
      }
    }
  }
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        disable = { 'undefined-global' }
      }
    }
  }
})

vim.lsp.config('hls', {
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
})

-- NOTE: use `:help lspconfig-all` for a list of servers and their proper names
vim.lsp.enable({ 'lua_ls', 'pyright', 'ocamllsp', 'rust_analyzer', 'tailwindcss', 'ts_ls', 'gopls', 'hls', 'eslint' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client:supports_method('textDocument/completion') then
      local chars = {}; for i = 32, 126 do
        local c = string.char(i)
        if not string.find("{}()[],<>;: ", c, 1, true) then
          table.insert(chars, c)
        end
      end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
      vim.keymap.set(
        'i',
        '<CR>',
        function()
          return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
        end
        , { expr = true })
    end

    if not client:supports_method('textDocument/willSaveWaitUntil')
        and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end

    pcall(vim.keymap.del, 'n', 'grn')
    pcall(vim.keymap.del, 'n', 'gra')
    pcall(vim.keymap.del, 'n', 'grr')
    pcall(vim.keymap.del, 'n', 'gri')

    vim.keymap.set('n', 'rn', vim.lsp.buf.rename, { desc = 'Rename Symbol' })
    vim.keymap.set('n', 'ca', vim.lsp.buf.code_action, { desc = '[C]ode [A]ction' })
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = '[G]oto [R]eferences' })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = '[G]oto [D]efinition' })
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = '[G]oto [I]mplementation' })
    vim.keymap.set('n', 'gtd', vim.lsp.buf.implementation, { desc = '[G]oto [T]ype [D]efinition' })
  end
})

require("lazy").setup({
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup {}

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch [G]rep' })
      vim.keymap.set('n', '<leader>ss', builtin.grep_string, { desc = '[S]earch [S]tring' })
      vim.keymap.set('n', '<leader>qq', builtin.quickfix, { desc = 'Open Quickfix' })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup {
        auto_install = true,
        highlight = { enable = true }
      }
    end,
  },
  {
    'mason-org/mason.nvim',
    opts = {}
  },
  {
    'neovim/nvim-lspconfig'
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      vim.cmd [[colorscheme tokyonight-night]]
    end
  },
  {
    'folke/which-key.nvim',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font
      }
    }
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional, but recommended for file icons
    },
    config = function()
      require('nvim-tree').setup()
      vim.keymap.set("n", "<leader>e", require("nvim-tree.api").tree.toggle, { desc = "Toggle NvimTree" })
      vim.keymap.set("n", "<leader>h", require("nvim-tree.api").tree.toggle_enable_filters,
        { desc = "Toggle NvimTree Filters" })
    end
  },
  {
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
      require('mini.basics').setup()
      require('mini.pairs').setup()
      require('mini.icons').setup()
      require('mini.statusline').setup()
    end
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          -- Defaults
          enable_close = true,          -- Auto close tags
          enable_rename = true,         -- Auto rename pairs of tags
          enable_close_on_slash = false -- Auto close on trailing </
        },
      })
    end
  }
})
