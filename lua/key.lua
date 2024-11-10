local function map(mode, key, action)
  vim.keymap.set(mode, key, action, { silent = true })
end

----------------------
-- General settings
----------------------
local M = require('util')

-- Map the leader key
vim.g.mapleader = ' '

-- Highlight search, but not move cursor
map('n', '*', '*N')

-- ESC to clear search highlight & save
map('n', '<ESC>', M.save_file)

-- Save while existing insert mode
map('i', '<ESC>', "<ESC>:lua require('util').save_file()<CR>")

-- Map q/Q to exit/quit
map('n', 'q', ':exit<CR>')
map('n', 'Q', ':qa!<CR>')

-- Delete from line start to end of previous line
map('n', 'dk', '^hvk$d')

-- Move current line up and down
map('n', '<C-k>', ':move -2<CR>')
map('n', '<C-j>', ':move +1<CR>')

-- Fix indent blocks
map('v', '<', '<gv')
map('v', '>', '>gv')

-- Replace ciw with cc
map('n', 'cc', 'ciw')

-- Copy to clipboard
map('v', '<Leader>y', '"+y')

-- Paste multiple times
map('v', 'p', '"0p')

-- Copy & replace word
map('n', '<Leader>y', 'yiw')
map('n', '<Leader>p', 'viw"0p')

-- CMake
map('n', '@b', ':!cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build<CR>')
map('n', '@g', ':!./build/main<CR>')

-- Begin & end of line
map({ 'n', 'v' }, '<S-h>', '^')
map({ 'n', 'v' }, '<S-l>', '$')

----------------------
-- Window settings
----------------------
-- map('n', '<S-l>', ':vertical resize -5<CR>')
-- map('n', '<S-h>', ':vertical resize +5<CR>')
-- map('n', '<S-k>', ':resize +5<CR>')
-- map('n', '<S-j>', ':resize -5<CR>')

----------------------
-- Terminal settings
----------------------
map('n', '<Leader>h', ':wincmd h<CR>')
map('n', '<Leader>j', ':wincmd j<CR>')
map('n', '<Leader>k', ':wincmd k<CR>')
map('n', '<Leader>l', ':wincmd l<CR>')

----------------------
-- Tab settings
----------------------
map('n', '<TAB>', ':bn<CR>')
map('n', '<Left>', ':bp<CR>')
map('n', '<Right>', ':bn<CR>')
map('n', '<Leader>bw', ':<C-u>bp <BAR> bd #<CR>') -- quit current buffer
map('n', '<Leader>bo', M.buf_only)
map('n', '<Leader>bb', M.move_buf_vsp)
map('n', 'B', ':BufferLinePick<CR>')
