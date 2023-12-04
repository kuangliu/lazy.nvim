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

-------------------------------
-- Plugins
-------------------------------
M = require('util')

require('lazy').setup({
  --------------------
  -- Onedark
  --------------------
  {
    'kuangliu/onedark.vim',
    config = function()
      vim.cmd([[colorscheme onedark]])
      vim.cmd([[set background=dark]])
    end,
  },

  --------------------
  -- Nvim-tree
  --------------------
  {
    'kuangliu/nvim-tree.lua',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    opts = {
      view = {
        width = 30,
        side = 'left',
        mappings = {
          custom_only = false,
          list = {
            { key = { 'l', '<CR>', 'o', 'e' }, action = 'edit' },
            {
              key = 'h',
              action = 'my_close_node',
              action_cb = M.nvim_tree_close_node,
            },
            { key = 'i', action = 'vsplit' },
          },
        },
      },
      filters = {
        dotfiles = true,
        custom = {},
        exclude = {},
      },
      git = {
        enable = true,
        ignore = true,
        timeout = 400,
      },
      renderer = {
        icons = {
          webdev_colors = false,
          git_placement = 'before',
          padding = ' ',
          symlink_arrow = ' ➜ ',
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
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
    },
    config = true,
    keys = {
      { '<Leader>f', M.nvim_tree_find },
      { '<S-r>', ':NvimTreeRefresh<CR>' },
    },
    init = function()
      vim.cmd([[autocmd BufEnter * lua require('nvim-tree').find_file(false)]])
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
  -- Flash Jump
  --------------------
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      search = { multi_window = false },
      label = { uppercase = false },
      modes = {
        search = { enabled = false },
        char = { enabled = false },
      },
    },
    config = function(_, opts)
      require('flash').setup(opts)
      local hls = {
        FlashMatch = { fg = '#61AFEF' },
        FlashCurrent = { fg = '#61AFEF' },
        FlashLabel = { fg = '#E06C75' },
      }
      for hl_group, hl in pairs(hls) do
        hl.default = true
        vim.api.nvim_set_hl(0, hl_group, hl)
      end
    end,
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end },
      { "f", mode = { "n", "x", "o" }, M.hopword },
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
  -- Conform reformat
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
      confrom.setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'autopep8' },
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
      { '<C-f>', ':Telescope find_files find_command=fd,--hidden,--no-ignore<CR>' },
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
        winblend = 3,
        highlights = {
          border = 'Normal',
          background = 'Normal',
        },
      },
    },
    keys = {
      { '<ESC>', [[<C-\><C-n>]], mode = 't' },
      { '2', ':ToggleTerm dir=./ direction=float<CR>' },
      { 'tr', ':ToggleTerm dir=./ direction=vertical<CR>' },
      { 'tb', ':ToggleTerm dir=./ direction=horizontal<CR>' },
      { 'zg', M.lazygit_toggle },
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
      local Path = require('plenary.path')
      require('session_manager').setup({
        sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),
        path_replacer = '__',
        colon_replacer = '++',
        autoload_mode = require('session_manager.config').AutoloadMode.CurrentDir,
        autosave_last_session = true,
        autosave_ignore_not_normal = true,
        autosave_ignore_filetypes = { 'gitcommit' },
        autosave_only_in_session = false,
        max_path_length = 80,
      })

      local config_group = vim.api.nvim_create_augroup('MyConfigGroup', {})
      vim.api.nvim_create_autocmd({ 'SessionLoadPost' }, {
        group = config_group,
        callback = function()
          require('nvim-tree').toggle(true, true)
        end,
      })
    end,
  },

  --------------------
  -- Lualine
  --------------------
  {
    'hoob3rt/lualine.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'onedark',
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        icons_enabled = false,
        globalstatus = true,
      },
      extensions = { 'nvim-tree', 'toggleterm' },
      sections = { lualine_c = { { 'filename', path = 2 } } },
    },
  },

  --------------------
  -- Bufferline
  --------------------
  {
    'kuangliu/bufferline.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    opts = {
      options = {
        indicator = { icon = '' },
        separator_style = { '', '' },
        modified_icon = '•',
        show_buffer_icons = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        enforce_regular_tabs = false,
        max_name_length = 300,
        tab_size = 15,
      },
      highlights = {
        fill = {
          bg = '#282C34',
        },
        background = {
          fg = '#778899',
          bg = '#282C34',
          bold = true,
        },
        tab_close = {
          bg = '#282C34',
        },
        separator = {
          fg = '#282C34',
          bg = '#282C34',
        },
        buffer_selected = {
          fg = '#282C34',
          bg = '#778899',
          bold = true,
        },
        modified_selected = {
          fg = '#282C34',
          bg = '#778899',
          bold = true,
        },
        duplicate_selected = {
          fg = '#282C34',
          bg = '#778899',
          italic = true,
        },
        duplicate_visible = {
          bg = '#282C34',
          fg = '#778899',
          italic = true,
        },
        duplicate = {
          bg = '#282C34',
          fg = '#778899',
          italic = true,
        },
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
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'kuangliu/friendly-snippets',
    },
    config = function()
      require('luasnip.loaders.from_vscode').load()

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end

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
        -- Codeium = '',
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
      }

      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        sources = {
          { name = 'luasnip' },
          -- { name = 'codeium' },
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        },
        mapping = {
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { 'i', 's' }),

          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),

          ['<CR>'] = cmp.mapping.confirm({ select = false }),
        },
        experimental = {
          ghost_text = true,
        },
        formatting = {
          format = function(entry, vim_item)
            -- Kind icons
            vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
            -- Source
            vim_item.menu = ({
              buffer = '[Buffer]',
              nvim_lsp = '[LSP]',
              luasnip = '[LuaSnip]',
              nvim_lua = '[Lua]',
              -- codeium = '[Codeium]',
              latex_symbols = '[LaTeX]',
            })[entry.source.name]
            return vim_item
          end,
        },
      })
    end,
  },

  --------------------
  -- LSP
  --------------------
  {
    'neovim/nvim-lspconfig',
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, opts)
        end,
      })

      vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        signs = { severity_limit = 'Hint' },
        virtual_text = { severity_limit = 'Warning' },
      })

      local nvim_lsp = require('lspconfig')
      nvim_lsp['lua_ls'].setup({})
      nvim_lsp['pyright'].setup({})
      nvim_lsp['rust_analyzer'].setup({})
    end,
  },

  --------------------
  -- Lsp-signature
  --------------------
  {
    'ray-x/lsp_signature.nvim',
    opts = { handler_opts = { border = 'none' } },
    config = true,
  },

  --------------------
  -- vim-illuminate
  --------------------
  {
    'RRethy/vim-illuminate',
    config = function()
      require('illuminate').configure({})
    end,
  },
})
