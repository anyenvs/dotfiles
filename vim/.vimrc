"""
" Plugin management
"""
if empty(glob('~/.vim/bundle/Vundle.vim'))
  silent !curl -fSSLo ~/.vim/bundle/Vundle.vim --create-dirs --depth=1 --single-branch --branch master
    \ https://github.com/VundleVim/Vundle.vim.git
  autocmd VimEnter * PlugInstall --sync
endif
"=====================================================
" Vundle install
"=====================================================
set nocompatible                    " be iMproved, required
set mouse=a                         " Mouse support
set history=50                      " History of commands
filetype off                        " required
filetype plugin indent on           " Enable file type detection
autocmd BufWritePre * %s/\s\+$//e   " Trim whitespace on save

"=====================================================
" Vundle settings
"=====================================================
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
let mapleader=" "
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
" ## VIM Themes
Plugin 'powerline/powerline'
Plugin 'joshdick/onedark.vim'
Plugin 'tomasiser/vim-code-dark'
Plugin 'bling/vim-airline'
Plugin 'itchyny/lightline.vim'
" if you use Vundle, load plugins:
Bundle 'ervandew/supertab'
"#Plugin 'Valloric/YouCompleteMe'
"let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/.ycm_extra_conf.py'
Plugin 'SirVer/ultisnips'
" ## https://github.com/preservim/nerdtree#installation
Plugin 'preservim/nerdtree'
" ## Syntastic is a syntax checking plugin for Vim
" ## https://github.com/vim-syntastic/syntastic
Plugin 'Syntastic'
" ## Fugitive is a Git wrapper for Vim
" ## https://github.com/tpope/vim-fugitive
Plugin 'https://github.com/tpope/vim-fugitive'
" GO completion ## https://github.com/fatih/vim-go#install
Plugin 'fatih/vim-go'
" ## https://github.com/sheerun/vim-polyglot#installation
Plugin 'sheerun/vim-polyglot'
" cht.sh plugin
Plugin 'scrooloose/syntastic'
Plugin 'dbeniamine/cheat.sh-vim'
" fzf.vim plugin
" https://github.com/junegunn/fzf.vim#commands
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
" https://github.com/jistr/vim-nerdtree-tabs#commands-and-mappings
" :NERDTreeFocusToggle  ## https://github.com/jistr/vim-nerdtree-tabs/blob/master/nerdtree_plugin/vim-nerdtree-tabs.vim#L218
Bundle 'jistr/vim-nerdtree-tabs'

" make YCM compatible with UltiSnips (using supertab)
" YouCompleteMe and UltiSnips compatibility, with the helper of supertab
" (via http://stackoverflow.com/a/22253548/1626737)
let g:SuperTabDefaultCompletionType    = '<C-n>'
let g:SuperTabCrMapping                = 0
let g:UltiSnipsExpandTrigger           = '<tab>'
let g:UltiSnipsJumpForwardTrigger      = '<tab>'
let g:UltiSnipsJumpBackwardTrigger     = '<s-tab>'
let g:ycm_key_list_select_completion   = ['<C-j>', '<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-k>', '<C-p>', '<Up>']
"let g:UltiSnipsExpandTrigger="<c-s>"
"let g:UltiSnipsJumpForwardTrigger="<c-j>"
"let g:UltiSnipsJumpBackwardTrigger="<c-k>"
"let g:UltiSnipsSnippetDirectories=["~/.vim/bundle/UltiSnips"]
" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"
" cht.sh
let g:syntastic_javascript_checkers = [ 'jshint' ]
let g:syntastic_ocaml_checkers = ['merlin']
let g:syntastic_python_checkers = ['pylint']
let g:syntastic_shell_checkers = ['shellcheck']

"let g:lightline = {
"  \     'active': {
"  \         'left': [['mode', 'paste' ], ['readonly', 'filename', 'modified']],
"  \         'right': [['lineinfo'], ['percent'], ['fileformat', 'fileencoding']]
"  \     }
"  \ }

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
"Plugin 'tpope/vim-fugitive'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

"=====================================================
" Vim transparent with gpg
"=====================================================
let g:GPGPreferArmor=1
let g:GPGDefaultRecipients=["vlad_m","vyacheslav.malinovskyy@gpg.com"]

