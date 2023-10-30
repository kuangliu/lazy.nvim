local M = {}

function M.nvim_tree_close_node(node)
  local view = require('nvim-tree.view')
  local renderer = require('nvim-tree.renderer')
  local core = require('nvim-tree.core')
  local utils = require('nvim-tree.utils')

  local fs_stat = node.fs_stat
  local parent = node.parent
  if fs_stat.type == 'directory' and node.open then
    parent = node
  end

  if not parent or parent.cwd then
    return view.set_cursor({ 1, 0 })
  end

  local _, line = utils.find_node(core.get_explorer().nodes, function(n)
    return n.absolute_path == parent.absolute_path
  end)

  view.set_cursor({ line + 1, 0 })
  parent.open = false
  renderer.draw()
end

function M.nvim_tree_find()
  local view = require('nvim-tree.view')
  if view.is_visible() then
    view.close()
  else
    local buf = vim.api.nvim_buf_get_name(0)
    if string.len(buf) == 0 then
      require('nvim-tree').toggle(false)
    else
      require('nvim-tree').find_file(true)
    end
  end
end

function M.lazygit_toggle()
  local Terminal = require('toggleterm.terminal').Terminal
  local lazygit = Terminal:new({
    cmd = 'lazygit',
    direction = 'float',
    hidden = true,
    float_opts = {
      border = 'curved',
      width = math.floor(vim.api.nvim_win_get_width(0) * 0.9),
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
  vim.cmd([[bp | bd #]])                 -- close current buffer
  vim.cmd('vsp ' .. file_path)           -- reopen in vsp
end

return M
