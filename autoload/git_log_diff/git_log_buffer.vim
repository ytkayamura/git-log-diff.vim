function! git_log_diff#git_log_buffer#open(target_dir = '.')
  let g:gitLogDiff.target_dir = a:target_dir
  " カレントディレクトリを保存して、移動
  let l:old_cwd = getcwd()
  execute 'cd ' . g:gitLogDiff.target_dir

  enew
  setlocal buftype=nofile
  execute 'file ' . g:gitLogDiff.LOG_BUF
  "silent execute "read !git log --oneline"
  silent execute "read !git log --date=format-local:'\\%Y-\\%m-\\%d \\%H:\\%M' --pretty=format:'\\%C(auto)\\%h \\%C(green)\\%cd \\%C(auto)\\%s \\%C(cyan)\\%an \\%C(auto)\\%d'"
  1delete
  setlocal nomodifiable
  
  call git_log_diff#mapping#setup_log_buffer()

  " 元のディレクトリに戻る
  execute 'cd ' . l:old_cwd
endfunction

