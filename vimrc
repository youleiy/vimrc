set nocompatible               " be iMproved
filetype off                   " required!


" Some settings are OS-dependent
let s:uname = system("echo -n \"$(uname)\"")

" -----------------------------------------------------------------------------  
"  < 判断是终端还是 Gvim >  
" -----------------------------------------------------------------------------  
if has("gui_running")  
    let g:isGUI = 1  
else  
    let g:isGUI = 0  
endif  

" ----------------------------------------- Basic Settings ---------------------------------------------- {{{
"syntax on
syntax enable
filetype plugin indent on
filetype plugin on

" Text-wrapping stuff. (Also check out my cursorcolumn setting in .gvimrc.)
set textwidth=110 " 80-width lines is for 1995
let &wrapmargin= &textwidth
set formatoptions=croql " Now it shouldn't hard-wrap long lines as you're typing (annoying), but you can gq
                        " as expected.

set hidden "This allows vim to put buffers in the bg without saving, and then allows undoes when you fg them.
set history=1000 "Longer history
set number
set hlsearch
set autoindent
set wildmenu
set wildmode=list:longest
set scrolloff=3 " This keeps three lines of context when scrolling
set expandtab
set smarttab
set ts=4
set sw=4
set sts=4
set laststatus=2
set ignorecase
set smartcase
set undofile
set backspace=indent,eol,start
set incsearch
set nojoinspaces
if exists("&ballooneval")
  set noballooneval " annoying
endif
set encoding=utf8

" When completing, don't automatically select the first choice, but instead just insert the longest common
" text.
set completeopt=menu,longest

" See stuff in .vim/after/plugins/endwise.vim for some more completion settings that necessarily must be
" loaded after endwise. (https://github.com/tpope/vim-endwise/pull/16)
" TODO: Get around this; it's better to have all configuration in this file or in plugins directly.

" Leaving foldmethod=syntax on all the time causes horrible slowdowns for some syntaxes in gvim.
set foldmethod=manual
set foldlevel=99
" TODO(caleb): Investigate and implement a workaround such as those listed here:
" http://vim.wikia.com/wiki/Keep_folds_closed_while_inserting_text

" Allow for modelines
set modeline

let mapleader = ","

" Bells == annoying
set vb
set t_vb=
if has("autocmd") && has("gui")
  au GUIEnter * set t_vb=
endif

" For some reason I accidentally hit this shortcut all the time...let's disable it. (I usually don't look at
" man pages from within vim anyway.)
noremap K <Nop>

" Textmate-style invisible char markers
"set list
"set listchars=tab:\ \ ,eol:¬

" Unify vim's default register and the system clipboard
set clipboard=unnamed
if s:uname == "Linux"
  set clipboard=unnamedplus
endif

" Ensure the temp dirs exist
if !isdirectory($HOME . "/.vim/tmp")
  call system("mkdir -p ~/.vim/tmp/swap")
  call system("mkdir -p ~/.vim/tmp/backup")
  call system("mkdir -p ~/.vim/tmp/undo")
endif

" Change where we store swap/undo files
set dir=~/.vim/tmp/swap//
set backupdir=~/.vim/tmp/backup//
set undodir=~/.vim/tmp/undo/

