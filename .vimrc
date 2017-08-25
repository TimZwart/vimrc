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

"deploys ING SSO project, work related
function! DeployINGSSO()
	let curdir = getcwd()
	cd /winhome/Downloads/ING_SSO
	echom 'running maven'
	let mvnresult = system('mvn clean install')
	if !v:shell_error 
		echom 'copying wars'
		silent !cp ./extranet-sso-saml/target/extranet-sso-saml.war ../jboss-eap-6.4/jboss-eap-6.4/standalone/deployments
		silent !cp ./extranet-sso-web/target/extranet-sso-web.war ../jboss-eap-6.4/jboss-eap-6.4/standalone/deployments
		silent !cp ./extranet-sso-trust/target/extranet-sso-trust.war ../jboss-eap-6.4/jboss-eap-6.4/standalone/deployments
	else	
		echom 'maven errors!'
		tabe ++ff=dos
		call append(0, mvnresult)
        :%s/\r/\r\n/g
	endif
	cd `=curdir`
endfunction

command! DeployINGSSO call DeployINGSSO()

"deploys AEM project work related
function! DeployAEM()
	let curdir = getcwd()
	cd /winhome/Downloads/INGEX_Core
	echom 'running maven'
	let mvnresult = system('mvn -Pdeploy_package_to_author_and_publisher_on_local clean install')
	if !v:shell_error 
		echom 'great success!'
	else	
		echom 'maven errors!'
		tabe ++ff=dos
		call append(0, mvnresult)
        :%s/\r/\r\n/g
	endif
	cd `=curdir`
endfunction

command! DeployAEM call DeployAEM()

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
    let curfile = expand("%:p")
    let com = 'read !git add '.curfile
    echo com
    tabe   
    execute com
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
    let com = 'read !git commit -m "'.a:comment.'"'
    echo com
    tabe
    "execute com
endfunction

command! -nargs=1 GitCommit call GitCommit(<q-args>)

"push the change
function! GitPush()
    !git push
endfunction

command! GitPush call GitPush()

function! Pop(l, i)
    let new_list = deepcopy(a:l)
    call remove(new_list, a:i)
    return new_list
endfunction

function! RelativeGitPath(path)
    "split up the path
    let dirs = split(path)
    "until we have the git path
    let curdirs = dirs
    let gitfound = false
    while !gitfound && len(curdirs) > 0
        "remove the last element of list
        let curdirs = Pop(curdirs, len(curdirs) )
        "add .git to the list
        let potentialgitdirs = add(curdirs, ['.git'])
        "join the path together
        let potentialgitpath = join(curdirs, "/")
        "check whether the .git exists
        if filereadable(potentialgitpath)
            gitfound = true
        endif
        "repeat from step 2
    endwhile
    "subtract all elements from the git path from the original list
    "join them together
    "return the path relative to the .git directory parent
endfunction

function! GitLog()
    let curfile = expand("%:p")
    RelativeGitPath(curfile)
    let com = 'read !git log '.curfile
    echo com
    tabe
    execute com
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
