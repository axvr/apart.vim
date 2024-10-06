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

function! apart#lisp#NextForm(look_forward = 1) abort
    call search('\m[([{]', 'Wz' . (a:look_forward ? '' : 'b'))
endfunction

function! apart#lisp#NextTopForm(look_forward = 1) abort
    call search('\m^[([{]', 'Wz' . (a:look_forward ? '' : 'b'))
endfunction

function! apart#lisp#Init() abort
    if apart#Conf('lisp_J', 0)
        nnoremap <silent> <buffer> J :<C-u>call apart#lisp#J(v:count1)<CR>
    endif

    if apart#Conf('lisp_motions', 0)
        nnoremap <silent> <buffer> ) :<C-u>call apart#lisp#NextForm()<CR>
        nnoremap <silent> <buffer> ( :<C-u>call apart#lisp#NextForm(0)<CR>
        nnoremap <silent> <buffer> } :<C-u>call apart#lisp#NextTopForm()<CR>
        nnoremap <silent> <buffer> { :<C-u>call apart#lisp#NextTopForm(0)<CR>
    endif
endfunction
