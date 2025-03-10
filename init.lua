-------------------------------
-- LazyNvim
-------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-------------------------------
-- General settings
-------------------------------
require('key')

local default_options = {
  number = true,
  expandtab = true,
  shiftwidth = 2,
  tabstop = 2,
  cursorline = true,
  cursorcolumn = true,
  scrolloff = 10,
  fileencoding = 'utf-8',
  termguicolors = true,
  splitbelow = true,
  splitright = true,
  clipboard = 'unnamedplus',
  swapfile = false,
  ignorecase = true,
  shell = 'zsh',
  mouse = 'v',
  so = 999,
  cmdheight = 0,
}

for k, v in pairs(default_options) do
  vim.opt[k] = v
end

-- Hide end-of-line symbol
vim.cmd([[set fillchars=eob:\ ]])

-------------------------------
-- Yank settings
-------------------------------
-- Blink & keep cursor position when yanking
local cursor_pre_yank
vim.keymap.set({ 'n', 'x' }, 'y', function()
  cursor_pre_yank = vim.api.nvim_win_get_cursor(0)
  return 'y'
end, { expr = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text & sticky yank',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
    if vim.v.event.operator == 'y' and cursor_pre_yank then
      vim.api.nvim_win_set_cursor(0, cursor_pre_yank)
    end
  end,
})

-------------------------------
-- Plugins
-------------------------------
M = require('util')

