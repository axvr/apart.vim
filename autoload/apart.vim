" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         autoload/apart.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

vim9script

const apart_config = {
      'pairs': { '(': ')', '[': ']', '{': '}', '"': '"' },
      'return_split': { '[': ']', '{': '}' },
      'space_split': { '[': ']', '{': '}' },
      'string_auto_escape': 0,
      'escape_char': '\',
      'lisp_J': 0,
      'lisp_object_motions': 0
    }

export def Conf(name: string, default: any): any
    const user_config = get(b:, 'apart_config', get(g:, 'apart_config', {}))
    const merged_config = extendnew(apart_config, user_config)
    return get(merged_config, name, default)
enddef

def SyntaxMatch(pat: string, line: number, col: number): bool
    const stack = synstack(line, col)
    # TODO: check entire stack?
    return (synIDattr(get(stack, -1, -1), 'name') =~? pat)
      \ || (synIDattr(get(stack, -2, -1), 'name') =~? pat)
enddef

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
        if Conf('string_auto_escape', 0) && delim ==# '"'
            return "\<BS>\<BS>"
        else
            return "\<BS>"
        endif
    endif

    if GetChar(1) != get(pairs, delim)
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

export def Backspace(): string
    const prevchar = GetChar(-1)
    const pairs = Conf('pairs', {})

    if has_key(pairs, prevchar)
        const open = prevchar
        const close = get(pairs, open)

        if open ==# close
            return BackspaceQuote(open)
        else
            return BackspacePair(open, close)
        endif
    else
        return "\<BS>"
    endif
enddef

export def Close(close: string): string
    const pairs = Conf('pairs', {})

    # If close was removed from apart_config, return early.
    if index(values(pairs), close) == -1
        return close
    endif

    return GetChar(1) ==# close ? "\<C-G>U\<Right>" : close
enddef

export def Open(open: string, close: string): string
    const pairs = Conf('pairs', {})

    # If open was removed from apart_config, return early.
    if !has_key(pairs, open)
        return open
    endif

    const escchar = Conf('escape_char', '')
    # TODO: add other symbols to this exclude list.
    return empty(escchar) || GetChar(-1) ==# escchar || GetChar(1) =~# '\m[^ \t\.\$)}\]]'
                \ ? open
                \ : open .. close .. "\<C-G>U\<Left>"
enddef

# Escape character can be configured using "escape_char".
# Disable auto-escaped quote character insertion using "string_auto_escape".
export def Quote(char: string): string
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
    const jump = Close(char)
    if jump !=# char
        return jump
    endif

    if Conf('string_auto_escape', 0)
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

export def ReturnSplit(): string
    const pairs = Conf('return_split', {})
    const close = get(pairs, GetChar(-1), '')

    if close !=# '' && close ==# GetChar(1)
        return "\<C-G>U\<CR>\<C-o>O"
    endif

    return "\<CR>"
enddef

export def SpaceSplit(): string
    const pairs = Conf('space_split', {})
    const close = get(pairs, GetChar(-1), '')

    if close !=# '' && close ==# GetChar(1)
        return "\<C-G>U\<Space>\<Space>\<Left>"
    endif

    return "\<Space>"
enddef

export def Init()
    const pairs = Conf('pairs', {})

    for [open, close] in items(pairs)
        if open ==# close
            exec 'inoremap <expr> <buffer> <silent> '
                        \ .. open .. ' apart#Quote("'
                        \ .. escape(open, '"') .. '")'
        else
            exec 'inoremap <expr> <buffer> <silent> '
                        \ .. open .. ' apart#Open("'
                        \ .. escape(open, '"') .. '", "' .. escape(close, '"') .. '")'
            exec 'inoremap <expr> <buffer> <silent> '
                        \ .. close .. ' apart#Close("'
                        \ .. escape(close, '"') .. '")'
        endif
    endfor

    if !empty(pairs)
        inoremap <expr> <buffer> <silent> <BS> apart#Backspace()
    endif

    if !empty(Conf('return_split', {}))
        inoremap <expr> <buffer> <silent> <CR> apart#ReturnSplit()
    endif

    if !empty(Conf('space_split', {}))
        inoremap <expr> <buffer> <silent> <Space> apart#SpaceSplit()
    endif

    apart#lisp#Init()
enddef
