" C++ uses regex syntax instead of Treesitter (see lua/eraffo/treesitter.lua).
" Regex syntax leaves function names uncolored, so add them: any identifier
" followed by '('. Keywords like `if` still win.
syntax match cppFunctionName "\<\h\w*\ze\s*("
highlight default link cppFunctionName Function
