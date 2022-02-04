" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         plugin/apart.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

vim9script

augroup apart_defaults
    autocmd!

    autocmd FileType lisp,clojure,scheme,racket b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', '"': '"' },
                \   'return_split': {},
                \   'space_split': {},
                \   'lisp_J': 1
                \ }

    autocmd FileType vim b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', "'": "'" },
                \   'return_split': {}
                \ }

    autocmd FileType python,cs b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', '"': '"', "'": "'" },
                \ }

    autocmd FileType javascript,typescript,json,perl,sh b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', '"': '"', "'": "'", '`': '`' },
                \ }
augroup END

augroup apart
    autocmd!
    autocmd BufEnter * :call apart#Init()
augroup END
