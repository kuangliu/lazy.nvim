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
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-------------------------------
-- General settings
-------------------------------
require('key')

local default_options = {
  number = true, -- show number
  expandtab = true, -- expand tabs into spaces
  shiftwidth = 2, -- shift lines by 2 spaces
  tabstop = 2, -- 2 whitespaces for tabs visual presentation
  cursorline = true, -- highlight current row
  cursorcolumn = true, -- highlight current column
  scrolloff = 10, -- let 10 lines before/after cursor during scroll
  fileencoding = 'utf-8', -- the encoding written to a file
  termguicolors = true, -- set color
  splitbelow = true,
  splitright = true,
  clipboard = 'unnamedplus',
  swapfile = false,
  ignorecase = true,
  shell = 'zsh',
  mouse = 'v',
  so = 999, -- scroll with cursor centering
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
    lazy = false,
    opts = {
      view = {
        width = 30,
        side = 'left',
        mappings = {
          custom_only = false,
          list = {
            { key = { 'l', '<CR>', 'o', 'e' }, action = 'edit' },
            { key = 'h', action = 'my_close_node', action_cb = M.nvim_tree_close_node },
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
            -- default = '',
            default = '',
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
              -- unstaged = '✗',
              unstaged = '•',
              staged = '✓',
              unmerged = '',
              renamed = '➜',
              -- untracked = '★',
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
      { '<leader>f', M.nvim_tree_find },
      { '<S-r>', ':NvimTreeRefresh<cr>' },
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
  -- Vim-easymotion
  --------------------
  {
    'kuangliu/vim-easymotion',
    keys = {
      { 's', '<Plug>(easymotion-s2)' },
      { 'f', '<Plug>(easymotion-sl)' },
    },
  },

  --------------------
  -- Mason
  --------------------
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    keys = { { '<Leader>ma', ':Mason<cr>', desc = 'Mason' } },
    opts = {
      ensure_installed = {
        'stylua',
        'shfmt',
        'autopep8',
        'clang-format',
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
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
  -- Copilot
  --------------------
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    build = ':Copilot auth',
    config = function()
      require('copilot').setup({
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = '<S-l>',
            prev = '<C-h>',
            next = '<C-l>',
          },
        },
      })
    end,
  },

  --------------------
  -- null-ls
  --------------------
  {
    'jose-elias-alvarez/null-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'mason.nvim' },
    opts = function()
      local nls = require('null-ls')
      return {
        root_dir = require('null-ls.utils').root_pattern('.null-ls-root', '.neoconf.json', 'Makefile', '.git'),
        sources = {
          nls.builtins.formatting.fish_indent,
          nls.builtins.formatting.stylua.with({
            extra_args = { '--indent-type', 'Spaces', '--indent-width', '2', '--quote-style', 'AutoPreferSingle' },
          }),
          nls.builtins.formatting.autopep8.with({
            extra_args = { '--max-line-length', '100' },
          }),
          nls.builtins.formatting.clang_format.with({
            extra_args = { '--style', 'Chromium' },
          }),
          nls.builtins.formatting.shfmt,
          nls.builtins.diagnostics.fish,
          nls.builtins.diagnostics.autopep8,
        },
      }
    end,
  },

  --------------------
  -- Telescope
  --------------------
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
    },
    keys = {
      { '<c-f>', ':Telescope find_files<cr>' },
      { '<c-g>', ':Telescope live_grep<cr>' },
    },
  },

  --------------------
  -- Smooth-scroll
  --------------------
  {
    'karb94/neoscroll.nvim',
    opts = {
      -- All these keys will be mapped to their corresponding default scrolling animation
      mappings = { '<C-u>', '<C-d>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
      hide_cursor = true, -- Hide cursor while scrolling
      stop_eof = true, -- Stop at <EOF> when scrolling downwards
      use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
      respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
      cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
      easing_function = nil, -- Default easing function
      pre_hook = nil, -- Function to run before the scrolling animation starts
      post_hook = nil, -- Function to run after the scrolling animation ends
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
      { '<leader>c', ':CommentToggle<cr>', mode = 'v' },
      { '<leader>c', ':CommentToggle<cr>', mode = 'n' },
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
    opts = {
      -- size can be a number or function which is passed the current terminal
      size = function(term)
        if term.direction == 'horizontal' then
          return 20
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<c-\>]],
      hide_numbers = true, -- hide the number column in toggleterm buffers
      shade_filetypes = {},
      shade_terminals = false,
      shading_factor = 1, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
      start_in_insert = true,
      insert_mappings = true, -- whether or not the open mapping applies in insert mode
      persist_size = true,
      -- direction = 'vertical' | 'horizontal' | 'window' | 'float',
      close_on_exit = true, -- close the terminal window when the process exits
      shell = vim.o.shell, -- change the default shell
      -- This field is only relevant if direction is set to 'float'
      float_opts = {
        -- The border key is *almost* the same as 'nvim_open_win'
        -- see :h nvim_open_win for details on borders however
        -- the 'curved' border is a custom border type
        -- not natively supported but implemented in this plugin.
        border = 'curved', -- 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
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
      { '<esc>', [[<C-\><C-n>]], mode = 't' },
      { 'tb', ':ToggleTerm dir=./ direction=horizontal<CR>' },
      { 'tr', ':ToggleTerm dir=./ direction=vertical<CR>' },
      { 'tf', ':ToggleTerm dir=./ direction=float<CR>' },
      { 'tt', ':ToggleTerm dir=./ direction=float<CR>' },
      { 'zg', M.lazygit_toggle },
    },
  },

  --------------------
  -- Surround
  --------------------
  {
    'ur4ltz/surround.nvim',
    config = function()
      require('surround').setup({ mappings_style = 'surround' })
    end,
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
        autosave_ignore_filetypes = {
          'gitcommit',
        },
        autosave_only_in_session = false,
        max_path_length = 80,
      })

      local config_group = vim.api.nvim_create_augroup('MyConfigGroup', {}) -- A global group for all your config autocommands
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
      sections = {
        lualine_c = {
          {
            'filename',
            path = 2,
          },
        },
      },
    },
  },

  --------------------
  -- Bufferline
  --------------------
  {
    'akinsho/bufferline.nvim',
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
    config = function()
      require('nvim-autopairs').setup({})
    end,
  },

  --------------------
  -- Treesitter
  --------------------
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup({
        highlight = {
          enable = true,
          custom_captures = {
            -- Highlight the @foo.bar capture group with the "Identifier" highlight group.
            ['foo.bar'] = 'Identifier',
          },
          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  },

  --------------------
  -- Indent-line
  --------------------
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      char = '│',
      filetype_exclude = { 'help', 'alpha', 'dashboard', 'neo-tree', 'Trouble', 'lazy' },
      show_trailing_blankline_indent = false,
      show_current_context = false,
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
      -- LuaSnip
      require('luasnip.loaders.from_vscode').load()

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end

      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        sources = {
          -- { name = 'copilot' },
          { name = 'luasnip' },
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
      })
    end,
  },

  --------------------
  -- LSP
  --------------------
  {
    'neovim/nvim-lspconfig',
    config = function()
      local nvim_lsp = require('lspconfig')

      -- Use an on_attach function to only map the following keys
      -- after the language server attaches to the current buffer
      local on_attach = function(client, bufnr)
        local function buf_set_keymap(...)
          vim.api.nvim_buf_set_keymap(bufnr, ...)
        end
        local function buf_set_option(...)
          vim.api.nvim_buf_set_option(bufnr, ...)
        end

        -- Enable completion triggered by <c-x><c-o>
        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        local opts = { noremap = true, silent = true }

        buf_set_keymap('n', '<Leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        -- buf_set_keymap('n', '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        -- buf_set_keymap('n', '<Leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)  -- pyright can't do formatting
        -- vim.api.nvim_command[[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
      end

      nvim_lsp['pyright'].setup({
        on_attach = on_attach,
      })

      nvim_lsp['clangd'].setup({
        on_attach = on_attach,
      })
    end,
  },

  --------------------
  -- vim-illuminate
  --------------------
  {
    'RRethy/vim-illuminate',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { 'lsp' },
      },
    },
    config = function(_, opts)
      require('illuminate').configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set('n', key, function()
          require('illuminate')['goto_' .. dir .. '_reference'](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' Reference', buffer = buffer })
      end

      map(']]', 'next')
      map('[[', 'prev')

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map(']]', 'next', buffer)
          map('[[', 'prev', buffer)
        end,
      })
    end,
    keys = {
      { ']]', desc = 'Next Reference' },
      { '[[', desc = 'Prev Reference' },
    },
  },
})
