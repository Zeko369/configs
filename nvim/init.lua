-- ============================================
-- Neovim config based on kickstart.nvim
-- With custom keybindings from vimrc
-- ============================================

-- Set leader key (must be before plugins)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ============================================
-- Bootstrap lazy.nvim (plugin manager)
-- ============================================
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- ============================================
-- Plugins
-- ============================================
require('lazy').setup({
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Git integration
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Surround text objects
  'tpope/vim-surround',

  -- Comment with gc
  { 'numToStr/Comment.nvim', opts = {} },

  -- Git signs in gutter
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  -- Indentation guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
    end,
  },

  -- Syntax highlighting (treesitter)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      pcall(function()
        require('nvim-treesitter.configs').setup {
          ensure_installed = {
            'bash', 'c', 'css', 'go', 'html', 'javascript', 'json',
            'lua', 'markdown', 'python', 'ruby', 'rust', 'tsx',
            'typescript', 'vim', 'vimdoc', 'yaml',
          },
          auto_install = true,
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = {
            enable = true,
          },
        }
      end)
    end,
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'folke/neodev.nvim',
    },
    config = function()
      require('neodev').setup()
      require('mason').setup()

      local servers = {
        ruby_lsp = {},
        ts_ls = {},
        pyright = {},
        bashls = {},
        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      local on_attach = function(_, bufnr)
        local nmap = function(keys, func, desc)
          if desc then desc = 'LSP: ' .. desc end
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end

        nmap('gd', require('telescope.builtin').lsp_definitions, 'Go to definition')
        nmap('gr', require('telescope.builtin').lsp_references, 'Go to references')
        nmap('gI', require('telescope.builtin').lsp_implementations, 'Go to implementation')
        nmap('gD', vim.lsp.buf.declaration, 'Go to declaration')
        nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type definition')
        nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, 'Document symbols')
        nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace symbols')
        nmap('K', vim.lsp.buf.hover, 'Hover documentation')
        nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature help')
        nmap('<leader>rn', vim.lsp.buf.rename, 'Rename')
        nmap('<leader>ca', vim.lsp.buf.code_action, 'Code action')
        nmap('<leader>F', function() vim.lsp.buf.format { async = true } end, 'Format buffer')
      end

      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        handlers = {
          function(server_name)
            require('lspconfig')[server_name].setup {
              capabilities = capabilities,
              on_attach = on_attach,
              settings = servers[server_name],
            }
          end,
        },
      }
    end,
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      require('luasnip.loaders.from_vscode').lazy_load()
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },

  -- Which-key (shows keybinding hints)
  { 'folke/which-key.nvim', opts = {} },

  -- File tree
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      view = { width = 30 },
      filters = { dotfiles = false },
    },
  },

  -- Lazygit integration
  {
    'kdheepak/lazygit.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  -- Colorscheme
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'catppuccin-mocha'
    end,
  },

}, {})

-- ============================================
-- Options (from vimrc)
-- ============================================
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.showmatch = true
vim.o.showcmd = true
vim.o.showmode = false -- Lualine shows mode
vim.o.laststatus = 2
vim.o.signcolumn = 'yes'

-- Tabs/indentation
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smarttab = true
vim.o.autoindent = true
vim.o.smartindent = true

-- Search
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

-- Editing
vim.o.backspace = 'indent,eol,start'
vim.o.wrap = true
vim.o.linebreak = true
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

-- File handling
vim.o.hidden = true
vim.o.autoread = true
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false
vim.o.undofile = true

-- Completion
vim.o.wildmenu = true
vim.o.wildmode = 'longest:full,full'
vim.o.completeopt = 'menu,menuone,noselect'

-- Appearance
vim.o.termguicolors = true
vim.o.background = 'dark'

-- Whitespace visualization
vim.o.list = true
vim.opt.listchars = { tab = '→ ', trail = '·', extends = '»', precedes = '«', nbsp = '␣' }

-- Disable bells
vim.o.visualbell = true
vim.o.errorbells = false

-- Mouse support
vim.o.mouse = 'a'

-- Sync clipboard with system
vim.o.clipboard = 'unnamedplus'

-- Faster updates
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Split behavior
vim.o.splitright = true
vim.o.splitbelow = true

-- ============================================
-- Keymaps (from vimrc)
-- ============================================
local keymap = vim.keymap.set

-- jk to escape
keymap('i', 'jk', '<Esc>', { desc = 'Exit insert mode' })

