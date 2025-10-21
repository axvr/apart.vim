" ==================== APART.VIM ====================
" Repository:   <https://github.com/axvr/apart.vim>
" File:         plugin/apart.vim
" Author:       Alex Vear <alex@vear.uk>
" Legal:        No rights reserved.  Public domain.
" ===================================================

" Run the given arg multiple times based on the count.
command! -nargs=+ ApartCall call apart#DoTimes(v:count1, {-> <args>})

augroup apart_defaults
    autocmd!

    autocmd FileType lisp,clojure,edn,scheme,chicken,guile,racket,elisp,hy,lfe,txr,tl,arc,bel,bass
                \ let b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', '"': '"' },
                \   'return_split': {},
                \   'space_split': {},
                \   'lisp_J': 1,
                \   'lisp_motions': 1
                \ }

    autocmd FileType elixir
                \ let b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', '"': '"', "'": "'" },
                \   'lisp_J': 1
                \ }

    autocmd FileType vim
                \ let b:apart_config = {
                \   'pairs': { '(': ')', '[': ']', '{': '}', "'": "'" },
                \   'return_split': {}
                \ }

    autocmd FileType python,cs,toml
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

    autocmd FileType markdown
                \ let b:apart_config = {
                \   'space_split': {}
                \ }
augroup END

augroup apart
    autocmd!
    autocmd BufEnter * :call apart#Init()
augroup END
