set nocompatible
filetype plugin indent on

"colorscheme
"crappy: blue, default, morning, peachpuff, shine
"ok: the rest
"zellner maybe too distractive
colorscheme desert

"tabs to spaces
set tabstop=4
set shiftwidth=4
set expandtab

"autocomplete menu in command shows all matches
set wildmenu

"i capitulate to the overwhelming force of the plugins. to use the omnisharper
execute pathogen#infect()

"set the shell to fish. will need to modify so that this only happens if fish
"is available
set shell=/bin/fish

function! s:get_visual_selection()
  " public domain
  " by mr xolox from stackoverflow, who will appreciate this attribution
  " Why is this not a built-in Vim script function?!
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

"open firefox on the visually selected string
function! Firefox()
       let vis = s:get_visual_selection()
       let visual = substitute(vis, "#", '\\\\#', "")
       let com = "!firefox " . visual
       execute com
endfunction

vmap <C-f> :call Firefox()<CR>

"cygwin related
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

"get netrw to delete nonempty directories
let g:netrw_localrmdir='rm -r'

"opens netbeans at the current line of the current file
function! Netbeans()
    let curline = line(".")
    let curfile = expand("%:p")
    let com0 = 'cygpath -w '.curfile
    :echom com0
    let output = system(com0)
    let winpath = substitute(output, "\n", "", "")
    :echom winpath
    let com = '!`netbeans "'.winpath.'":'.curline.'`'
    :echom com
    execute com
endfunction

command! Netbeans call Netbeans()

"opens current file of grep or perg output

function! OpenFile()
    "check if current line has a colon, if so assume its grep output, else
    "assume its perg output
    normal 0y$
    let linetext = @0
    if match(linetext, ":") != -1
        normal 0yt:
        let rawfilename = @0
    else
        let rawfilename = linetext
    endif
    let filename = fnameescape(rawfilename)
    execute "tabe " . filename
endfunction

command! OpenFile call OpenFile()

"this one is more for maven outputs hold the cursor somewhere on the file name
"and open it with this command
function! OpenFile2()
    normal T yt:
    let copied_filename = @0
    let filename = '/c' . substitute(copied_filename, "\\", "\/", "g")
"    echo "filename == " . filename
    let com = "tabe " . filename
    echo com
    execute com
endfunction

command! OpenFile2 call OpenFile2()

function! OpenFile3()
    let vis = s:get_visual_selection()
    let path = substitute(vis, "\\", "/", "g")
    let com = "tabe " . path
    execute com
endfunction

xnoremap <C-o> :call OpenFile3()<CR>

function! OpenFileVisVsplit()
    let vis = s:get_visual_selection()
    let rawpath = substitute(vis, "\\", "/", "g")
    let path = substitute(vis, "\ ", "\\\\ ", "g")
    let com = "vsplit " . path 
    execute com
endfunction

xnoremap <C-v> :call OpenFileVisVsplit()<CR>

let g:pergbuffernumber = 0

function! OpenGrepBuffer()
    let g:pergbuffernumber = g:pergbuffernumber + 1
    let bufname = "Grep_output".g:grepbuffernumber
    let com = "new ".bufname
    execute com
endfunction


"opens a tab with results from a grep for the word under the cursor
function! GrepWord()
    let var = expand("<cword>")
    call OpenGrepBuffer()
    let com = 'read !grep -r "'.var.'"'
    echo com
    execute com
    set ro
endfunction

command! GrepWord call GrepWord()

"keeps track of the buffer name to use for the next perg window
let g:pergbuffernumber = 0

function! OpenPergBuffer()
    let g:pergbuffernumber = g:pergbuffernumber + 1
    let bufname = "Perg_output".g:pergbuffernumber
    let com = "new ".bufname
    execute com
endfunction

"opens a tab with results from a perg.py for the word under the cursor
function! PergWord()
    let var = expand("<cword>")
    call OpenPergBuffer()
    let com = 'read !perg.py . '.var
    echo com
    execute com
    set ro
endfunction

command! PergWord call PergWord()

function! Perg(searchterm)
    call OpenPergBuffer()
    let com = 'read !perg.py . '.a:searchterm
    echo com
    execute com
    set ro
endfunction
            
command! -nargs=1 Perg call Perg(<q-args>)