-- B/E for start/end of line
keymap('n', 'B', '^', { desc = 'Start of line' })
keymap('n', 'E', '$', { desc = 'End of line' })
keymap('v', 'B', '^', { desc = 'Start of line' })
keymap('v', 'E', '$', { desc = 'End of line' })

-- Quick save/quit
keymap('n', '<leader>w', ':w<CR>', { desc = 'Save' })
keymap('n', '<leader>q', ':q<CR>', { desc = 'Quit' })
keymap('n', '<leader>x', ':x<CR>', { desc = 'Save and quit' })

-- Split navigation
keymap('n', '<C-h>', '<C-w>h', { desc = 'Move to left split' })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Move to below split' })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Move to above split' })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Move to right split' })

-- Split creation
keymap('n', '<leader>v', ':vsplit<CR>', { desc = 'Vertical split' })
keymap('n', '<leader>ss', ':split<CR>', { desc = 'Horizontal split' })

-- Buffer navigation
keymap('n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' })
keymap('n', '<leader>bp', ':bprev<CR>', { desc = 'Previous buffer' })
keymap('n', '<leader>bd', ':bdelete<CR>', { desc = 'Delete buffer' })

-- Tab navigation
keymap('n', '<leader>tn', ':tabnext<CR>', { desc = 'Next tab' })
keymap('n', '<leader>tp', ':tabprev<CR>', { desc = 'Previous tab' })
keymap('n', '<leader>tc', ':tabnew<CR>', { desc = 'New tab' })

-- Move lines up/down
keymap('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
keymap('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
keymap('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
keymap('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Keep visual selection when indenting
keymap('v', '<', '<gv', { desc = 'Indent left and reselect' })
keymap('v', '>', '>gv', { desc = 'Indent right and reselect' })

-- Y yanks to end of line
keymap('n', 'Y', 'y$', { desc = 'Yank to end of line' })

-- Center screen after jumps
keymap('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
keymap('n', 'N', 'Nzzzv', { desc = 'Previous search result (centered)' })
keymap('n', '<C-d>', '<C-d>zz', { desc = 'Page down (centered)' })
keymap('n', '<C-u>', '<C-u>zz', { desc = 'Page up (centered)' })

-- Clear search highlight
keymap('n', '<Esc>', ':nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Quick config access
keymap('n', '<leader>ev', ':e $MYVIMRC<CR>', { desc = 'Edit config' })
keymap('n', '<leader>sv', ':source $MYVIMRC<CR>', { desc = 'Reload config' })

-- File tree
keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file tree' })
keymap('n', '<leader>E', ':NvimTreeFindFile<CR>', { desc = 'Find file in tree' })

-- Telescope
keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live grep' })
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find buffers' })
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Help tags' })
keymap('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', { desc = 'Recent files' })
keymap('n', '<leader>fw', '<cmd>Telescope grep_string<cr>', { desc = 'Grep word under cursor' })
keymap('n', '<leader>/', '<cmd>Telescope current_buffer_fuzzy_find<cr>', { desc = 'Fuzzy find in buffer' })

-- Git (via telescope)
keymap('n', '<leader>gs', '<cmd>Telescope git_status<cr>', { desc = 'Git status' })
keymap('n', '<leader>gc', '<cmd>Telescope git_commits<cr>', { desc = 'Git commits' })
keymap('n', '<leader>gb', '<cmd>Telescope git_branches<cr>', { desc = 'Git branches' })

-- Lazygit
keymap('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = 'Open lazygit' })

-- ============================================
-- Autocommands
-- ============================================
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  group = 'YankHighlight',
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Remove trailing whitespace on save
augroup('TrimWhitespace', { clear = true })
autocmd('BufWritePre', {
  group = 'TrimWhitespace',
  pattern = '*',
  command = [[%s/\s\+$//e]],
})

-- Return to last edit position
augroup('LastPosition', { clear = true })
autocmd('BufReadPost', {
  group = 'LastPosition',
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Filetype specific settings
augroup('FileTypeSettings', { clear = true })
autocmd('FileType', {
  group = 'FileTypeSettings',
  pattern = 'python',
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})
autocmd('FileType', {
  group = 'FileTypeSettings',
  pattern = 'go',
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})
autocmd('FileType', {
  group = 'FileTypeSettings',
  pattern = 'make',
  callback = function()
    vim.opt_local.expandtab = false
  end,
})
