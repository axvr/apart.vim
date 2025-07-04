" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         autoload/apart/lisp.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

" Smarter J mapping for Lisp dev: removes extra whitespace before closing
" brackets and after opening ones.
function! apart#lisp#J() abort
    normal! J
    let prevchar  = getline('.')[getcursorcharpos()[2] - 2]
    let nextchar  = getline('.')[getcursorcharpos()[2] - 1]
    let nnextchar = getline('.')[getcursorcharpos()[2]]
    if nextchar ==# ' ' && ((nnextchar ==# ']' || nnextchar ==# '}')
                            \ || (prevchar ==# '[' || prevchar ==# '{'))
        normal! x
    endif
endfunction

noremap <Plug>(apart/lisp_J) :<C-u>ApartCall apart#lisp#J()<CR>

function! apart#lisp#NextForm(top_level = 0, look_backward = 0) abort
    let pattern = '\m' . (a:top_level ? '^' : '') . '[([{]'
    let flags = 'W' . (a:look_backward ? 'b' : 'z')
    call search(pattern, flags)
endfunction

noremap <Plug>(apart/lisp_motions.top_form_next) :<C-u>ApartCall apart#lisp#NextForm(1, 0)<CR>
noremap <Plug>(apart/lisp_motions.top_form_prev) :<C-u>ApartCall apart#lisp#NextForm(1, 1)<CR>
noremap <Plug>(apart/lisp_motions.form_next)     :<C-u>ApartCall apart#lisp#NextForm(0, 0)<CR>
noremap <Plug>(apart/lisp_motions.form_prev)     :<C-u>ApartCall apart#lisp#NextForm(0, 1)<CR>

function! apart#lisp#Init() abort
    if apart#Conf('lisp_J', 0)
        map <silent> <buffer> J <Plug>(apart/lisp_J)
    endif

    if apart#Conf('lisp_motions', 0)
        map <silent> <buffer> ]] <Plug>(apart/lisp_motions.top_form_next)
        map <silent> <buffer> [[ <Plug>(apart/lisp_motions.top_form_prev)
        map <silent> <buffer> ) <Plug>(apart/lisp_motions.form_next)
        map <silent> <buffer> ( <Plug>(apart/lisp_motions.form_prev)
    endif
endfunction
