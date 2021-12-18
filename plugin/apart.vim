" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         plugin/apart.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

augroup apart_defaults
    autocmd!

    autocmd FileType lisp,scheme,clojure let b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', '"': '"' },
                \   'cr_split': {},
                \   'lisp_J': 1
                \ }

    autocmd FileType vim let b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', "'": "'" },
                \   'cr_split': {}
                \ }

    autocmd FileType javascript,typescript let b:apart_pairs = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', '"': '"', "'": "'", '`': '`' },
                \   'cr_split': { '[': ']', '{': '}' }
                \ }
augroup END

augroup apart
    autocmd!
    autocmd BufEnter * :call apart#init()
augroup END