"=====================================================
" fzf
"=====================================================
nnoremap <c-p> :Files<cr>
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_layout = { 'down': '~40%' }

"=====================================================
" Custom vim settings
"=====================================================
set backspace=indent,eol,start
color desert
let g:airline_theme='codedark'
"let g:airline_theme='onedark'
"colorscheme onedark
" Vim VScode Theme
colorscheme codedark
" lightline.vim plugin
set laststatus=2
set noshowmode
if !has('gui_running')
  set t_Co=256
endif
" ## Default colorscheme for files
" autocmd BufEnter * colorscheme codedark
autocmd BufEnter *.code-snippets* colorscheme codedark
autocmd BufEnter .bash* colorscheme onedark
autocmd BufEnter *.*t*pl* colorscheme codedark
autocmd FileType python setlocal shiftwidth=2 softtabstop=2 expandtab
" use gofmt compatible tab settings
autocmd FileType go setlocal shiftwidth=2 tabstop=2 softtabstop=2 noexpandtab
" mappings for vim-go
autocmd FileType go nmap <leader>d <plug>(go-doc)
autocmd FileType go nmap <leader>r <plug>(go-run)
autocmd FileType go nmap <leader>b <plug>(go-build)
autocmd FileType go nmap <leader>t <plug>(go-test)
autocmd FileType go nmap <leader>ds <plug>(go-def-split)
autocmd FileType go nmap <leader>dv <plug>(go-def-vertical)
autocmd FileType go nmap <leader>dt <plug>(go-def-tab)
autocmd FileType go nmap gd <plug>(go-def-split)
autocmd BufNewFile,BufRead *.go colorscheme codedark


" get all the errors from syntastic
autocmd FileType go let g:syntastic_aggregate_errors = 1
autocmd FileType go let g:syntastic_go_checkers = ["go", "govet", "golint"]
"# default colorscheme
"autocmd BufEnter * colorscheme desert
autocmd BufEnter *.php colorscheme Tomorrow-Night
autocmd BufEnter *.py colorscheme Tomorrow
" autocmd BufEnter *.bash* colorscheme gruvbox
autocmd BufEnter *.bash* colorscheme codedark "#onedark "#desert
autocmd BufEnter *.tf* colorscheme onedark


" tab spaces https://stackoverflow.com/questions/1878974/redefine-tab-as-4-spaces/1878983#1878983
set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
set expandtab
set autoindent
set number
set cul "Highlight current line
"show all $ and ^M
"set list
syntax on
let g:syntastic_error_symbol = '✗'
let g:syntastic_style_error_symbol = '✠'
let g:syntastic_warning_symbol = '∆'
let g:syntastic_style_warning_symbol = '≈'
let g:is_bash=1
let g:sh_no_error=1

"set ls=2
"set laststatus=2
" tabnew
"set showtabline=2
set statusline="%f%m%r%h%w [%Y] [0x%02.2B]%< %F%=%4v,%4l %3p%% of %L"

"use Ag with ack.vim by adding the following line
let g:ackprg = 'ag --nogroup --nocolor --column'

"define 3 custom highlight groups
hi User1 ctermbg=green ctermfg=red   guibg=green guifg=red
hi User2 ctermbg=red   ctermfg=blue  guibg=red   guifg=blue
hi User3 ctermbg=blue  ctermfg=green guibg=blue  guifg=green

set statusline=
set statusline+=%1*  "switch to User1 highlight
set statusline+=%F   "full filename
set statusline+=%2*  "switch to User2 highlight
set statusline+=%y   "filetype
set statusline+=%3*  "switch to User3 highlight
set statusline+=%l   "line number
set statusline+=%*   "switch back to statusline highlight
set statusline+=%P   "percentage thru file

