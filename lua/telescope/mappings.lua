-- TODO: Customize keymap
local a = vim.api

local state = require('telescope.state')

local mappings = {}
local keymap = {}

mappings.set_keymap = function(prompt_bufnr, results_bufnr)
  local function default_mapper(map_key, table_key)
    a.nvim_buf_set_keymap(
      prompt_bufnr,
      'i',
      map_key,
      string.format(
        [[<C-O>:lua __TelescopeMapping(%s, %s, '%s')<CR>]],
        prompt_bufnr,
        results_bufnr,
        table_key
        ),
      {
        silent = true,
      }
    )
  end

  default_mapper('<c-n>', 'control-n')
  default_mapper('<c-p>', 'control-p')
  default_mapper('<CR>', 'enter')
end

local function update_current_selection(prompt_bufnr, change)
  state.get_status(prompt_bufnr).picker:move_selection(change)
end


function __TelescopeMapping(prompt_bufnr, results_bufnr, characters)
  if keymap[characters] then
    keymap[characters](prompt_bufnr, results_bufnr)
  end
end

-- TODO: Refactor this to use shared code.
-- TODO: Move from top to bottom, etc.
-- TODO: It seems like doing this brings us back to the beginning of the prompt, which is not great.
keymap["control-n"] = function(prompt_bufnr, _)
  update_current_selection(prompt_bufnr, 1)
end

keymap["control-p"] = function(prompt_bufnr, _)
  update_current_selection(prompt_bufnr, -1)
end

keymap["enter"] = function(prompt_bufnr, results_bufnr)
  local row = state.get_status(prompt_bufnr).picker:get_selection()
  if row == nil then
    print("Could not do anything...")
    return
  else
    local line = a.nvim_buf_get_lines(results_bufnr, row, row + 1, false)[1]
    if line == nil then
      print("Could not do anything with blank line...")
      return
    end

    local sections = vim.split(line, ":")

    local filename = sections[1]
    local row = tonumber(sections[2])
    local col = tonumber(sections[3])

    vim.cmd(string.format([[bdelete! %s]], prompt_bufnr))

    local bufnr = vim.fn.bufnr(filename, true)
    a.nvim_set_current_buf(bufnr)
    a.nvim_buf_set_option(bufnr, 'buflisted', true)
    if row and col then
      a.nvim_win_set_cursor(0, {row, col})
    end
  end
end

return mappings
