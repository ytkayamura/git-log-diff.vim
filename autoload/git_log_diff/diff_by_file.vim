function! git_log_diff#diff_by_file#open()
  " カレントディレクトリを保存して、移動
  let l:old_cwd = getcwd()
  execute 'cd ' . git_log_diff#common#FindGitRoot(g:gitLogDiff.target_dir)

  let bufname = bufname('%')
  let commit = split(bufname, ':')[2]
  let line = getline('.')
  let file_path = substitute(line, '\v^(\S+\s+)', '', '')
  let current_win = win_getid()

  " バッファを開く、または上書き準備
  set splitright
  call git_log_diff#common#FindOrCreateBuffer(g:gitLogDiff.DIFF_BY_FILE_BUF , commit, 'vsplit')

  " バッファの内容を更新
  execute 'silent read !git diff ' . git_log_diff#common#GetParentCommit(commit) . ' ' . commit . ' -- ' . shellescape(file_path)
  1delete
  " シンタックスハイライトの設定
  syntax match diffRemoved "^-.*" 
  syntax match diffAdded "^+.*"
  highlight diffRemoved ctermfg=red guifg=red
  highlight diffAdded ctermfg=cyan guifg=cyan

  setlocal nomodifiable

  call git_log_diff#mapping#setup_diff_by_file_buffer()

  call win_gotoid(current_win)

  " 元のディレクトリに戻る
  execute 'cd ' . l:old_cwd
endfunction

