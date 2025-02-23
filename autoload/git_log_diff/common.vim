function! git_log_diff#common#ActivateBuffer(buffer_name)
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

function! git_log_diff#common#FindOrCreateBuffer(buffer_name, commit, split_cmd)
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

function! git_log_diff#common#ResizeBuffer(buffer_name, size)
  " バッファを探す
  for buf in getbufinfo({'bufloaded': 1})
    if buf.name =~  escape(a:buffer_name, '\')
      " そのバッファを表示しているウィンドウを探す
      let l:win_id = bufwinid(buf.bufnr)
      if l:win_id != -1
        " ウィンドウが見つかった場合はサイズを変更
        call win_gotoid(l:win_id)
        execute 'resize ' . a:size
        return
    endif
  endfor
  echo "ログバッファが見つかりません: " . a:buffer_name . "*"
endfunction

function! git_log_diff#common#GetParentCommit(commit)
  " Determine the parent commit
  let parent = a:commit . '^'
  let parent_exists = system('git rev-parse ' . shellescape(parent) . ' 2>/dev/null')

  if v:shell_error
      " If commit^ does not exist, use the empty tree hash
      let parent = '4b825dc642cb6eb9a060e54bf8d69288fbee4904'
  endif

  return parent
endfunction

function! git_log_diff#common#close_all_buffer()
  for buf in getbufinfo()
    if buf.name =~# g:gitLogDiff.BUF_NAME_PREFIX
      execute 'bwipeout! ' . buf.bufnr
    endif
  endfor
endfunction

function! git_log_diff#common#FindGitRoot(dir)
    let l:git_dir = a:dir
    
    while l:git_dir != '/'
        if isdirectory(l:git_dir . '/.git')
            return l:git_dir
        endif
        let l:git_dir = fnamemodify(l:git_dir, ':h')
    endwhile
    
    return ''
endfunction


function! git_log_diff#common#OnCursorMovedChangePreview()
  let bufname = bufname('%')
  if bufname =~# g:gitLogDiff.LOG_BUF
      call git_log_diff#diff_name_status#open()
  elseif bufname =~# g:gitLogDiff.DIFF_NAME_STATUS_BUF
      call git_log_diff#diff_by_file#open()
  endif
endfunction

