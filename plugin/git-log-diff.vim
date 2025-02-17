const s:BUF_NAME_PREFIX = 'GitLogDiff:'
const s:LOG_BUF = s:BUF_NAME_PREFIX . 'Log'
const s:DIFF_NAME_STATUS_BUF = s:BUF_NAME_PREFIX . 'DiffOnlyName:'
const s:DIFF_BY_FILE_BUF = s:BUF_NAME_PREFIX . 'DiffByFile:'

function! s:ActivateBuffer(buffer_name)
  " バッファを探す
  for buf in getbufinfo({'bufloaded': 1})
    if buf.name =~  escape(a:buffer_name, '\')
      " そのバッファを表示しているウィンドウを探す
      let l:win_id = bufwinid(buf.bufnr)
      if l:win_id != -1
        " ウィンドウが見つかった場合はそこにカーソルを移動
        call win_gotoid(l:win_id)
        return
      else
        " ウィンドウが見つからない場合は新しいバッファを開く
        execute 'buffer' buf.bufnr
        return
      endif
    endif
  endfor
  echo "ログバッファが見つかりません: " . a:buffer_name . "*"
endfunction

function! s:FindOrCreateBuffer(buffer_name, commit, split_cmd)
  let existing_buf = 0
  let existing_win = 0

  " バッファと対応するウィンドウを探す
  for buf in getbufinfo()
    if buf.name =~# a:buffer_name
      let existing_buf = buf.bufnr
      " このバッファを表示しているウィンドウを探す 
      for win in buf.windows
        let existing_win = win
        break
      endfor
      break
    endif
  endfor

  if existing_buf
    " 既存のバッファが見つかった場合
    if existing_win
      " 既にウィンドウがある場合はそれを使用
      call win_gotoid(existing_win)
    else
      " ウィンドウがない場合は新しく開く
      execute a:split_cmd
      execute 'buffer ' . existing_buf
    endif
  else
    " 新しいバッファを作成
    execute a:split_cmd
    enew
    setlocal buftype=nofile
  endif
  " バッファ名を設定
  execute 'file ' . a:buffer_name . a:commit
  setlocal modifiable
  %delete _
endfunction

function! GetParentCommit(commit)
  " Determine the parent commit
  let parent = a:commit . '^'
  let parent_exists = system('git rev-parse ' . shellescape(parent) . ' 2>/dev/null')

  if v:shell_error
      " If commit^ does not exist, use the empty tree hash
      let parent = '4b825dc642cb6eb9a060e54bf8d69288fbee4904'
  endif

  return parent
endfunction

function! s:git_log_buffer(target_dir = '.')
  let s:target_dir = a:target_dir
  " カレントディレクトリを保存して、移動
  let l:old_cwd = getcwd()
  execute 'cd ' . s:target_dir

  enew
  setlocal buftype=nofile
  execute 'file ' . s:LOG_BUF
  "silent execute "read !git log --oneline"
  silent execute "read !git log --date=format-local:'\\%Y-\\%m-\\%d \\%H:\\%M' --pretty=format:'\\%C(auto)\\%h \\%C(green)\\%cd \\%C(auto)\\%s \\%C(cyan)\\%an \\%C(auto)\\%d'"
  1delete
  setlocal nomodifiable
  
  nnoremap <buffer> <silent> p :call <SID>diff_name_status()<CR>
  nnoremap <buffer> <silent> q :call <SID>close_all_buffer()<CR>
  nnoremap <buffer> <silent> <C-n> j:call <SID>diff_name_status()<CR>
  nnoremap <buffer> <silent> <C-p> k:call <SID>diff_name_status()<CR>
  execute 'nnoremap <buffer> <silent> <C-j> :call <SID>ActivateBuffer("' . s:LOG_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-h> :call <SID>ActivateBuffer("' . s:DIFF_NAME_STATUS_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-k> :call <SID>ActivateBuffer("' . s:DIFF_NAME_STATUS_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-l> :call <SID>ActivateBuffer("' . s:DIFF_BY_FILE_BUF . '")<CR>'


  " 元のディレクトリに戻る
  execute 'cd ' . l:old_cwd
endfunction

function! s:diff_name_status()
  " カレントディレクトリを保存して、移動
  let l:old_cwd = getcwd()
  execute 'cd ' . s:target_dir

  let commit = split(getline('.'), ' ')[0]
  let current_win = win_getid()
  let existing_buf = 0
  let existing_win = 0

  " バッファを開く、または上書き準備
  call s:FindOrCreateBuffer(s:DIFF_NAME_STATUS_BUF, commit, 'split')

  " バッファの内容を更新
  execute 'silent read !git diff --name-status ' . GetParentCommit(commit) . ' ' . commit
  execute 'set nolist'
  execute 'set tabstop=6'
  1delete
  " シンタックスハイライトの設定
  syntax match deleted "^D.*" 
  syntax match modified "^M.*"
  syntax match rename "^R.*"
  syntax match added "^A.*"
  highlight deleted ctermfg=red guifg=red
  highlight modified ctermfg=green guifg=green
  highlight rename ctermfg=magenta guifg=magenta
  highlight added ctermfg=cyan guifg=cyan
  setlocal nomodifiable

  execute 'nnoremap <buffer> <silent> <C-j> :call <SID>ActivateBuffer("' . s:LOG_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-h> :call <SID>ActivateBuffer("' . s:DIFF_NAME_STATUS_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-k> :call <SID>ActivateBuffer("' . s:DIFF_NAME_STATUS_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-l> :call <SID>ActivateBuffer("' . s:DIFF_BY_FILE_BUF . '")<CR>'
  nnoremap <buffer> <silent> p :call <SID>diff_by_file()<CR>
  nnoremap <buffer> <silent> q :call <SID>close_all_buffer()<CR>
  nnoremap <buffer> <silent> <C-n> j:call <SID>diff_by_file()<CR>
  nnoremap <buffer> <silent> <C-p> k:call <SID>diff_by_file()<CR>
  
  call win_gotoid(current_win)

  " 元のディレクトリに戻る
  execute 'cd ' . l:old_cwd
endfunction

function! FindGitRoot(dir)
    let l:git_dir = a:dir
    
    while l:git_dir != '/'
        if isdirectory(l:git_dir . '/.git')
            return l:git_dir
        endif
        let l:git_dir = fnamemodify(l:git_dir, ':h')
    endwhile
    
    return ''
endfunction

function! s:diff_by_file()
  " カレントディレクトリを保存して、移動
  let l:old_cwd = getcwd()
  execute 'cd ' . FindGitRoot(s:target_dir)

  let bufname = bufname('%')
  let commit = split(bufname, ':')[2]
  let line = getline('.')
  let file_path = substitute(line, '\v^(\S+\s+)', '', '')
  let current_win = win_getid()

  " バッファを開く、または上書き準備
  set splitright
  call s:FindOrCreateBuffer(s:DIFF_BY_FILE_BUF, commit, 'vsplit')

  " バッファの内容を更新
  execute 'silent read !git diff ' . GetParentCommit(commit) . ' ' . commit . ' -- ' . shellescape(file_path)
  1delete
  " シンタックスハイライトの設定
  syntax match diffRemoved "^-.*" 
  syntax match diffAdded "^+.*"
  highlight diffRemoved ctermfg=red guifg=red
  highlight diffAdded ctermfg=cyan guifg=cyan

  setlocal nomodifiable

  nnoremap <buffer> <silent> q :call <SID>close_all_buffer()<CR>
  execute 'nnoremap <buffer> <silent> <C-j> :call <SID>ActivateBuffer("' . s:LOG_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-h> :call <SID>ActivateBuffer("' . s:DIFF_NAME_STATUS_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-k> :call <SID>ActivateBuffer("' . s:DIFF_NAME_STATUS_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-l> :call <SID>ActivateBuffer("' . s:DIFF_BY_FILE_BUF . '")<CR>'

  call win_gotoid(current_win)

  " 元のディレクトリに戻る
  execute 'cd ' . l:old_cwd
endfunction

function! s:close_all_buffer()
  for buf in getbufinfo()
    if buf.name =~# s:BUF_NAME_PREFIX
      execute 'bwipeout! ' . buf.bufnr
    endif
  endfor
endfunction

command! -nargs=? -complete=dir GitLogDiff call s:git_log_buffer(<f-args>)
command! GitLogDiffClose call s:close_all_buffer()
nnoremap <leader>gl :execute 'GitLogDiff ' . expand('%:p:h')<CR>