"unzip a zip from netrw directory browser
function! Unzip()
    let lastdir = getcwd()
    "change cwd to the browsing directory in netrw
    normal c
    normal 0y$
    let linetext = @0
    "remove the star
    let file = substitute(linetext, "*$", "", "")
    let extraction_dir1 = substitute(file, "\.zip$", "", "")
    let extraction_dir1 = substitute(file, "\.war$", "", "")
    let extraction_dir = substitute(extraction_dir1, "\.jar$", "", "")
    let com = '!unzip '.file.' -d '.extraction_dir
    execute com
    "select the directory as it was before
    let com2 = 'cd '.lastdir
    execute com2
endfunction

command! Unzip call Unzip()

"add file to pending changes
function! TFAdd()
    let curfile = expand("%:p")
    let com = 'read !tf add '.curfile
    echo com
    tabe   
    execute com
endfunction

command! TFadd call TFadd()

"view pending changes
function! TFStatus()
    let com = 'read !tf status'
    echo com
    tabe   
    execute com
endfunction

command! TFStatus call TFStatus()

" check in the pending changes
function! TFCheckin(comment)
    let com = 'read !tf checkin -comment "'.a:comment.'"'
    echo com
    tabe
    "execute com
endfunction

command! -nargs=1 TFCheckin call TFCheckin(<q-args>)

"add file to next commit
function! GitAdd()
    let olddir = getcwd()
    let dirofcurfile = expand('%:p:h')
    let com0 = 'cd '.dirofcurfile
    execute com0
    let curfile = expand('%:p')
    let path = RelativeGitPath(curfile)
 
    let com = 'read !git add '.path
    echo com
    tabe   
    execute com
    let com1 = 'cd '.olddir
    execute com1
endfunction

command! GitAdd call GitAdd()

"view git status
function! GitStatus()
    let com = 'read !git status'
    echo com
    tabe
    execute com
endfunction

command! GitStatus call GitStatus()

" commit a change
function! GitCommit(comment)
    let olddir = getcwd()
    let dirofcurfile = expand('%:p:h')
    let com0 = 'cd '.dirofcurfile
    execute com0
    let com = 'read !git commit -m "'.a:comment.'"'
    echo com
    tabe
    execute com
    let com1 = 'cd '.olddir
    execute com1
endfunction

command! -nargs=1 GitCommit call GitCommit(<q-args>)

"push the change
function! GitPush()
    let olddir = getcwd()
    let dirofcurfile = expand('%:p:h')
    let com0 = 'cd '.dirofcurfile
    execute com0
    !git push
    let com1 = 'cd '.olddir
    execute com1
endfunction

command! GitPush call GitPush()

function! GitGraph()
    tabe
    read !git log --graph --abbrev-commit --decorate --date=relative --all
endfunction

command! GitGraph call GitGraph()

function! GitGraph2()
    tabe
    read !git log --graph --oneline --decorate --all
endfunction

command! GitGraph2 call GitGraph2()

function! GitGraph3()
    tabe
    read !git log --graph --full-history --all --pretty=format:"%h%x09%d%x20%s"
endfunction

command! GitGraph3 call GitGraph3()

function! GitAncestorBranch()
    tabe
    read !git show-branch -a| grep '\*'| grep -v `git rev-parse --abbrev-ref HEAD`| head -n1 | sed 's/.*\[\(.*\)\].*/\1/' | 's/[\^~].*//'
endfunction

command! GitAncestorBranch call GitAncestorBranch()

function! GitDiscardChanges()
    new
    read !git stash save --keep-index
endfunction

command! GitDiscardChanges call GitDiscardChanges()

function! GitPull()
    new
    read !git pull
endfunction

command! GitPull call GitPull()

function! Pop(l, i)
    let new_list = deepcopy(a:l)
    call remove(new_list, a:i)
    return new_list
endfunction

"python has a quick way to subtract lists
function! ListSubstract(list1, list2)
python << EOF
import vim
list1 = vim.eval("a:list1")
#print list1
list2 = vim.eval("a:list2")
#print list2
#substract the lists
l = [ x for x in list1 if x not in list2 ]
#print l
liststr = '["'+'",'.join(l)+'"]'
#print liststr
#return to vim
vim.command("let retval = "+liststr)
EOF
    "echo retval
    return retval
endfunction

command! ListSubtractTest call ListSubstract(["1", "2", "3"], ["1", "2"])

