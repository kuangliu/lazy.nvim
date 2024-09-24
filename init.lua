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

vim.cmd([[set fillchars=eob:\ ]])

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
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    keys = {
      { '<C-f>', ':Telescope find_files find_command=fd<CR>' },
      { '<C-g>', ':Telescope live_grep<CR>' },
    },
    config = function()
      require('telescope').setup({
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
        },
      })
      require('telescope').load_extension('fzf')
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
        extensions = { 'nvim-tree', 'toggleterm' },
        sections = {
          lualine_b = {
            { 'branch', color = { fg = c.orange, bg = c.none, gui = 'bold' }, icon = '' },
          },
          lualine_c = { { 'filename', path = 2 } },
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
  -- Nvim-cmp
  --------------------
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'kuangliu/friendly-snippets',
    },
    config = function()
      require('luasnip.loaders.from_vscode').load()

      local kind_icons = {
        Text = '',
        Method = '󰆧',
        Function = '󰊕',
        Constructor = '',
        Field = '󰇽',
        Variable = '󰂡',
        Class = '󰠱',
        Interface = '',
        Module = '',
        Property = '󰜢',
        Unit = '',
        Value = '󰎠',
        Enum = '',
        Keyword = '󰌋',
        Snippet = '',
        Color = '󰏘',
        File = '󰈙',
        Reference = '',
        Folder = '󰉋',
        EnumMember = '',
        Constant = '󰏿',
        Struct = '',
        Event = '',
        Operator = '󰆕',
        TypeParameter = '󰅲',
        Codeium = '',
      }

      local kind_icons_mac = {
        Method = 'm',
        Function = '',
        Constructor = '',
        Field = '',
        Variable = '',
        Class = '',
        Interface = '',
        Module = '',
        Property = '',
        Unit = '',
        Value = '',
        Enum = '',
        Keyword = '',
        Snippet = '',
        Color = '',
        File = '',
        Reference = '',
        Folder = '',
        EnumMember = '',
        Constant = '',
        Struct = '',
        Event = '',
        Operator = '',
        TypeParameter = '',
        Codeium = '',
      }

      local cmp = require('cmp')
      cmp.setup({
        preselect = cmp.PreselectMode.None,
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        sources = {
          { name = 'codeium' },
          { name = 'luasnip' },
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        },
        mapping = {
          ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<CR>'] = cmp.mapping(
            cmp.mapping.confirm({
              behavior = cmp.ConfirmBehavior.Insert,
              select = true,
            }),
            { 'i' }
          ),
        },
        experimental = {
          ghost_text = true,
        },
        formatting = {
          format = function(entry, vim_item)
            vim_item.kind = string.format('%s [%s]', kind_icons[vim_item.kind], vim_item.kind)
            vim_item.menu = nil
            return vim_item
          end,
        },

        window = {
          completion = {
            border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
            scrollbar = '║',
            winhighlight = 'Normal:CmpMenu,FloatBorder:VertSplit,CursorLine:PmenuSel,Search:None',
            autocomplete = {
              require('cmp.types').cmp.TriggerEvent.InsertEnter,
              require('cmp.types').cmp.TriggerEvent.TextChanged,
            },
          },
          documentation = {
            border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
            winhighlight = 'NormalFloat:CmpMenu,FloatBorder:VertSplit',
            scrollbar = '║',
          },
        },
      })

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
        },
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
          { name = 'cmdline' },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })
    end,
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

      require('lspconfig').clangd.setup({})
      require('lspconfig').lua_ls.setup({})
      require('lspconfig').pyright.setup({})
      require('lspconfig').rust_analyzer.setup({})
    end,
    keys = {
      { '<Leader>r', vim.lsp.buf.rename, mode = { 'n' } },
    },
  },

  --------------------
  -- Lsp-signature
  --------------------
  {
    'ray-x/lsp_signature.nvim',
    opts = { handler_opts = { border = 'rounded' } },
    config = true,
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
