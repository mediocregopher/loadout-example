call plug#begin('~/.config/nvim/plugged')
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive' " needed so airline will show git branch
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
Plug 'benekastah/neomake'
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'tomlion/vim-solidity'
call plug#end()

" NERDTree #####################################################################
let NERDTreeMouseMode=3
let NERDTreeMinimalUI=1
let NERDTreeAutoDeleteBuffer=1
let NERDTreeHighlightCursorline=1
let NERDTreeShowHidden=1
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "Δ",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "☢",
    \ "Deleted"   : "-",
    \ "Dirty"     : "Δ",
    \ "Clean"     : "",
    \ "Unknown"   : ""
    \ }

map <C-n> :NERDTreeToggle<CR>
" always enter term buffer in insert mode
autocmd BufEnter * if &buftype == 'terminal' | :startinsert | endif

" airline ######################################################################
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers=0
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#show_tab_type = 0

" youcompleteme ################################################################
let g:ycm_path_to_python_interpreter = "/usr/bin/python"
let g:ycm_autoclose_preview_window_after_insertion = 1
autocmd! User YouCompleteMe if !has('vim_starting') | call youcompleteme#Enable() | endif

" neomake ######################################################################
autocmd! BufWritePost * Neomake
"let g:neomake_verbose=3
"let g:neomake_logfile='/tmp/neomake.log'

" the sidebar sign placement wasn't playing nice with gitgutter, so use the
" location list instead. But location list is kinda dumb cause it pops open
" multiple times and at weird times, sooo.... fuck it
"let g:neomake_open_list=2
let g:neomake_open_list=0
let g:neomake_place_signs=0

let g:neomake_go_enabled_makers = ['go', 'gometalinter', 'misspell']
let g:neomake_go_gometalinter_maker = {
    \ 'args': [
        \ '--disable-all',
        \ '--enable',   'deadcode',
        \ '--severity', 'deadcode:error',
        \ '--enable',   'vet',
        \ '--severity', 'vet:error',
        \ '--enable',   'gofmt',
        \ '--severity', 'gofmt:error',
        \ '--enable',   'golint',
        \ '--severity', 'golint:error',
        \ '--enable',   'ineffassign',
        \ '--severity', 'ineffassign:error',
        \ '.'
    \ ],
    \ 'append_file': 0,
    \ 'cwd': '%:h',
    \ 'errorformat': '%f:%l:%c:%t%*[^:]: %m',
    \ }

let g:neomake_go_misspell_maker = {
    \ 'errorformat': '%f:%l:%c:%m',
    \ }

let g:neomake_markdown_enabled_makers = ['misspell']
let g:neomake_markdown_misspell_maker = {
    \ 'errorformat': '%f:%l:%c:%m',
    \ }

" mine #########################################################################

"Makes current line/column highlighted, and set text width
set tw=80
set colorcolumn=+1
"autocmd bufenter * set cursorline   cursorcolumn   colorcolumn=+1
"autocmd bufleave * set nocursorline nocursorcolumn colorcolumn=0
hi ColorColumn ctermfg=none ctermbg=lightgrey cterm=none
"hi CursorLine ctermfg=none ctermbg=lightgrey cterm=none
"hi CursorColumn ctermfg=none ctermbg=lightgrey cterm=none

"Buffers scroll a bit so cursor doens't go all the way to the bottom before
"scroll begins
set scrolloff=3

"Makes all .swp files go to /tmp instead of . CAUSE FUCK DA POLICE
set backupdir=/tmp
set directory=/tmp

"Better indenting
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4

"Show eol and tabs
set list
set listchars=trail:░,tab:►\ ,extends:>,precedes:<

"Don't highlight search matches, don't jump while mid-search
set noincsearch
set nohlsearch

"We want certain types to only have 2 space for tabs
au FileType clojure setlocal tabstop=2 shiftwidth=2
au FileType ruby    setlocal tabstop=2 shiftwidth=2
au FileType yaml    setlocal tabstop=2 shiftwidth=2

"We want certain types to use tabs instead of spaces
au FileType go      setlocal nolist noexpandtab
au FileType make    setlocal nolist noexpandtab

"use goimports for formatting instead of gofmt
let g:go_fmt_command = "goimports"

"terminal shortcuts
tnoremap <leader><leader> \
tnoremap <leader> <C-\><C-n>

"tab shortcuts
noremap tn :tabe term://zsh<CR>
noremap tN :tabe<CR>
noremap ts :vs term://zsh<CR>
noremap tS :vnew<CR>
noremap ti :sp term://zsh<CR>
noremap tI :new<CR>
noremap th gT
noremap tH :-tabmove<CR>
noremap tl gt
noremap tL :+tabmove<CR>
noremap t<C-w> :tabclose<CR>

" yank/paste into/from clipboard
set clipboard+=unnamedplus

"Clojure specific mappings
" Eval outerform
au FileType clojure nmap <buffer> cpP :Eval<cr>
" Eval full page
au FileType clojure nmap <buffer> cpR :%Eval<cr>

