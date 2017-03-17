"PATHONGEN
execute pathogen#infect()

"VUNDLE
filetype off    
set nocompatible
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'honza/vim-snippets'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'kien/ctrlp.vim'
Plugin 'sudar/vim-arduino-snippets'
Plugin 'Shougo/neocomplete'
Plugin 'Shougo/neosnippet'
Plugin 'Shougo/neosnippet-snippets'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdtree'
Plugin 'severin-lemaignan/vim-minimap'

call vundle#end()            " required
filetype plugin indent on    " required

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
imap <expr><TAB>
 \ pumvisible() ? "\<C-n>" :
 \ neosnippet#expandable_or_jumpable() ?
 \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

let g:neosnippet#enable_snipmate_compatibility = 1
let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'
let g:neosnippet#snippets_directory='~/.vim/bundle/vim-arduino-snippets/Ultisnips/'
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#sources#tags#cache_limit_size = 16777216 " 16MB
let g:neocomplete#enable_smart_case = 1
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1

" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"POWERLINE setup
set rtp+=/home/zeko/.local/lib/python2.7/site-packages/powerline/bindings/vim/
set laststatus=2
set t_Co=256

"CTRL P
let g:ctrlp_map = '<c-f>'

"colors
set t_Co=256                        " force vim to use 256 colors
let g:solarized_termcolors=256      " use solarized 256 fallback
set background=dark

set mouse=a
set wrap
set showcmd
set showmatch
set pastetoggle=<F5>

set clipboard=unnamedplus

"numbers
set nu
set relativenumber
set number

"foldsjj
set foldenable
set foldlevel=10
set foldnestmax=10

nnoremap <space> za

set foldmethod=indent
filetype plugin indent on
set foldmethod=marker
"set foldlevel=0
"set modelines=1
set foldmethod=syntax

"serach
set incsearch 
set ignorecase
set smartcase
set hlsearch 

set textwidth=150
set nocompatible "vim only no vi
set ruler "show cursor all the time
"set lazyredraw
set tabstop=8
set shiftwidth=8
set softtabstop=8
set wildmenu
syntax on

"copy to clipboard
"vnoremap <C-c> "+y

"nnoremap j gj
"nnoremap k gk
nnoremap <C-j>		3j
vnoremap <C-j>		3j
nnoremap <C-k>		3k
vnoremap <C-k>		3k
nnoremap <C-w>		3w
vnoremap <C-w>		3w
nnoremap <C-b>		3b
vnoremap <C-b>		3b

nnoremap B ^
nnoremap E $

let mapleader="-"
map w<leader> :w<Enter>
map <leader>r :%s/ 

inoremap <C-t>	:tabnew<CR>
noremap <C-t>	:tabnew<CR>
noremap <Up>    gT
noremap <Down>  gt
inoremap <S-Tab>		gT
noremap <S-Tab>		gT

let notabs = 0

"remove arrow
inoremap <Up>   <Esc>
inoremap <Down> <Esc>
inoremap <Left> <Esc>
inoremap <Right> <Esc>
noremap <Left>  <Esc>
noremap <Right> <Esc>

"ending stuff
inoremap jk <ESC>
vnoremap jk <ESC>
inoremap {      {}<Left>
""inoremap [      []<Left>
""inoremap (      ()<Left>
""inoremap "      ""<Left>
""inoremap '      ''<Left>
""inoremap <    <><Left>

map <F1>                :help<Enter>
map <F2>                :w<Enter>
map <C-F2>              :w
map <F3>                :wq<Enter>
map <F4>                :q!<Enter>
map <C-H>		I
map <F6>		:nohlsearch<CR>
map <F12>		:NERDTreeToggle<CR>
map <C-n>		:NERDTreeToggle<CR>
map <Leader><F12>	:NERDTreeFind<CR>
map <Leader><F8>		<C-Y>:sleep 150ms<CR><Esc>k<Leader><F8>
map <Leader><F9>		<C-Y>:sleep 50ms<CR><Esc>k<Leader><F9>
map <Leader><F10>		<C-Y>:sleep 20ms<CR><Esc>k<Leader><F10>
map <F8>		<C-E>:sleep 150ms<CR><Esc>j<F8>
map <F9>		<C-E>:sleep 50ms<CR><Esc>j<F9>
map <F10>		<C-E>:sleep 20ms<CR><Esc>j<F10>

map Y                   y$
nnoremap <C-L>  $a;<Esc>
nnoremap <C-c>  0i//<Esc>
autocmd Filetype python nnoremap <C-c>	0i## <Esc>
autocmd Filetype python set tabstop=8 
