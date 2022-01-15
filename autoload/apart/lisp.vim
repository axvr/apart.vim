" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         autoload/apart/lisp.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

vim9script autoload

# Smarter J mapping for Lisp dev: removes extra whitespace before closing
# brackets.
export def J(count: number)
    var c = count
    while c > 0
        normal! J
        const nextchar  = getline('.')[getcursorcharpos()[2] - 1]
        const nnextchar = getline('.')[getcursorcharpos()[2]]
        if nextchar ==# ' ' && (nnextchar ==# ']' || nnextchar ==# '}')
            normal! x
        endif
        c -= 1
    endwhile
enddef
