local function map(mode, key, action)
  vim.keymap.set(mode, key, action, { silent = true })
end

----------------------
-- General settings
----------------------
local M = require('util')

-- Map the leader key
vim.g.mapleader = ' '

-- ESC to clear search highlight & save
map('n', '<ESC>', ':w|nohlsearch<CR>')

-- Save while existing insert mode
map('i', '<ESC>', '<ESC>:w<CR>')

-- Map 1 to reformat
map('n', '1', ':lua vim.lsp.buf.format()<CR>')

-- Map 2 to toggle float term
map('n', '2', ':ToggleTerm dir=./ direction=float<CR>')

-- Map q/Q to exit/quit
map('n', 'q', ':exit<CR>')
map('n', 'Q', ':wqa!<CR>')

-- Delete from line start to end of previous line
map('n', '<Leader>dk', '^hvk$d<CR>')

-- Delete from cursor to end of previsou line
map('n', 'dk', 'vk$d')

-- Move current line up and down
map('n', '<c-k>', ':move -2<CR>')
map('n', '<c-j>', ':move +1<CR>')

-- Fix indent blocks
map('v', '<', '<gv')
map('v', '>', '>gv')

-- Replace ciw with cc
map('n', 'cc', 'ciw')

-- Copy to clipboard
map('v', '<Leader>y', '"+y')

-- Replace word under cursor
-- map('n', '<Leader>r', ':%s/\\<<c-r><c-w>\\>//g<left><left>', { silent=false })

-- CMake
map('n', '@b', ':!cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build<CR>')
map('n', '@g', ':!./build/main<CR>')

----------------------
-- Window settings
----------------------
map('n', '<s-l>', ':vertical resize -5<CR>')
map('n', '<s-h>', ':vertical resize +5<CR>')
map('n', '<s-k>', ':resize +5<CR>')
map('n', '<s-j>', ':resize -5<CR>')

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
map('n', ']b', ':bn<CR>')
map('n', '[b', ':bp<CR>')
map('n', '<Leader>bw', ':<c-u>bp <bar> bd #<CR>') -- quit current buffer
map('n', '<Leader>bo', M.buf_only)
map('n', '<Leader>br', M.move_buf_vsp)
