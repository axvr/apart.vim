" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         plugin/apart.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

augroup apart_defaults
    autocmd!

    autocmd FileType lisp,clojure,edn,bb,scheme,chicken,guile,racket,elisp,hy,lfe,txr,tl,arc,bel,bass
                \ let b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', '"': '"' },
                \   'return_split': {},
                \   'space_split': {},
                \   'lisp_J': 1,
                \   'lisp_motions': 1
                \ }

    autocmd FileType vim
                \ let b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', "'": "'" },
                \   'return_split': {}
                \ }

    autocmd FileType python,cs
                \ let b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', '"': '"', "'": "'" },
                \ }

    autocmd FileType javascript,typescript,json,perl,sh
                \ let b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', '"': '"', "'": "'", '`': '`' },
                \ }

    autocmd FileType css
                \ let b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', "'": "'", '"': '"' },
                \   'return_split': { '{': '}' },
                \   'space_split': { '{': '}' }
                \ }
augroup END

augroup apart
    autocmd!
    autocmd BufEnter * :call apart#Init()
augroup END
