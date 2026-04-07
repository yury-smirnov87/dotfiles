if not CURSES then
	view:set_theme('light', {font = 'JetBrains Mono Nerd Font', size = 11})
end

-- Always use spaces for indentation.
io.detect_indentation = false
buffer.use_tabs = false
buffer.tab_width = 2

textadept.editing.strip_trailing_spaces = true
textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_CURRENT

-- 1. Clear any existing binding for Ctrl+D to prevent "Select Word"
keys['ctrl+d'] = nil

-- 3. Optional: If you want to make sure Ctrl+Shift+D doesn't
-- also do it, you can nil that out too
keys['ctrl+D'] = nil

-- 2. Explicitly bind it to duplicate line using the buffer object
keys['ctrl+d'] = function()
  buffer:line_duplicate()
end


