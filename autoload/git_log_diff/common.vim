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
    endif
  endfor
  echo "ログバッファが見つかりません: " . a:buffer_name . "*"
endfunction

function! git_log_diff#common#GetParentCommit(commit)
  " Resolve commit^ to an actual hash.
  " On Windows cmd.exe '^' is the escape character, so passing a raw 'commit^'
  " into a later shell command would be mangled. Resolving it here keeps every
  " downstream argument a plain hex hash. Using the list form of systemlist()
  " also avoids any shell quoting (no '2>/dev/null', which is not portable).
  let l:out = systemlist(['git', 'rev-parse', '--verify', '--quiet', a:commit . '^'])

  if v:shell_error != 0 || empty(l:out)
      " If commit^ does not exist (root commit), use the empty tree hash
      return '4b825dc642cb6eb9a060e54bf8d69288fbee4904'
  endif

  return l:out[0]
endfunction

function! git_log_diff#common#close_all_buffer()
  for buf in getbufinfo()
    if buf.name =~# g:gitLogDiff.BUF_NAME_PREFIX
      execute 'bwipeout! ' . buf.bufnr
    endif
  endfor
endfunction

function! git_log_diff#common#FindGitRoot(dir)
    " Walk up until we find a .git, stopping when the parent no longer changes
    " (the filesystem root). The old 'while != "/"' test never matched on
    " Windows roots such as 'C:/', causing an infinite loop.
    let l:git_dir = fnamemodify(a:dir, ':p')
    let l:git_dir = substitute(l:git_dir, '[\\/]\+$', '', '')

    while 1
        " .git is a directory in a normal repo, a file in a worktree/submodule
        if isdirectory(l:git_dir . '/.git') || filereadable(l:git_dir . '/.git')
            return l:git_dir
        endif
        let l:parent = fnamemodify(l:git_dir, ':h')
        if l:parent ==# l:git_dir
            break
        endif
        let l:git_dir = l:parent
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

