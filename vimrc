set t_Co=256
colorscheme lucius

" automatic runtime management (https://github.com/tpope/vim-pathogen)
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

syntax on
filetype plugin indent on

set incsearch   " show search results as I type.
set ignorecase  " ignore case on searches...
set smartcase   " ...but if I start with uppercase, obey it.
set number      " always display line numbers
set modelines=3 " scan 3 lines for vim opts
set ruler       " show ruler with filename & cursor position
set hlsearch    " search is highlighted, nohlsearch do disable
set cursorline  " set a highlight on the line where the cursor is
set showcmd     " show partial command entered
set visualbell  " no beeps when I make a mistakes
set background=dark " need bright colors since terminal background is black
set hidden       " don't bug me with modified buffers when switching
set switchbuf=useopen " if buffer is opened focus on it

" proper behavior of DEL, BS, CTLR-w; otherwise you can't BS after an ESC
set backspace=eol,start,indent

" window width size, don't squeeze too much
set winwidth=50
set winminwidth=50

" from gary bernhardt - store temp files in a central spot
" first dir found is used.
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

" ignoring some files in search (also Command-T respect this setting)
set wildignore+=*.class,*.jar " Java artifact
set wildignore+=target/** " Maven artifacts
set wildignore+=_site/** " Jekyll artifact
set wildignore+=tmp/**,log/** " rails working directories
set wildignore+=vendor/** " where gems usually get installed

set laststatus=2 " always show statusline even on sigle window
set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

" no tabs, expand them to 2 spaces
set tabstop=2
set shiftwidth=2
set expandtab

" leave some room when jumping
set scrolloff=6

" OmniCompletion settings
set omnifunc=syntaxcomplete#Complete
set completeopt=menu,preview,longest

" save files when suspending with CTRL-Z
map <C-z> :wa\|:suspend<cr>

" quick switch between alternate buffer
nnoremap <leader><leader> <c-^>

" Command-T style file selection using selecta
nnoremap <leader>t :exec ":e " SelectaCommand(FindWithWildignore())<cr>

" search google for links and filter results through selecta
inoremap <c-l> <c-r>=SearchGoogleSelecta()<cr>

" from gary bernhardt, tab or completion
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

" rename current file
nnoremap <leader>n :call RenameFile()<cr>

" clear search on return in normal mode...
function! MapCR()
  nnoremap <cr> :nohlsearch<cr>
endfunction
call MapCR()
" ... but not for command and quickfix windows
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
autocmd CmdwinEnter * nnoremap <cr> <cr>
autocmd CmdwinLeave * call MapCR()

" this is a fix for a bad default in Java syntax file
" which highlights C++ keywords as errors
let java_allow_cpp_keywords=1

" Force write when open readonly files
command! SudoWrite :w !sudo tee %

" originally .md is for modula2, I use for markdown format
autocmd BufNewFile,BufRead *.md set filetype=markdown

" Default to Perl6 instead of Perl5 filetype
autocmd BufNewfile,BufRead *.t,*.pm,*.pl set filetype=perl6

" keep cursor position, ref: https://github.com/garybernhardt/dotfiles/blob/master/.vimrc line 87
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif

function! InsertTabWrapper()
    let col = col('.') - 1
    if col && getline('.')[col - 1] == '='
      return "> "
    elseif !col || getline('.')[col - 1] !~ '\k'
      return "\<tab>"
    else
      return "\<c-p>"
    endif
endfunction

" from gary bernhardt, rename file
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
      :w!
      exec ':saveas ' . new_name
      exec ':silent !rm ' . old_name
      redraw!
    endif
endfunction

" CSE means Clear Screen and Execute, use it by
" mapping (depending of the project) to a test runner command
" map <leader>r CSE('rspec', '--color')<cr>
function! CSE(runthis, ...)
  :wa
  exec ':!clear && tput cup 1000 0;' . a:runthis . ' ' . join(a:000, ' ')
endfunction

" Run a given vim command on the results of fuzzy selecting from a given shell
" command.
function! SelectaCommand(choice_command)
  try
    silent let selection = system(a:choice_command . " | selecta ")
  catch /Vim:Interrupt/
    " Swallow the ^C so that the redraw below happens; otherwise there will be
    " leftovers from selecta on the screen
    redraw!
    return ""
  endtry
  redraw!
  return selection
endfunction

" Creates a find command ignoring paths and files set in wildignore
function! FindWithWildignore()
  let excluding=""
  for entry in split(&wildignore,",")
    let excluding.= (match(entry,'*/*') ? " ! -ipath \'" : " ! -iname \'") . entry . "\' "
  endfor
  return "find * -type f \\\( " . excluding . " \\\)"
endfunction

" Request user input and search google filtered by selecta
function! SearchGoogleSelecta()
  call inputsave()
  let search = input("Search Google for: ")
  call inputrestore()
  let search_cmd = "googlesearch " . search ." | jq '.items[].link' | tr -d '\"' "
  return substitute(SelectaCommand(search_cmd), '\n$', '', '')
endfunction

" arrows disabled on insert and normal mode
noremap <up> <nop>
noremap <down> <nop>
noremap <left> <nop>
noremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" some color changes
highlight Pmenu      ctermfg=Black ctermbg=LightGrey
highlight PmenuSel   ctermfg=Black ctermbg=Yellow
highlight PmenuSbar  ctermfg=Black ctermbg=LightGrey
highlight PmenuThumb ctermfg=DarkGrey
highlight Visual     ctermfg=Black ctermbg=White cterm=NONE
highlight Search     ctermfg=White ctermbg=Magenta
highlight IncSearch  ctermfg=Blue ctermbg=White
highlight LineNr     ctermfg=Grey
