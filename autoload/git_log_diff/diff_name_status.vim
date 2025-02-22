function! git_log_diff#diff_name_status#open()
  " カレントディレクトリを保存して、移動
  let l:old_cwd = getcwd()
  execute 'cd ' . g:gitLogDiff.target_dir

  let commit = split(getline('.'), ' ')[0]
  let current_win = win_getid()
  let existing_buf = 0
  let existing_win = 0

  " バッファを開く、または上書き準備
  call git_log_diff#common#FindOrCreateBuffer(g:gitLogDiff.DIFF_NAME_STATUS_BUF, commit, 'split')

  " バッファの内容を更新
  execute 'silent read !git diff --name-status ' . git_log_diff#common#GetParentCommit(commit) . ' ' . commit
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
  set cursorline
  " 最初のファイルのdiffを表示
  call git_log_diff#diff_by_file#open()


  call git_log_diff#mapping#setup_diff_name_status_buffer()
  
  call win_gotoid(current_win)

  " 元のディレクトリに戻る
  execute 'cd ' . l:old_cwd
endfunction

