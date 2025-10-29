function! git_log_diff#diff_by_file#open()
  " カレントディレクトリを保存して、移動
  let l:old_cwd = getcwd()
  execute 'cd ' . git_log_diff#common#FindGitRoot(g:gitLogDiff.target_dir)

  let bufname = bufname('%')
  let commit = split(bufname, ':')[2]
  let line = getline('.')

  " 改名の場合は R100 old_path new_path のような形式
  " それ以外は M/A/D file_path のような形式
  let status = matchstr(line, '^\S\+')
  if status =~# '^R'
    " 改名の場合: "R100 old_path new_path" から new_path を取得
    let parts = split(line, '\t')
    if len(parts) >= 3
      let old_file_path = parts[1]
      let file_path = parts[2]
    else
      " フォールバック: スペース区切りで取得
      let parts = split(line)
      if len(parts) >= 3
        let old_file_path = parts[1]
        let file_path = parts[2]
      else
        let file_path = substitute(line, '\v^(\S+\s+)', '', '')
        let old_file_path = ''
      endif
    endif
  else
    let file_path = substitute(line, '\v^(\S+\s+)', '', '')
    let old_file_path = ''
  endif

  let old_commit = g:gitLogDiff.last_diff_by_file_commit
  
  " 前回と同じコミット・ファイルの場合はスキップ
  if file_path ==# g:gitLogDiff.last_file && old_commit ==# g:gitLogDiff.last_commit
    execute 'cd ' . l:old_cwd
    return
  endif
  let g:gitLogDiff.last_file = file_path
  
  let current_win = win_getid()

  " バッファを開く、または上書き準備
  set splitright
  call git_log_diff#common#FindOrCreateBuffer(g:gitLogDiff.DIFF_BY_FILE_BUF , commit, 'vsplit')

  " バッファの内容を更新
  " 改名の場合は旧ファイル名も指定して差分を取得
  if old_file_path !=# ''
    execute 'silent read !git -c core.quotepath=false diff -M ' . git_log_diff#common#GetParentCommit(commit) . ' ' . commit . ' -- ' . shellescape(old_file_path) . ' ' . shellescape(file_path)
  else
    execute 'silent read !git -c core.quotepath=false diff ' . git_log_diff#common#GetParentCommit(commit) . ' ' . commit . ' -- ' . shellescape(file_path)
  endif
  let g:gitLogDiff.last_diff_by_file_commit = commit
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

