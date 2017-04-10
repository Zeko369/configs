""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""		__      _______ __  __ _____   _____ 		    ""
""		\ \    / /_   _|  \/  |  __ \ / ____|               ""
""		 \ \  / /  | | | \  / | |__) | |     		    ""
""		  \ \/ /   | | | |\/| |  _  /| |                    ""
""		 _ \  /   _| |_| |  | | | \ \| |____                ""
""		(_) \/   |_____|_|  |_|_|  \_\\_____|               ""
""								    ""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"HELLO, I'm Zeko369 and this is my vim config, if you are reading this that
"means that you use vim or are about to use vim, great choice, I like you
"some hints are on the bottom
"you can use it as you wish, that includes copying and distributing if it is noted that this is my config
"
"NAVIGATION (relative number from this line, maybe not accurete because i adde someting)
"1. Plugins.....................................8			
"	- Powerline.............................26	
"	- Pathongen.............................31
"	- Vundle................................34
"	- neocomplete...........................57
"	- Ctrl - P..............................83
"	- Nerdtree..............................86
"2.  Tabs (	)...............................108
"3.  Tabs (windows).............................111
"4.  Leaders....................................119
"5.  Looks......................................114
"6.  Numbers....................................120
"7.  Smart movements1...........................135
"8.  Splits.....................................143
"8.  Smart movements improvements...............147
"9.  Folds......................................154
"10. Search.....................................164
"11. Some my lazy features......................170
"12. Brackets...................................175
"13. Hell for others............................183
"14. Touchbar...................................191
"15. Filetyps...................................209
"16. Some others................................213
"17. HINTS......................................226

"Plugins
"POWERLINE setup
set rtp+=/usr/local/lib/python2.7/dist-packages/powerline/bindings/vim/
set laststatus=2
set t_Co=256

"PATHONGEN
execute pathogen#infect()
let g:vim_arduino_ino_cmd = 'ano'

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
Plugin 'sudar/vim-arduino-syntax'
Plugin 'Shougo/neocomplete'
Plugin 'Shougo/neosnippet'
Plugin 'Shougo/neosnippet-snippets'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdtree'

Plugin 'jplaut/vim-arduino-ino'

call vundle#end()            " required
filetype plugin indent on    " required

"neocomplete
let g:acp_enableAtStartup = 0
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neosnippet#enable_snipmate_compatibility = 1
let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'
let g:neosnippet#snippets_directory='~/.vim/bundle/vim-arduino-snippets/Ultisnips/'
let g:neocomplete#sources#tags#cache_limit_size = 16777216 " 16MB

"inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>" "easier way for this down"

" SuperTab like snippets behavior.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
imap <expr><TAB>
 \ pumvisible() ? "\<C-n>" :
 \ neosnippet#expandable_or_jumpable() ?
 \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

"CTRL P
let g:ctrlp_map = '<c-f>'

"Nerdtree
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

let g:NERDDefaultAlign = 'left'
" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"mother of tabs(dragons)
set tabstop=8
set shiftwidth=8
set softtabstop=8

"other kind of tabs
map <C-t>	:tabnew<CR>
noremap <Up>    gT
noremap <Down>  gt
inoremap <S-Tab>	gT
noremap <S-Tab>		gT
let notabs = 0

"leader mappings
let mapleader="-"
map w<leader> :w<Enter>
map <leader>r :%s/

"looks
syntax on
set t_Co=256                        " force vim to use 256 colors
let g:solarized_termcolors=256      " use solarized 256 fallback
set background=dark

"numbers
set nu
set relativenumber
set number

"speeding movement
nnoremap <C-j>		3j
vnoremap <C-j>		3j
nnoremap <C-k>		3k
vnoremap <C-k>		3k
" nnoremap <C-w>		3w
" vnoremap <C-w>		3w
nnoremap <C-b>		3b
vnoremap <C-b>		3b
nnoremap <C-e>		3<C-e>
nnoremap <C-y>		3<C-y>

"splits
set splitbelow
set splitright


"vims smart movement made smarter
nnoremap B ^
nnoremap E $
map Y      y$
inoremap jk <ESC>
vnoremap jk <ESC>

"folds
set foldenable
set foldlevel=10
set foldnestmax=10
filetype plugin indent on
"set foldmethod=marker
"set foldmethod=indent
set foldmethod=syntax
nnoremap <space> za

"serach
set incsearch
set ignorecase
set smartcase
set hlsearch

"lazy features
map <C-L>  ma$a;<Esc>`a
set clipboard=unnamedplus

"autocomplete brackets
inoremap {      {}<Left>
"inoremap [      []<Left>
"inoremap (      ()<Left>
"inoremap "      ""<Left>
"inoremap '      ''<Left>
"inoremap <      <><Left>

"make vim hell for non vim users (remove arrow keys)
inoremap <Up>   <Esc>
inoremap <Down> <Esc>
inoremap <Left> <Esc>
inoremap <Right> <Esc>
noremap <Left>  <Esc>
noremap <Right> <Esc>

"'touchbar' (functions row) mapings
map <F1>                :help<Enter>
map <F2>                :w<Enter>
map <C-F2>              :w
map <F3>                :wq<Enter>
map <F4>                :q!<Enter>
set pastetoggle=<F5>
map <C-H>		I
map <F6>		:nohlsearch<CR>
map <F12>		:NERDTreeToggle<CR>
map <Leader><F12>	:NERDTreeFind<CR>
map <Leader><F8>		<C-Y>:sleep 150ms<CR><Esc>k<Leader><F8>
map <Leader><F9>		<C-Y>:sleep 50ms<CR><Esc>k<Leader><F9>
map <Leader><F10>		<C-Y>:sleep 20ms<CR><Esc>k<Leader><F10>
map <F8>		<C-E>:sleep 150ms<CR><Esc>j<F8>
map <F9>		<C-E>:sleep 50ms<CR><Esc>j<F9>
map <F10>		<C-E>:sleep 20ms<CR><Esc>j<F10>

"filetypes
autocmd Filetype python set tabstop=8

"some other commands
set mouse=a
set wrap
set showcmd
set showmatch
set textwidth=150
set nocompatible "vim only no vi
set ruler "show cursor all the time
"set lazyredraw
set wildmenu
set backupdir=~/.vim_backup

"Arduino
au BufRead,BufNewFile *.pde set filetype=arduino
au BufRead,BufNewFile *.ino set filetype=arduino
autocmd Filetype arduino map <C-U> :ArduinoUpload
" autocmd Filetype arduino map <C-S-U> :ArduinoUpload
" autocmd Filetype arduino map <C-U> :ArduinoUpload
" autocmd Filetype arduino map <C-U> :ArduinoUpload
let g:arduino_cmd = '/home/zeko/installs/arduino-1.8.1/arduino'
let g:arduino_dir = '/home/zeko/installs/arduino-1.8.1'

"USFULL STUFF
":%s/old/new/gc for replace with confirmation
"or just use leader r for replace without comfirm
"H, M, L - top, mid, bottom
":w !sudo tee % make currnet file sudo editable
"Macros
"	qa - record macro a
"	q  - stop recording
"	@q - play macro a
"zz move screen to cursor
"fx find x
"tx find x - 1
"~  TO MAKE SELECTED TEXT TOGGLE CAPS