"gets the path of relative to the root of the git repository
function! RelativeGitPath(path)
    "split up the path
    let dirs = split(a:path, "/")
    let curdirs = dirs
    "echo curdirs
    "1 is true, 0 is false
    let gitfound = 0
    let length = len(curdirs)
    "until we have the git path
    while !gitfound && length > 0
        "remove the last element of list
        let curdirs = Pop(curdirs, length - 1 )
        "echo curdirs
        let length = length - 1
        "add .git to the list
        let potentialgitdirs = add(curdirs, '.git')
        "echo potentialgitdirs
        "join the path together
        let potentialgitpath = "/".join(curdirs, "/")
        "echo potentialgitpath
        "check whether the .git exists
        if isdirectory(potentialgitpath)
            let gitfound = 1
        endif
        "repeat from step 2
    endwhile
    if !gitfound
        throw 'git path was not found'
    endif
    "subtract all elements from the git path from the original list
    let gitdirs = ListSubstract(dirs, curdirs)
    "join them together
    let gitpath = join(gitdirs, "/")
    "return the path relative to the .git directory parent
    echo gitpath
    return gitpath
endfunction

function! RelativeGitPathTest()
    RelativeGitPath("/cygdrive/c/Users/tim.zwart/Downloads/INGEX_core/pom.xml")
endfunction

command! RelativeGitPathTest call RelativeGitPath("/cygdrive/c/Users/tim.zwart/Downloads/INGEX_core/pom.xml")

command! RelativeGitPathTest2 call RelativeGitPath("/home/Tim.Zwart/vimrc/.vimrc")

function! GitLog()
    "old dir
    let olddir = getcwd()
    let dirofcurfile = expand('%:p:h')
    let com0 = 'cd '.dirofcurfile
    execute com0
    let curfile = expand('%:p')
    echo curfile
    let path = RelativeGitPath(curfile)
    let com = 'read !git log -p '.path
    echo com
    tabe
    execute com
    let com1 = 'cd '.olddir
    execute com1
endfunction

command! GitLog call GitLog()

"prints a dependency tree for maven project
function! MavenTree()
    let com = 'read !mvn dependency:tree -Dverbose'
    echo com
    tabe
    execute com
endfunction

command! MavenTree call MavenTree()

"prints the effective pom
function! MavenEffectivePom()
    let com = 'read !mvn help:effective-pom'
    echo com
    tabe
    execute com
endfunction

command! MavenEffectivePom call MavenEffectivePom()

let g:findbuffernumber = 0

function! OpenFindBuffer()
    let g:findbuffernumber = g:findbuffernumber + 1
    let bufname = "Perg_output".g:findbuffernumber
    let com = "new ".bufname
    execute com
endfunction

"finds a file"
function! Find(filename)
    let com = 'read !find -iname "'.a:filename.'"'
    echo com
    call OpenFindBuffer()
    execute com
    set ro
endfunction

command! -nargs=1 Find call Find(<q-args>)

" copypaste from stackoverflow, thanks mr statox
" supposed to save also unwritten stuff only does not really work. seems to
" have permissions problem
function! MkSession(...)
    " Handle the argument
    if empty(a:000)
        let filename = "Session.vim"
    else
        let filename = fnameescape(a:1)
    endif

    " Create the session file according to the argument passed
    execute 'mksession! ' . filename

    " The list containing the lines on the unnmaed buffers
    let noname_buffers = []

    " Get the lines of all the unnamed buffers in the list
    execute "silent! bufdo \| if expand('%')=='' \| call add(noname_buffers, getline(1, '$')) \| endif"

    " For each set of lines
    " Add into the session file a line creating an empty buffer
    " and a line adding its content
    for lines in noname_buffers
        call system('echo "enew" >> '.filename)
        call system('echo "call append(0, [\"'. join(lines, '\",\"') .'\"])" >>'. filename)
    endfor

endfunction

command! -nargs=? Mksession call MkSession(<f-args>)

function! NextFileInPergSearch()
    /^\(\(^  \)\@!.\)*$
endfunction

command! PergSearchNextFile call NextFileInPergSearch()

" Follow symlinks when opening a file {{{
" NOTE: this happens with directory symlinks anyway (due to Vim's chdir/getcwd
" magic when getting filenames).
" Sources:
" - https://github.com/tpope/vim-fugitive/issues/147#issuecomment-7572351
" - http://www.reddit.com/r/vim/comments/yhsn6/is_it_possible_to_work_around_the_symlink_bug/c5w91qw
function! MyFollowSymlink(...)
  if exists('w:no_resolve_symlink') && w:no_resolve_symlink
    return
  endif
  let fname = a:0 ? a:1 : expand('%')
  if fname =~ '^\w\+:/'
    " do not mess with 'fugitive://' etc
    return
  endif
  let fname = simplify(fname)

  let resolvedfile = resolve(fname)
  if resolvedfile == fname
    return
  endif
  let resolvedfile = fnameescape(resolvedfile)
  echohl WarningMsg | echomsg 'Resolving symlink' fname '=>' resolvedfile | echohl None
  " exec 'noautocmd file ' . resolvedfile
  " XXX: problems with AutojumpLastPosition: line("'\"") is 1 always.
  exec 'file ' . resolvedfile
