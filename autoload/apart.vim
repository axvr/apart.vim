" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         autoload/apart.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

vim9script

const apart_escape_char = '\'
const apart_auto_escape = 0

const apart_pairs = {
            \   '(': ')',
            \   '[': ']',
            \   '{': '}',
            \   '"': '"',
            \   "'": "'"
            \ }

def Conf(name: string, default: any): any
    return get(b:, name, get(g:, name, default))
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
    const pairs = Conf('apart_pairs', apart_pairs)
    const prevprevchar = GetChar(-2)
    const escchar = Conf('apart_escape_char', apart_escape_char)

    # Backspace escaped quote.
    if prevprevchar ==# escchar
        if Conf('apart_auto_escape', apart_auto_escape) && delim ==# '"'
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
    return GetChar(1) ==# close
                \ ? "\<C-G>U\<BS>\<DEL>"
                \ : "\<BS>"
enddef

export def apart#backspace(): string
    const prevchar = GetChar(-1)
    const pairs = Conf('apart_pairs', apart_pairs)

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
    return GetChar(1) ==# close
                \ ? "\<C-G>U\<Right>"
                \ : close
enddef

export def apart#open(open: string, close: string): string
    return GetChar(-1) ==# apart_escape_char || GetChar(1) =~# '\m[^ \t\.)}\]]'
                \ ? open
                \ : open .. close .. "\<C-G>U\<Left>"
enddef

# Escape character can be configured using "apart_escape_char".
# Disable auto-escaped quote character insertion using "apart_auto_escape".
export def apart#quote(char: string): string
    const escchar = Conf('apart_escape_char', apart_escape_char)
    const prevchar = GetChar(-1)

    # Return the actual value if escaped (preceded by the escape character).
    if prevchar ==# escchar
        return char
    endif

    # Test if can close.
    const jump = apart#close(char)
    if jump !=# char
        return jump
    endif

    if Conf('apart_auto_escape', apart_auto_escape)
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

export def apart#cr(): string
    const nextchar = GetChar(1)
    const prevchar = GetChar(-1)

    if (prevchar ==# '{' && nextchar ==# '}') || (prevchar ==# '[' && nextchar ==# ']')
        return "\<C-G>U\<CR>\<C-o>O"
    else
        return "\<CR>"
    endif
enddef

export def apart#init(): void
    if !get(b:, 'apart_initialised', 0)
        b:apart_initialised = 1
        lockvar b:apart_initialised

        for [open, close] in items(Conf('apart_pairs', apart_pairs))
            if open ==# close
                exec 'inoremap <expr> <buffer> <silent> ' .. open .. ' apart#quote("'
                            \ .. escape(open, '"') .. '")'
            else
                exec 'inoremap <expr> <buffer> <silent> ' .. open .. ' apart#open("'
                            \ .. escape(open, '"') .. '", "' .. escape(close, '"') .. '")'
                exec 'inoremap <expr> <buffer> <silent> ' .. close .. ' apart#close("'
                            \ .. escape(close, '"') .. '")'
            endif
        endfor

        inoremap <expr> <buffer> <silent> <BS> apart#backspace()

        if Conf('apart_cr', 0)
            inoremap <expr> <buffer> <silent> <CR> apart#cr()
        endif
    endif
enddef
