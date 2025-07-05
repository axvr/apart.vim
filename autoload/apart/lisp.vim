" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         autoload/apart/lisp.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

" Smarter J mapping for Lisp dev: removes extra whitepace on the inside of any
" type of bracket when using the `J` mapping (useful for Clojure).
function! apart#lisp#J() abort
    normal! J
    let pos = getcursorcharpos()[2]
    let ctx = getline('.')[pos - 2 : pos]
    if ctx =~# '\(^[\[{(] \| [\]})]$\)'
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
