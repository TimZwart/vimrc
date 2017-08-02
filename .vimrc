set expandtab

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

function! Firefox()
       let vis = s:get_visual_selection()
       let visual = substitute(vis, "#", '\\\\#', "")
       let com = "!firefox " . visual
       execute com
endfunction

vmap <C-f> :call Firefox()<CR>

set nocompatible
filetype plugin indent on

set tabstop=4
set shiftwidth=4
set expandtab

let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

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

function! OpenFile()
    let curline = line(".")
    normal 0yt:
    let var = @0
    execute "tabe " . var
endfunction

command! OpenFile call OpenFile()

function! GrepWord()
    let var = expand("<cword>")
    tabe
    let com = 'read !grep -r "'.var.'"'
    echo com
    execute com
endfunction

command! GrepWord call GrepWord()

" copypaste from stackoverflow, thanks mr statox
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
