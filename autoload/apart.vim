" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         autoload/apart.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

let s:apart_config = {
    \   'pairs': { '(': ')', '[': ']', '{': '}', '"': '"' },
    \   'return_split': { '[': ']', '{': '}' },
    \   'space_split': { '[': ']', '{': '}' },
    \   'string_auto_escape': 0,
    \   'escape_char': '\',
    \   'lisp_J': 0,
    \   'lisp_object_motions': 0
    \ }

function! apart#Conf(name, default)
    let user_config = get(b:, 'apart_config', get(g:, 'apart_config', {}))
    let merged_config = extendnew(s:apart_config, user_config)
    return get(merged_config, a:name, a:default)
endfunction

function! s:SyntaxMatch(pat, line, col)
    let stack = synstack(a:line, a:col)
    " TODO: check entire stack?
    return (synIDattr(get(stack, -1, -1), 'name') =~? a:pat)
      \ || (synIDattr(get(stack, -2, -1), 'name') =~? a:pat)
endfunction

" s:GetChar(0)  -> an empty string.
" s:GetChar(1)  -> next character (the one under the cursor).
" s:GetChar(-1) -> character before the cursor.
function! s:GetChar(rel_idx)
    let line = getline('.')
    let cur = getcursorcharpos()
    let idx = cur[2] + a:rel_idx - 1

    if a:rel_idx == 0
        return ''
    elseif a:rel_idx > 0
        let idx = idx - 1
    endif

    if idx < 0 || idx > (len(line) - 1)
        " TODO: skip over whitespace.
        " TODO: if end of line, check next line (+ repeat if empty).
        " TODO: if start of line, check prev line (+ repeat if empty).
        return ''
    else
        return line[idx]
    endif
endfunction

function! s:BackspaceQuote(delim)
    let pairs = apart#Conf('pairs', {})
    let prevprevchar = s:GetChar(-2)
    let escchar = apart#Conf('escape_char', '')

    " Backspace escaped quote.
    if !empty(escchar) && prevprevchar ==# escchar
        if apart#Conf('string_auto_escape', 0) && a:delim ==# '"'
            return "\<BS>\<BS>"
        else
            return "\<BS>"
        endif
    endif

    if s:GetChar(1) != get(pairs, a:delim)
        return "\<BS>"
    endif

    if empty(prevprevchar) || prevprevchar =~# '\m\s' || prevprevchar != a:delim
        return "\<C-G>U\<BS>\<DEL>"
    endif

    return "\<BS>"
endfunction

function! s:BackspacePair(open, close)
    return s:GetChar(1) ==# a:close ? "\<C-G>U\<BS>\<DEL>" : "\<BS>"
endfunction

function! apart#Backspace()
    let prevchar = s:GetChar(-1)
    let pairs = apart#Conf('pairs', {})

    if has_key(pairs, prevchar)
        let open = prevchar
        let close = get(pairs, open)

        if open ==# close
            return s:BackspaceQuote(open)
        else
            return s:BackspacePair(open, close)
        endif
    else
        return "\<BS>"
    endif
endfunction

function! apart#Close(close)
    let pairs = apart#Conf('pairs', {})

    " If close was removed from apart_config, return early.
    if index(values(pairs), a:close) == -1
        return a:close
    endif

    return s:GetChar(1) ==# a:close ? "\<C-G>U\<Right>" : a:close
endfunction

function! apart#Open(open, close)
    let pairs = apart#Conf('pairs', {})

    " If open was removed from apart_config, return early.
    if !has_key(pairs, a:open)
        return a:open
    endif

    let escchar = apart#Conf('escape_char', '')
    " TODO: add other symbols to this exclude list.
    return empty(escchar) || s:GetChar(-1) ==# escchar || s:GetChar(1) =~# '\m[^ \t\.\$)}\]]'
                \ ? a:open
                \ : a:open . a:close . "\<C-G>U\<Left>"
endfunction

" Escape character can be configured using "escape_char".
" Disable auto-escaped quote character insertion using "string_auto_escape".
function! apart#Quote(char)
    let pairs = apart#Conf('pairs', {})

    " If char was removed from apart_config, return early.
    if !has_key(pairs, a:char)
        return char
    endif

    let escchar = apart#Conf('escape_char', '')
    let prevchar = s:GetChar(-1)

    " Return the actual value if escaped (preceded by the escape character).
    if empty(escchar) || prevchar ==# escchar
        return a:char
    endif

    " Test if can close.
    let jump = apart#Close(a:char)
    if jump !=# a:char
        return jump
    endif

    if apart#Conf('string_auto_escape', 0)
        if prevchar !=# a:char
            let cur = getcurpos()
            " If in a string, escape new double quote characters.
            if a:char ==# '"' && s:SyntaxMatch('\m\cstring', cur[1], cur[2])
                return escchar . a:char
            endif
        elseif s:GetChar(-2) ==# escchar && prevchar ==# a:char
            return escchar . a:char
        endif
    endif

    return prevchar ==# a:char || prevchar =~# '\m\w' || s:GetChar(1) =~# '\m\w'
                \ ? a:char
                \ : a:char . a:char . "\<C-G>U\<Left>"
endfunction

function! apart#ReturnSplit()
    let pairs = apart#Conf('return_split', {})
    let close = get(pairs, s:GetChar(-1), '')

    if close !=# '' && close ==# s:GetChar(1)
        return "\<C-G>U\<CR>\<C-o>O"
    endif

    return "\<CR>"
endfunction

function! apart#SpaceSplit()
    let pairs = apart#Conf('space_split', {})
    let close = get(pairs, s:GetChar(-1), '')

    if close !=# '' && close ==# s:GetChar(1)
        return "\<C-G>U\<Space>\<Space>\<Left>"
    endif

    return "\<Space>"
endfunction

function! apart#Init()
    let pairs = apart#Conf('pairs', {})

    for [open, close] in items(pairs)
        if open ==# close
            exec 'inoremap <expr> <buffer> <silent> '
                        \ . open . ' apart#Quote("'
                        \ . escape(open, '"') . '")'
        else
            exec 'inoremap <expr> <buffer> <silent> '
                        \ . open . ' apart#Open("'
                        \ . escape(open, '"') . '", "' . escape(close, '"') . '")'
            exec 'inoremap <expr> <buffer> <silent> '
                        \ . close . ' apart#Close("'
                        \ . escape(close, '"') . '")'
        endif
    endfor

    if !empty(pairs)
        inoremap <expr> <buffer> <silent> <BS> apart#Backspace()
    endif

    if !empty(apart#Conf('return_split', {}))
        inoremap <expr> <buffer> <silent> <CR> apart#ReturnSplit()
    endif

    if !empty(apart#Conf('space_split', {}))
        inoremap <expr> <buffer> <silent> <Space> apart#SpaceSplit()
    endif

    call apart#lisp#Init()
endfunction
