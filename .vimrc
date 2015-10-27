set nocompatible



" This marks the beginning of Vundle's config

filetype off                 " required
" set the runtime path to include Vundle and initialise
set rtp+=$VIMRUNTIME/../vimfiles/bundle/neobundle.vim
call neobundle#begin('$VIMRUNTIME/../vimfiles/bundle')

" let Vundle manage Vundle, required
NeoBundleFetch 'Shougo/neobundle.vim'

" Add plugins here
NeoBundle 'tpope/vim-surround'
NeoBundle 'Conque-GDB'

" Languages:
NeoBundle 'PProvost/vim-ps1'
NeoBundle 'octol/vim-cpp-enhanced-highlight'
NeoBundle 'vim-pandoc/vim-pandoc'
NeoBundle 'vim-pandoc/vim-pandoc-syntax'

" UI:
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'mbbill/undotree'
NeoBundle 'mhinz/vim-startify'
NeoBundle 'bling/vim-airline'
"NeoBundle 'itchyny/lightline.vim'
"NeoBundle 'tpope/vim-vinegar'
"NeoBundle 'sjl/gundo.vim'
NeoBundle 'Shougo/vimproc.vim', {
\ 'build' : {
\     'windows' : 'tools\\update-dll-mingw',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make',
\     'linux' : 'make',
\     'unix' : 'gmake',
\    },
\ }

" Git:
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'idanarye/vim-merginal'
"NeoBundle 'Xuyuanp/nerdtree-git-plugin'
"NeoBundle 'airblade/vim-gitgutter'

" Intelligence:
NeoBundle 'scrooloose/syntastic'
NeoBundle 'Valloric/YouCompleteMe'
NeoBundle 'editorconfig/editorconfig-vim'

" YCM: {{{
let g:ycm_global_ycm_extra_conf = $VIMRUNTIME . "/../../DotFiles/.ycm_extra_conf.py"
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
" }}}

" Colorschemes:
"NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'morhetz/gruvbox'
"NeoBundle 'chriskempson/vim-tomorrow-theme'
"NeoBundle 'jonathanfilip/vim-lucius'
"NeoBundle 'sjl/badwolf'
"NeoBundle 'nanotech/jellybeans.vim'
"NeoBundle 'tomasr/molokai'
"NeoBundle 'vyshane/cleanroom-vim-color'
"NeoBundle 'romainl/apprentice'
"NeoBundle 'endel/vim-github-colorscheme'


call neobundle#end()            " required
" End of Vundle's config
NeoBundleCheck


imap jk <esc>
map <space> :
nnoremap <F5> :UndotreeToggle<CR>
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <C-c> :bp\|bd #<CR>

filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
set number
set relativenumber
set numberwidth=4
set cursorline

" source $VIMRUNTIME/vimrc_example.vim
" source $VIMRUNTIME/mswin.vim
" behave mswin

" Backup/Persistance Settings
set undodir=$VIMRUNTIME/../tmp/undo/
set backupdir=$VIMRUNTIME/../tmp/backup/,.
set directory=$VIMRUNTIME/../tmp/swap/,.
set backup
set writebackup
set noswapfile

" Gundo Settings
set undofile
set history=100
set undolevels=100

set hidden

set foldmethod=marker

"set lines=25 columns=80
autocmd GUIEnter * simalt ~x
set colorcolumn=80
set guifont=Consolas_for_Powerline_FixedD:h10:cANSI
set guioptions-=e
set guioptions-=m
set guioptions-=T

set laststatus=2
set noshowmode

" Nah: don't need NERDTree until needed :3
" autocmd VimEnter *
"             \   if !argc()
"             \ |     Startify
"             \ |     NERDTree
"             \ |     wincmd w
"             \ | endif

"let g:lightline = {
"            \ 'colorscheme': 'jellybeans',
"            \ 'component': {
"            \   'readonly': '%{&readonly?"":""}',
"            \ },
"            \ 'separator': { 'left': '', 'right': '' },
"            \ 'subseparator': { 'left': '', 'right': '' }
"            \ }

let g:airline_powerline_fonts = 1
set encoding=utf-8

if !empty("CONEMUBUILD")
    set termencoding=utf8
    set term=xterm
    set mouse=a
    set t_Co=256
    let &t_AB="\e[48;5;%dm"
    let &t_AF="\e[38;5;%dm"
    inoremap <Esc>[62~ <C-X><C-E>
    inoremap <Esc>[63~ <C-X><C-Y>
    nnoremap <Esc>[62~ <C-E>
    nnoremap <Esc>[63~ <C-Y>
endif

colorscheme gruvbox
set background=dark
syntax on

let g:cpp_class_scope_highlight = 1

let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = ' -std=c++11 -stdlib=libc++'

let g:syntastic_mode_map = {
    \ "mode": "passive",
    \ "active_filetypes": [],
    \ "passive_filetypes": [] }

" Editorconfig
let g:EditorConfig_exclude_patterns = ['fugitive://.*']


" Don't show seperators
"let g:airline_left_sep=''
"let g:airline_right_sep=''

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_left_sep = '⮀'
let g:airline_left_alt_sep = '⮁'
let g:airline_right_sep = '⮂'
let g:airline_right_alt_sep = '⮃'
let g:airline_symbols.branch = '⭠'
let g:airline_symbols.readonly = '⭤'
let g:airline_symbols.linenr = '⭡'


let g:airline#extensions#tabline#enabled = 1

" let g:NERDTreeIndicatorMapCustom = {
"     \ "Modified"  : "·",
"     \ "Staged"    : "+",
"     \ "Untracked" : "◦",
"     \ "Renamed"   : "r",
"     \ "Unmerged"  : "═",
"     \ "Deleted"   : "−",
"     \ "Dirty"     : "#",
"     \ "Clean"     : "c",
"     \ "Unknown"   : "?"
"     \ }

" unicode symbols
"let g:airline_left_sep = '»'
"let g:airline_left_sep = '?'
"let g:airline_right_sep = '«'
"let g:airline_right_sep = '?'
"let g:airline_symbols.linenr = '?'
"let g:airline_symbols.linenr = '?'
"let g:airline_symbols.linenr = '¶'
"let g:airline_symbols.branch = '?'
"let g:airline_symbols.paste = '?'
"let g:airline_symbols.paste = 'Þ'
"let g:airline_symbols.paste = '?'
"let g:airline_symbols.whitespace = '?'

"set diffexpr=MyDiff()
"function MyDiff()
"  let opt = '-a --binary '
"  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
"  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
"  let arg1 = v:fname_in
"  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
"  let arg2 = v:fname_new
"  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
"  let arg3 = v:fname_out
"  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
"  let eq = ''
"  if $VIMRUNTIME =~ ' '
"    if &sh =~ '\<cmd'
"      let cmd = '""' . $VIMRUNTIME . '\diff"'
"      let eq = '"'
"    else
"      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
"    endif
"  else
"    let cmd = $VIMRUNTIME . '\diff'
"  endif
"  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
"endfunction