" Don't back up temp files
set backupskip=/tmp/*,/private/tmp/*

" Don't save other tabs in sessions (as I don't use tabs)
set sessionoptions-=tabpages
" Don't save help pages in sessions
set sessionoptions-=help
" Don't save hidden buffers -- only save the visible ones.
set sessionoptions-=buffers

" Viminfo saves/restores editing metadata in ~/.viminfo.
" '100   Save marks for the last 100 edited files
" f1     Store global marks
" <500   Save max of 500 lines of each register
" :100   Save 100 lines of command-line history
" /100   Save 100 searches
" h      Disable hlsearch when starting
set viminfo='1000,f1,<500,:100,/100,h

" Restore position when reopening a file.
" http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

" }}}

" ----------------------------- Colorscheme Settings (assume Lucius) ------------------------------------ {{{
set t_Co=256
set background=dark
set guifont=DejaVu\ Sans\ mono\ 14 

"let g:solarized_termcolors=256
let g:solarized_termtrans=1
let g:solarized_contrast="normal"
let g:solarized_visibility="normal"

" Molokai Theme
let g:molokai_original = 1
if g:isGUI
    colorscheme solarized
    "colorscheme molokai
else
    "colorscheme solarized
    colorscheme molokai
endif
let g:molokai_original = 1
let g:rehash256 = 1

"LuciusBlack

" Adjust colors as necessary
hi IncSearch       ctermfg=NONE   ctermbg=67
hi Search          ctermfg=NONE   ctermbg=22
hi Comment         ctermfg=245    cterm=NONE
hi MatchParen      ctermfg=NONE   ctermbg=237
hi Error           ctermfg=NONE   ctermbg=239
hi LineNr      ctermfg=245   ctermbg=235

" Show extra whitespace
hi ExtraWhitespace guibg=#CCCCCC
hi ExtraWhitespace ctermbg=7
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

set shortmess=atI " 启动的时候不显示那个援助乌干达儿童的提示
"set term=screen " Set terminal for tmux

" 插入匹配括号
inoremap ( ()<LEFT>
inoremap [ []<LEFT>
inoremap { {}<LEFT>

" 输入一个字符时，如果下一个字符也是括号，则删除它，避免出现重复字符
function! RemoveNextDoubleChar(char)
	let l:line = getline(".")
	let l:next_char = l:line[col(".")] " 取得当前光标后一个字符
 
	if a:char == l:next_char
		execute "normal! l"
	else
		execute "normal! i" . a:char . ""
	end
endfunction
inoremap ) <ESC>:call RemoveNextDoubleChar(')')<CR>a
inoremap ] <ESC>:call RemoveNextDoubleChar(']')<CR>a
inoremap } <ESC>:call RemoveNextDoubleChar('}')<CR>a

" }}}

" ----------------------------- vundle Settings ------------------------------------ {{{
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim' 

" My Bundles here:
"
" original repos on github
Plugin 'tpope/vim-fugitive'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'Lokaltog/vim-powerline'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'tpope/vim-rails.git'
Plugin 'fatih/vim-go'
Plugin 'kien/ctrlp.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'majutsushi/tagbar'
Plugin 'SirVer/ultisnips'
Plugin 'scrooloose/nerdcommenter'
Plugin 'cespare/vim-golang'
" Color theme
Plugin 'tomasr/molokai'  "Molokai theme
Plugin 'altercation/vim-colors-solarized'

" vim-scripts repos
Plugin 'L9'
Plugin 'FuzzyFinder'
Plugin 'taglist.vim'
Plugin 'The-NERD-tree'
Plugin 'winmanager'
Plugin 'minibufexpl.vim'
" non github repos
Plugin 'git://git.wincent.com/command-t.git'
" ...

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


" -------------------------------------- Plugin-specific Settings --------------------------------------- {{{
" Gvim
"Toggle Menu and Toolbar
set guioptions-=m
set guioptions-=T
map <silent> <F2> :if &guioptions =~# 'T' <Bar>
        \set guioptions-=T <Bar>
        \set guioptions-=m <bar>
    \else <Bar>
        \set guioptions+=T <Bar>
        \set guioptions+=m <Bar>
    \endif<CR>

" vim-powerline plugin
set laststatus=2
let g:Powerline_symbols = 'unicode'

" NERDTree plugin
map <C-n> :NERDTreeToggle<CR>

" taglist plugin
let Tlist_Show_Menu = 1
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1

" minibufexpl plugin
" 多文件切换，也可使用鼠标双击相应文件名进行切换
let g:miniBufExplMapWindowNavVim    = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs  = 1
let g:miniBufExplModSelTarget       = 1
"解决FileExplorer窗口变小问题
let g:miniBufExplForceSyntaxEnable = 1
let g:miniBufExplorerMoreThanOne=2
let g:miniBufExplCycleArround=1
" buffer 切换快捷键，默认方向键左右可以切换buffer
map <C-Tab> :MBEbn<cr>
map <C-S-Tab> :MBEbp<cr>

" winmanager plugin
let g:winManagerWindowLayout='FileExplorer|TagList'
nmap wm :WMToggle

" CtrlP plugin
" Open ctrlp
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
" MRU Function，show recently opened files
map <leader>fp :CtrlPMRU<CR>
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux"
"let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll|zip|tar|tar.gz)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

"\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
let g:ctrlp_working_path_mode=0
let g:ctrlp_match_window_bottom=1
let g:ctrlp_max_height=15
let g:ctrlp_match_window_reversed=0
let g:ctrlp_mruf_max=500
let g:ctrlp_follow_symlinks=1

" tagbar plugin
nmap <leader>tb :TagbarToggle<CR>  " ,tb 打开tagbar窗口
let g:tagbar_autofocus = 1

" ultisnips plugin
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
"定义存放代码片段的文件夹 .vim/snippets下，使用自定义和默认的，将会的到全局，有冲突的会提示
"let g:UltiSnipsSnippetDirectories=["snippets", "bundle/ultisnips/UltiSnips"]

" Auto comment
nmap <leader>bn :Tab 

"goimport 
autocmd BufWritePre *.go :Fmt
