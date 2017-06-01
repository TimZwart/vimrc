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
    system('netbeans open '+curfile+':'+curline)

command! Netbeans call Netbeans()
