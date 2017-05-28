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
