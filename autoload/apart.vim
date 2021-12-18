" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         autoload/apart.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

vim9script

const apart_config = {
            \   'pairs': { '(': ')', '[': ']', '{': '}', '"': '"' },
            \   'cr_split': { '[': ']', '{': '}' },
            \   'auto_escape': 0,
            \   'escape_char': '\',
            \   'lisp_J': 0
            \ }

def Conf(name: string, default: any): any
    const user_config = get(b:, 'apart_config', get(g:, 'apart_config', {}))
    const merged_config = extendnew(apart_config, user_config)
    return get(merged_config, name, default)
enddef

if exists('*synstack')
    def SyntaxMatch(pat: string, line: number, col: number): bool
        const stack = synstack(line, col)
        # TODO: check entire stack?
        return (synIDattr(get(stack, -1, -1), 'name') =~? pat)
          \ || (synIDattr(get(stack, -2, -1), 'name') =~? pat)
    enddef
else
    def SyntaxMatch(pat: string, line: number, col: number): bool
        return synIDattr(synID(line, col, 0), 'name') =~? pat
    enddef
endif

# GetChar(0)  -> an empty string.
# GetChar(1)  -> next character (the one under the cursor).
# GetChar(-1) -> character before the cursor.
def GetChar(rel_idx: number): string
    const line = getline('.')
    const cur = getcursorcharpos()
    var idx = cur[2] + rel_idx - 1

    if rel_idx == 0
        return ''
    elseif rel_idx > 0
        idx = idx - 1
    endif

    if idx < 0 || idx > (len(line) - 1)
        # TODO: skip over whitespace.
        # TODO: if end of line, check next line (+ repeat if empty).
        # TODO: if start of line, check prev line (+ repeat if empty).
        return ''
    else
        return line[idx]
    endif
enddef

def BackspaceQuote(delim: string): string
    const pairs = Conf('pairs', {})
    const prevprevchar = GetChar(-2)
    const escchar = Conf('escape_char', '')

    # Backspace escaped quote.
    if !empty(escchar) && prevprevchar ==# escchar
        if Conf('auto_escape', 0) && delim ==# '"'
            return "\<BS>\<BS>"
        else
            return "\<BS>"
        endif
    endif

    if GetChar(1) != pairs[delim]
        return "\<BS>"
    endif

    if empty(prevprevchar) || prevprevchar =~# '\m\s' || prevprevchar != delim
        return "\<C-G>U\<BS>\<DEL>"
    endif

    return "\<BS>"
enddef

def BackspacePair(open: string, close: string): string
    return GetChar(1) ==# close ? "\<C-G>U\<BS>\<DEL>" : "\<BS>"
enddef

export def apart#backspace(): string
    const prevchar = GetChar(-1)
    const pairs = Conf('pairs', {})

    if has_key(pairs, prevchar)
        const open = prevchar
        const close = pairs[open]

        if open ==# close
            return BackspaceQuote(open)
        else
            return BackspacePair(open, close)
        endif
    else
        return "\<BS>"
    endif
enddef

export def apart#close(close: string): string
    const pairs = Conf('pairs', {})

    # If close was removed from apart_config, return early.
    if index(values(pairs), close) == -1
        return close
    endif

    return GetChar(1) ==# close ? "\<C-G>U\<Right>" : close
enddef

export def apart#open(open: string, close: string): string
    const pairs = Conf('pairs', {})

    # If open was removed from apart_config, return early.
    if !has_key(pairs, open)
        return open
    endif

    const escchar = Conf('escape_char', '')
    return empty(escchar) || GetChar(-1) ==# escchar || GetChar(1) =~# '\m[^ \t\.)}\]]'
                \ ? open
                \ : open .. close .. "\<C-G>U\<Left>"
enddef

# Escape character can be configured using "escape_char".
# Disable auto-escaped quote character insertion using "auto_escape".
export def apart#quote(char: string): string
    const pairs = Conf('pairs', {})

    # If char was removed from apart_config, return early.
    if !has_key(pairs, char)
        return char
    endif

    const escchar = Conf('escape_char', '')
    const prevchar = GetChar(-1)

    # Return the actual value if escaped (preceded by the escape character).
    if empty(escchar) || prevchar ==# escchar
        return char
    endif

    # Test if can close.
    const jump = apart#close(char)
    if jump !=# char
        return jump
    endif

    if Conf('auto_escape', 0)
        if prevchar !=# char
            const cur = getcurpos()
            # If in a string, escape new double quote characters.
            if char ==# '"' && SyntaxMatch('\m\cstring', cur[1], cur[2])
                return escchar .. char
            endif
        elseif GetChar(-2) ==# escchar && prevchar ==# char
            return escchar .. char
        endif
    endif

    return prevchar ==# char || prevchar =~# '\m\w' || GetChar(1) =~# '\m\w'
                \ ? char
                \ : char .. char .. "\<C-G>U\<Left>"
enddef

export def apart#cr_split(): string
    const pairs = Conf('cr_split', {})
    const close = get(pairs, GetChar(-1), '')

    if close !=# '' && close ==# GetChar(1)
        return "\<C-G>U\<CR>\<C-o>O"
    endif

    return "\<CR>"
enddef

export def apart#init(): void
    const pairs = Conf('pairs', {})

    for [open, close] in items(pairs)
        if open ==# close
            exec 'inoremap <expr> <buffer> <silent> '
                        \ .. open .. ' apart#quote("'
                        \ .. escape(open, '"') .. '")'
        else
            exec 'inoremap <expr> <buffer> <silent> '
                        \ .. open .. ' apart#open("'
                        \ .. escape(open, '"') .. '", "' .. escape(close, '"') .. '")'
            exec 'inoremap <expr> <buffer> <silent> '
                        \ .. close .. ' apart#close("'
                        \ .. escape(close, '"') .. '")'
        endif
    endfor

    if !empty(pairs)
        inoremap <expr> <buffer> <silent> <BS> apart#backspace()
    endif

    if !empty(Conf('cr_split', {}))
        inoremap <expr> <buffer> <silent> <CR> apart#cr_split()
    endif

    if Conf('lisp_J', 0)
        nnoremap <silent> <buffer> J :<C-u>call apart#lisp_j#J(v:count1)<CR>
    endif
enddef