" =====================================================
" Vim additional keybindings
" Find Key codes using  sed -n l  or  cat
" =====================================================
" ## Alt + leftArrow move to end of word
" ## Alt + rightArrow move to beginning of word
" ## Alt + leftArrow move to end of word in insert mode
" ## Alt + rightArrow move to beginning of word in insert mode
map  <ESC><ESC>[D   b
map  <ESC><ESC>[C   w
map  <ESC>[D        <ESC>[1;2D
map  <ESC>[C        <ESC>[1;2C
imap <ESC><ESC>[D   <ESC>[1;2D
imap <ESC><ESC>[C   <ESC>[1;2C
" Move vertically by visual line
" https://dougblack.io/words/a-good-vimrc.html#movement
nnoremap j gj
nnoremap k gk
" nmap means map in normal mode
" imap means map in insert mode
" nnoremap `nore` part in nnoremap prevent expanding mapping recursively
" =====================================================
" NERDTree config
" =====================================================
" Ctr + l switch to to next tab
" Ctr + h switch to to prev tab
" Ctr + n opens new tab
" Left Arrow to switch tab
" Right Arrow to switch tab
map  <C-l> :tabn<CR>
map  <C-h> :tabp<CR>
map  <C-n> :tabnew<CR>
nnoremap <left> gT
nnoremap <right> gt
" map a specific key or shortcut to open NERDTree
nnoremap <space> ea
"<F2> saves current file in edit mode
"<F2> saves current file
"<F6> open / close NERDTree
imap <F2>  <ESC>:w<CR>
nmap <F2>  <ESC>:w<CR>
nmap <F6>  :NERDTreeToggle<CR>
" TAB switch between NERDTree and Opened file
nmap <TAB> <plug>NERDTreeFocusToggle<CR>
" #nnoremap <silent> <expr> <TAB> :NERDTreeFocus.IsOpen() ? "\:NERDTreeClose<CR>" : bufexists(expand('%')) ? "\:NERDTreeFind<CR>" : "\:NERDTree<CR>"
" NERDTree show hidden files + ignore .git
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.DS_Store$', '\.git$']
let g:NERDTreeChDirMode = 2
" open a NERDTree automatically when vim starts up
" autocmd vimenter * NERDTree
" open a NERDTree automatically when vim starts up if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" open NERDTree automatically when vim starts up on opening a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
" close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" change default arrows
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
" in NERDTree, to open-silently file in newtab with Enter, instead of default pressing "T" (same for not silently with Tab instead of t)
"let NERDTreeMapOpenInTab='<TAB>'
"let NERDTreeMapOpenInTabSilent='<ENTER>'

set smartcase
set ignorecase

"set localtion for temporatry swap (.swp) backup (.~) undo (.un~) files
set backupdir=~/.aliases/tmp/,~/.tmp/,/tmp//
set directory=~/.aliases/tmp/,~/.tmp/,/tmp//
set undodir=~/.aliases/tmp/,~/.tmp/,/tmp//

"change color scheme
if &diff
    "source ~/.vim/colors/mycolorsheme.vim
    source ~/.vim/colors/mycolorscheme2.vim
    "source ~/.vim/colors/molokai.vim
endif

" map Mac OS X Terminal.app default Home and End
":map <ESC>[H <Home>
":map <ESC>[F <End>
":imap <ESC>[H <C-O><Home>
":imap <ESC>[F <C-O><End>
":cmap <ESC>[H <Home>
":cmap <ESC>[F <End>

"jump to first non-whitespace on line, jump to begining of line if already at first non-whitespace
function! LineHome()
  let x = col('.')
  execute "normal ^"
  if x == col('.')
    unmap 0
    execute "normal 0"
    map 0 :call LineHome()<CR>:echo<CR>
  endif
  return ""
endfunction


" jump to the last non-whitespace char on line, or eol if already there
map <End> :call LineEnd()<CR>:echo<CR>
imap <End> <C-R>=LineEnd()<CR>
function! LineEnd()
  let x = col('.')
    execute "normal g_"
  if x == col('.')
    execute "normal $"
  endif
  return ""
endfunction

map  <C-A> <Home>
imap <C-A> <Home>
vmap <C-A> <Home>
map  <C-E> <End>
imap <C-E> <End>
vmap <C-E> <End>

"""
" Glow Markdown
"""
let g:preview_markdown_parser = 'glow'
let g:preview_markdown_vertical = 1
let g:preview_markdown_auto_update = 1
nmap <C-m> :PreviewMarkdown right<CR>
