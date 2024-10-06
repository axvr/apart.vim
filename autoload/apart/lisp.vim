" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         autoload/apart/lisp.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

" Smarter J mapping for Lisp dev: removes extra whitespace before closing
" brackets.
function! apart#lisp#J(count) abort
    let c = a:count
    while c > 0
        normal! J
        let nextchar  = getline('.')[getcursorcharpos()[2] - 1]
        let nnextchar = getline('.')[getcursorcharpos()[2]]
        if nextchar ==# ' ' && (nnextchar ==# ']' || nnextchar ==# '}')
            normal! x
        endif
        let c -= 1
    endwhile
endfunction

function! apart#lisp#Init() abort
    if apart#Conf('lisp_J', 0)
        nnoremap <silent> <buffer> J :<C-u>call apart#lisp#J(v:count1)<CR>
    endif
endfunction
