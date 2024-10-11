" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         autoload/apart/lisp.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

" Smarter J mapping for Lisp dev: removes extra whitespace before closing
" brackets.
function! apart#lisp#J() abort
    normal! J
    let nextchar  = getline('.')[getcursorcharpos()[2] - 1]
    let nnextchar = getline('.')[getcursorcharpos()[2]]
    if nextchar ==# ' ' && (nnextchar ==# ']' || nnextchar ==# '}')
        normal! x
    endif
endfunction

function! apart#lisp#NextForm(top_level = 0, look_backward = 0) abort
    let pattern = '\m' . (a:top_level ? '^' : '') . '[([{]'
    let flags = 'W' . (a:look_backward ? 'b' : 'z')
    call search(pattern, flags)
endfunction

function! apart#lisp#Init() abort
    if apart#Conf('lisp_J', 0)
        nnoremap <silent> <buffer> J :<C-u>call apart#DoTimes(v:count1, {-> apart#lisp#J()})<CR>
    endif

    if apart#Conf('lisp_motions', 0)
        nnoremap <silent> <buffer> ) :<C-u>call apart#DoTimes(v:count1, {-> apart#lisp#NextForm(0, 0)})<CR>
        nnoremap <silent> <buffer> ( :<C-u>call apart#DoTimes(v:count1, {-> apart#lisp#NextForm(0, 1)})<CR>
        nnoremap <silent> <buffer> } :<C-u>call apart#DoTimes(v:count1, {-> apart#lisp#NextForm(1, 0)})<CR>
        nnoremap <silent> <buffer> { :<C-u>call apart#DoTimes(v:count1, {-> apart#lisp#NextForm(1, 1)})<CR>
    endif
endfunction
