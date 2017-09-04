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
    :echo com0
    let output = system(com0)
    let winpath = substitute(output, "\n", "", "")
    :echo winpath
    let com = '!`netbeans "'.winpath.'":'.curline.'`'
    :echo com
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
        let filename = @0
    else
        let filename = linetext
    endif
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

"opens a tab with results from a grep for the word under the cursor
function! GrepWord()
    let var = expand("<cword>")
    tabe
    let com = 'read !grep -r "'.var.'"'
    echo com
    execute com
endfunction

"opens a tab with results from a perg.py for the word under the cursor
command! GrepWord call GrepWord()

function! PergWord()
    let var = expand("<cword>")
    tabe
    let com = 'read !perg.py . '.var
    echo com
    execute com
endfunction

command! PergWord call PergWord()

function! Perg(searchterm)
    tabe
    let com = 'read !perg.py . '.a:searchterm
    echo com
    execute com
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

"finds a file"
function! Find(filename)
    let com = 'read !find -name "'.a:filename.'"'
    echo com
    tabe
    execute com
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
