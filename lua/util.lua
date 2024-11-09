local M = {}

function M.save_file()
  local buftype = vim.bo.buftype
  if buftype == 'nofile' or buftype == 'terminal' then
    vim.cmd([[nohlsearch]])
    return
  end
  vim.cmd([[w|nohlsearch]])
end

function M.get_absolute_path()
  if vim.bo.buftype == 'nofile' then
    -- Nvimtree return file path under cursor.
    local api = require('nvim-tree.api')
    local node = api.tree.get_node_under_cursor()
    return node.absolute_path
  end
  -- Return file path of current buffer.
  return vim.fn.expand('%:p')
end

function M.lazygit_toggle()
  local Terminal = require('toggleterm.terminal').Terminal
  local lazygit = Terminal:new({
    cmd = 'lazygit',
    direction = 'float',
    hidden = false,
    float_opts = {
      border = 'curved',
      width = math.floor(vim.o.columns * 0.9),
      height = math.floor(vim.api.nvim_win_get_height(0) * 0.9),
    },
  })
  lazygit:toggle()
end

-- Close all other buffers
function M.buf_only()
  vim.cmd([[BufferLineCloseLeft]])
  vim.cmd([[BufferLineCloseRight]])
  local lazy = require('bufferline.lazy')
  local ui = lazy.require('bufferline.ui')
  ui.refresh()
end

-- Move current buffer vsp
function M.move_buf_vsp()
  -- If current buffer is the only buffer, return
  local num_buffers = #vim.fn.getbufinfo({ buflisted = 1 })
  if num_buffers == 1 then
    return
  end
  local file_path = vim.fn.expand('%:p') -- get current file path
  vim.cmd([[bp | bd #]]) -- close current buffer
  vim.cmd('vsp ' .. file_path) -- reopen in vsp
end

-- Hopword
function M.hopword()
  local Flash = require('flash')

  local function format(opts)
    return {
      { opts.match.label1, 'FlashMatch' },
      { opts.match.label2, 'FlashLabel' },
    }
  end

  Flash.jump({
    search = { mode = 'search' },
    label = { after = false, before = { 0, 0 }, uppercase = false, format = format },
    pattern = [[\<]],
    action = function(match, state)
      state:hide()
      Flash.jump({
        search = { max_length = 0 },
        highlight = { matches = false },
        label = { format = format },
        matcher = function(win)
          return vim.tbl_filter(function(m)
            return m.label == match.label and m.win == win
          end, state.results)
        end,
        labeler = function(matches)
          for _, m in ipairs(matches) do
            m.label = m.label2
          end
        end,
      })
    end,
    labeler = function(matches, state)
      local labels = state:labels()
      for m, match in ipairs(matches) do
        match.label1 = labels[math.floor((m - 1) / #labels) + 1]
        match.label2 = labels[(m - 1) % #labels + 1]
        match.label = match.label1
      end
    end,
  })
end

return M