require('lazy').setup({
  --------------------
  -- Onedark
  --------------------
  {
    'navarasu/onedark.nvim',
    config = function()
      local c = require('onedark.palette').dark
      require('onedark').setup({
        highlights = {
          ['@constructor'] = { fg = c.cyan },
          ['@variable.builtin'] = { fg = c.yellow },
          ['@variable.parameter'] = { fg = c.fg },
          ['@lsp.type.parameter'] = { fg = c.fg },
          ['@punctuation.bracket'] = { fg = c.fg },
          ['@punctuation.special'] = { fg = c.blue },
          ['@punctuation.delimiter'] = { fg = c.fg },
          ['CmpItemKindSnippet'] = { fg = c.orange },
          ['MatchParen'] = { bg = c.light_grey },
        },
        transparent = true,
        lualine = { transparent = true },
      })
      require('onedark').load()
      vim.cmd([[hi! link FloatBorder VertSplit]])
      vim.cmd([[hi! link NormalFloat CmpMenu]])
      vim.cmd([[hi! link BlinkCmpMenu Normal]])
      vim.cmd([[hi! link BlinkCmpMenuBorder VertSplit]])
      vim.cmd([[hi! link BlinkCmpDocBorder VertSplit]])
      vim.cmd([[hi! link BlinkCmpDocSeparator VertSplit]])
      vim.cmd([[hi! link BlinkCmpSignatureHelpBorder VertSplit]])
    end,
  },

  --------------------
  -- Nvim-tree
  --------------------
  {
    'nvim-tree/nvim-tree.lua',
    opts = {
      on_attach = function(bufnr)
        local api = require('nvim-tree.api')
        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.del('n', '<C-v>', { buffer = bufnr })
        vim.keymap.del('n', '<BS>', { buffer = bufnr })
        vim.keymap.del('n', '<Tab>', { buffer = bufnr })
        vim.keymap.del('n', 'e', { buffer = bufnr })
        vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', 'e', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', 'i', api.node.open.vertical, opts('Open: Vertical Split'))
        vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
      end,
      filters = { dotfiles = true },
      renderer = {
        root_folder_label = false,
        icons = {
          glyphs = {
            default = '',
            -- default = '', -- for mac
            symlink = '',
            bookmark = '',
            folder = {
              arrow_closed = '',
              arrow_open = '',
              default = '',
              open = '',
              empty = '',
              empty_open = '',
              symlink = '',
              symlink_open = '',
            },
            git = {
              unstaged = '•',
              staged = '✓',
              unmerged = '',
              renamed = '➜',
              untracked = '✗',
              deleted = '',
              ignored = '◌',
            },
          },
        },
      },
      actions = { change_dir = { restrict_above_cwd = true } },
    },
    config = function(_, opts)
      require('nvim-tree').setup(opts)
    end,
    keys = {
      { '<Leader>f', ':NvimTreeFindFileToggle<CR>' },
    },
    init = function()
      vim.cmd([[autocmd BufEnter * lua require('nvim-tree.actions.tree.find-file').fn()]])
    end,
  },

  --------------------
  -- Vim-startify
  --------------------
  {
    'mhinz/vim-startify',
    init = function()
      vim.g.startify_change_to_vcs_root = 1
      vim.g.startify_change_to_dir = 1
    end,
  },

  --------------------
  -- Flash-jump
  --------------------
  {
    'kuangliu/flash.nvim',
    event = 'VeryLazy',
    opts = {
      search = { multi_window = false },
      label = { after = false, before = { 0, 0 }, uppercase = false },
      prompt = { prefix = { { '  ', 'FlashPromptIcon' } } },
      modes = {
        search = { enabled = false },
        char = {
          multi_line = false,
          jump_labels = true,
          search = { wrap = true },
          highlight = { backdrop = true },
          keys = { 'f' },
        },
      },
    },
    config = function(_, opts)
      require('flash').setup(opts)
      local hls = {
        FlashMatch = { fg = '#61AFEF' },
        FlashCurrent = { fg = '#61AFEF' },
        FlashLabel = { fg = '#E06C75' },
        FlashCursor = { fg = '#98C379' },
      }
      for hl_group, hl in pairs(hls) do
        hl.default = true
        vim.api.nvim_set_hl(0, hl_group, hl)
      end
    end,
    keys = {
      { 's', M.hopword, mode = { 'n', 'x', 'o' } },
    },
  },

  --------------------
  -- Mason
  --------------------
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    keys = { { '<Leader>ma', ':Mason<CR>', desc = 'Mason' } },
    opts = {
      ensure_installed = {
        'stylua',
        'shfmt',
        'autopep8',
        'clang-format',
      },
    },
    config = function(_, opts)
      require('mason').setup(opts)
      local mr = require('mason-registry')
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  --------------------
  -- Reformat
  --------------------
  {
    'stevearc/conform.nvim',
    config = function()
      local confrom = require('conform')
      confrom.formatters.stylua = {
        prepend_args = { '--indent-type', 'Spaces', '--indent-width', '2', '--quote-style', 'AutoPreferSingle' },
      }
      confrom.formatters.autopep8 = {
        prepend_args = { '--max-line-length', '120' },
      }
      confrom.formatters.clang_format = {
        prepend_args = { '-style', 'Google' },
      }
      confrom.setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'autopep8' },
          cpp = { 'clang_format' },
        },
      })
    end,
    keys = {
      {
        '1',
        function()
          require('conform').format({ async = false, lsp_fallback = true })
          M.save_file()
        end,
        mode = 'n',
      },
    },
  },

  --------------------
  -- Telescope
  --------------------
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-telescope/telescope-live-grep-args.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    keys = {
      { '<C-f>', ':Telescope find_files find_command=fd<CR>' },
      { '<C-g>', ':Telescope live_grep_args<CR>' },
    },
    config = function()
      local actions = require('telescope-live-grep-args.actions')
      require('telescope').setup({
        extensions = {
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ['<Tab>'] = actions.quote_prompt({ postfix = ' -g *.' }),
                ['<C-i>'] = actions.quote_prompt({ postfix = ' --iglob ' }),
              },
            },
          },
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
        },
      })
      require('telescope').load_extension('fzf')
      require('telescope').load_extension('live_grep_args')
    end,
  },

  --------------------
  -- Smooth-scroll
  --------------------
  {
    'karb94/neoscroll.nvim',
    opts = {
      mappings = { '<C-u>', '<C-d>' },
    },
  },

  --------------------
  -- Nvim-comment
  --------------------
  {
    'terrortylor/nvim-comment',
    config = function()
      require('nvim_comment').setup({
        hook = function()
          if vim.api.nvim_buf_get_option(0, 'filetype') == 'cpp' then
            vim.api.nvim_buf_set_option(0, 'commentstring', '// %s')
          end
        end,
      })
    end,
    keys = {
      { '<Leader>c', ':CommentToggle<CR>', mode = { 'n', 'v' } },
    },
  },

  --------------------
  -- Accelerated-jk
  --------------------
  {
    'rhysd/accelerated-jk',
    keys = {
      { 'j', '<Plug>(accelerated_jk_gj)' },
      { 'k', '<Plug>(accelerated_jk_gk)' },
    },
  },

  --------------------
  -- Toggleterm
  --------------------
  {
    'akinsho/toggleterm.nvim',
    lazy = false,
    opts = {
      size = function(term)
        if term.direction == 'horizontal' then
          return 20
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
      shade_terminals = false,
      shading_factor = 1,
      persist_mode = false,
      float_opts = {
        border = 'curved',
        width = math.floor(vim.api.nvim_win_get_width(0) * 0.9),
        height = math.floor(vim.api.nvim_win_get_height(0) * 0.9),
      },
    },
    keys = {
      { '<ESC>', [[<C-\><C-n>]],                               mode = 't' },
      { '2',     ':ToggleTerm dir=./ direction=float<CR>' },
      { 'tr',    ':ToggleTerm dir=./ direction=vertical<CR>' },
      { 'tb',    ':ToggleTerm dir=./ direction=horizontal<CR>' },
      { 'zg',    M.lazygit_toggle },
    },
  },

  --------------------
  -- Surround
  --------------------
  {
    'kylechui/nvim-surround',
    config = true,
  },

  --------------------
  -- Session-manager
  --------------------
  {
    'Shatur/neovim-session-manager',
    config = function()
      require('session_manager').setup({
        autoload_mode = require('session_manager.config').AutoloadMode.CurrentDir,
      })

      local config_group = vim.api.nvim_create_augroup('MyConfigGroup', {})
      vim.api.nvim_create_autocmd({ 'SessionLoadPost' }, {
        group = config_group,
        callback = function()
          require('nvim-tree.api').tree.toggle(true, true)
        end,
      })
    end,
  },

  --------------------
  -- Lualine
  --------------------
  {
    'hoob3rt/lualine.nvim',
    config = function()
      local c = require('onedark.colors')
      require('lualine').setup({
        options = {
          theme = 'onedark',
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
          icons_enabled = true,
          globalstatus = true,
          transparent = true,
        },
        extensions = { 'toggleterm' },
        sections = {
          lualine_b = {
            { 'branch', color = { fg = c.orange, bg = c.none, gui = 'bold' }, icon = '' },
          },
          lualine_c = { { M.get_absolute_path } },
          lualine_x = {
            {
              'diff',
              symbols = { added = '󰐙 ', modified = '󰣕 ', removed = '󰍷 ' },
            },
            {
              'diagnostics',
              sections = { 'error', 'warn' },
              symbols = { error = '󱓇 ', warn = '󰗖 ' },
            },
          },
          lualine_y = { { 'progress', color = { fg = c.fg, bg = c.none } } },
          lualine_z = {
            {
              function()
                return '▐'
              end,
              color = { fg = c.green, bg = c.none },
              padding = { left = 0, right = 0 },
            },
          },
        },
      })
    end,
  },

  --------------------
  -- Bufferline
  --------------------
  {
    'kuangliu/bufferline.nvim',
    opts = {
      options = {
        indicator = { icon = 'ᐅ' },
        separator_style = { '', '' },
        modified_icon = '•',
        show_buffer_icons = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        enforce_regular_tabs = false,
        max_name_length = 300,
        tab_size = 15,
      },
    },
  },

  --------------------
  -- Autopairs
  --------------------
  {
    'windwp/nvim-autopairs',
    config = true,
  },

  --------------------
  -- Treesitter
  --------------------
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'cpp', 'lua', 'python' },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },

  --------------------
  -- Indent-line
  --------------------
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    main = 'ibl',
    opts = {
      indent = { char = '│' },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
      },
    },
  },

  --------------------
  -- Blink.cmp
  --------------------
  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '*',
    opts = {
      signature = { enabled = true, window = { border = 'single' } },
      completion = {
        list = { selection = { preselect = false } },
        menu = {
          border = 'single',
          auto_show = function(ctx)
            return vim.bo.buftype ~= 'prompt'
          end,
        },
        documentation = { auto_show = true, auto_show_delay_ms = 0, window = { border = 'single' } },
        ghost_text = { enabled = true, show_with_menu = false },
      },
      keymap = {
        ['<C-u>'] = { 'select_prev', 'fallback' },
        ['<C-d>'] = { 'select_next', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<CR>'] = { 'select_and_accept', 'fallback' },
      },
      cmdline = {
        completion = {
          list = { selection = { preselect = false } },
          menu = { auto_show = true },
        },
        keymap = {
          ['<C-u>'] = { 'select_prev', 'fallback' },
          ['<C-d>'] = { 'select_next', 'fallback' },
          ['<Tab>'] = { 'select_next', 'fallback' },
        },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = { path = { opts = { trailing_slash = false, label_trailing_slash = true } } },
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },

  --------------------
  -- LSP
  --------------------
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    config = function()
      vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        signs = { severity = { min = vim.diagnostic.severity.ERROR } },
        virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
      })

      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'rounded',
      })

      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local lspconfig = require('lspconfig')
      lspconfig.clangd.setup({ capabilities = capabilities })
      lspconfig.lua_ls.setup({ capabilities = capabilities })
      lspconfig.pyright.setup({ capabilities = capabilities })
      lspconfig.rust_analyzer.setup({ capabilities = capabilities })
    end,
    keys = {
      { '<Leader>r', vim.lsp.buf.rename,                                        mode = { 'n' } },
      { 'gd',        ":lua require('telescope.builtin').lsp_definitions()<CR>", mode = { 'n' } },
      { 'gr',        ":lua require('telescope.builtin').lsp_references()<CR>",  mode = { 'n' } },
    },
  },

  --------------------
  -- Outline
  --------------------
  {
    'hedyhli/outline.nvim',
    config = function()
      require('outline').setup()
    end,
    keys = {
      { '<Leader>o', ':Outline<CR>', mode = { 'n' } },
    },
  },

  --------------------
  -- Harpoon2
  --------------------
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require('harpoon')
      harpoon:setup()
      vim.keymap.set('n', '<Leader>a', function()
        harpoon:list():add()
      end)
      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)
    end,
  },

  --------------------
  -- Codeium
  --------------------
  {
    'Exafunction/codeium.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
    },
    config = function()
      require('codeium').setup({
        enable_chat = true,
      })
    end,
  },

  --------------------
  -- Cursor highlight
  --------------------
  {
    'RRethy/vim-illuminate',
    opts = { filetypes_denylist = { 'NvimTree' } },
    config = function(_, opts)
      require('illuminate').configure(opts)
    end,
  },

  --------------------
  -- Macro
  --------------------
  {
    'chrisgrieser/nvim-recorder',
    lazy = false,
    config = function()
      require('recorder').setup({
        mapping = {
          startStopRecording = 'm',
          playMacro = 'M',
        },
        clear = true,
      })
      require('recorder').recordingStatus()
      require('recorder').displaySlots()
    end,
    keys = {
      { 'M', ':norm M<CR>', mode = { 'v' } }, -- apply macro to selected lines
    },
  },

  --------------------
  -- Search & replace
  --------------------
  {
    'chrisgrieser/nvim-rip-substitute',
    cmd = 'RipSubstitute',
    keys = {
      { '<Leader>ss', function() require('rip-substitute').sub() end, mode = { 'n', 'x' } },
    }
  },

  --------------------
  -- Gitsigns
  --------------------
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '│' },
          change = { text = '│' },
          delete = { text = '─' },
          topdelete = { text = '│' },
          changedelete = { text = '│' },
        },
      })
    end,
  },
})