endfunction
command! FollowSymlink call MyFollowSymlink()
command! ToggleFollowSymlink let w:no_resolve_symlink = !get(w:, 'no_resolve_symlink', 0) | echo "w:no_resolve_symlink =>" w:no_resolve_symlink
au BufReadPost * call MyFollowSymlink(expand('<afile>'))

" SubstituteAccrossDirectory you use by selecting the replacement, then typing
" the search pattern
function! SubstituteAccrossDirectory()
    let vis = s:get_visual_selection()
    let selection = vis
    call inputsave()
    let searchpattern = input("Enter search pattern")
    call inputrestore()
    echo "\n"
    new
    let com = 'read !find . -name "*" -type f -exec sed -i -e "s/'.searchpattern.'/'.selection.'/g" -- {} +'
    echo com
    execute com
endfunction

vmap <C-r> :call SubstituteAccrossDirectory()<CR>

function! Is_there_a_sln_here(path)
    let foundsln = 0
python << EOF
import vim
import os
import re
foundsln = False
path = vim.eval("a:path")
for x in os.listdir(path):
    if x.startswith("Upload"):
        vim.command("echo \""+x+"\"")
    if re.search(".sln$", x):
        vim.command("echo \"match found\"")
        vim.command("let foundsln = \'"+x+"\'")
EOF
    echom "foundsln"
    echom foundsln
    return foundsln
endfunction

"returns solution path given a path
function! FindSolutionFile(path)
    "split up the path
    let dirs = split(a:path, "/")
    let curdirs = dirs
    "echo curdirs
    "1 is true, 0 is false
    let solpath_exists = 0
    let length = len(curdirs)
    "until we have the git path
    while solpath_exists is# 0 && length > 0
        "remove the last element of list
        let curdirs = Pop(curdirs, length - 1 )
        "echo curdirs
        let length = length - 1
        "join the path together
        let potentialsolpath = "/".join(curdirs, "/")
"        echo "potentialsolpath"
"        echo potentialsolpath
        "check whether the sln file exist
        let solpath_exists = Is_there_a_sln_here(potentialsolpath)
        echom "solpath_exists"
        echom solpath_exists
        if type(solpath_exists) == 1
            echom "solpath_exists is a string"
            let solpath = potentialsolpath."/".solpath_exists
            echo "solpath"
            echo solpath
            if solpath
                echo "solpath is also truthy"
            endif
        endif
        "repeat from step 2
    endwhile
    if type(solpath_exists) == 0
        throw 'solution path was not found'
    endif
    "return the path to the solution
    echo solpath
    return solpath
endfunction

function! GetWinpath()
    let curfile = expand('%:p')
    let solutionfile = FindSolutionFile(curfile)
    let winpathoutput = system('cygpath -w '.solutionfile)
    let winpath = substitute(winpathoutput, nr2char(10), ' ', "g")
    return winpath
endfunction

""Build VS Solution
function! VSBuild()
     let curfile = expand('%:p')
     let solutionfile = FindSolutionFile(curfile)
     let winpathoutput = system('cygpath -w '.solutionfile)
     let winpath = substitute(winpathoutput, nr2char(10), ' ', "g")
     echom winpath
     new
     let com = 'read !devenv "'.winpath.'" /Build'
     echom com
     "/c/Program\ Files\ (x86)/Microsoft\ Visual\ Studio/2017/Enterprise/Common7/IDE/devenv.exe /Build '
     ". solutionfile
     execute com
endfunction

command! VSBuild call VSBuild()

"Run visual studio solution
function! VSRun()
    let winpath = GetWinpath()
    let com = 'read !devenv "'.winpath.'" /Run'
    execute com
endfunction

command! VSRun call VSRun()

"get the difference between two xml files. unfortunately it gives some vague
"xml output
function! DiffXML(file1, file2)
    let file1 = a:file1
    let file2 = a:file2
    let com = 'read !~/Downloads/diffxml-0.96B/diffxml/diffxml.cmd '.file1.' '.file2
    new
    execute com
endfunction

command! -nargs=* DiffXML call DiffXML(<f-args>)

"i cannot ever remember this when i need it
command! SelectDirOfFile cd %:p:h


"no longer need to do enew and then read
function! Read(something)
    enew
    read something
endfunction

command! -nargs=1 Read call Read(<q-args>)
