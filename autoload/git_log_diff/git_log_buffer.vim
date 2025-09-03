function! git_log_diff#git_log_buffer#open(target = '.')
  if isdirectory(a:target)
    let g:gitLogDiff.target_dir = fnamemodify(a:target, ':p:h')
  else
    let g:gitLogDiff.target_dir = fnamemodify(a:target, ':p:h')
    let g:gitLogDiff.target_file = fnamemodify(a:target, ':p')
  endif

  " カレントディレクトリを保存して、移動
  let l:old_cwd = getcwd()
  execute 'cd ' . g:gitLogDiff.target_dir

  enew
  setlocal buftype=nofile
  execute 'file ' . g:gitLogDiff.LOG_BUF
  
  " ターゲットファイルが指定されている場合は、そのファイルのログのみ表示
  if !empty(g:gitLogDiff.target_file)
    silent execute "read !git -c core.quotepath=false log --date=format-local:'\\%Y-\\%m-\\%d \\%H:\\%M' --pretty=format:'\\%h \\%cd \\%s \\%an \\%d' -- " . g:gitLogDiff.target_file
  else
    silent execute "read !git -c core.quotepath=false log --date=format-local:'\\%Y-\\%m-\\%d \\%H:\\%M' --pretty=format:'\\%h \\%cd \\%s \\%an \\%d'"
  endif

  1delete
  setlocal nomodifiable
  set cursorline
  set nolist
  
  call git_log_diff#mapping#setup_log_buffer()

  " 元のディレクトリに戻る
  execute 'cd ' . l:old_cwd
endfunction

