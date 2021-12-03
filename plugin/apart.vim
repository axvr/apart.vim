" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         plugin/apart.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

augroup apart_defaults
    autocmd!
    autocmd FileType lisp,scheme,clojure let b:apart_pairs = {
                \   '(': ')',
                \   '[': ']',
                \   '{': '}',
                \   '"': '"'
                \ }
    autocmd FileType vim let b:apart_pairs = {
                \   '(': ')',
                \   '[': ']',
                \   '{': '}',
                \   "'": "'"
                \ }
    autocmd FileType javascript,typescript let b:apart_pairs = {
                \   '(': ')',
                \   '[': ']',
                \   '{': '}',
                \   '"': '"',
                \   "'": "'",
                \   '`': '`'
                \ }
augroup END

augroup apart
    autocmd!
    autocmd BufEnter * :call apart#init()
augroup END
