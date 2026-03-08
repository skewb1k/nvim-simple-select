--- A simple implementation of vim.ui.select using a floating window.
--- Usage: vim.ui.select = require('simple-select')
---
--- MIT License Copyright (c) 2026 skewb1k <skewb1kunix@gmail.com>
return function(items, opts, on_choice)
  if #items == 0 then
    on_choice(nil)
    return
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  local lines = vim.iter(items):map(opts.format_item):totable()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false

  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.6)
  local win = vim.api.nvim_open_win(bufnr, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
  })
  vim.wo[win].winfixbuf = true
  vim.wo[win].cursorline = true

  vim.keymap.set('n', '<CR>', function()
    local cur_row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_delete(bufnr, {})
    on_choice(items[cur_row], cur_row)
  end, { buffer = bufnr })

  vim.api.nvim_create_autocmd('WinClosed', {
    buffer = bufnr,
    callback = function()
      vim.api.nvim_buf_delete(bufnr, {})
      on_choice(nil)
    end,
  })
end
