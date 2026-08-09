function! git_log_diff#git_log_buffer#open(target = '.')
  if isdirectory(a:target)
    let g:gitLogDiff.target_dir = fnamemodify(a:target, ':p:h')
    " ディレクトリ指定のときは前回のファイル指定を必ずクリアする
    let g:gitLogDiff.target_file = ''
  else
    let g:gitLogDiff.target_dir = fnamemodify(a:target, ':p:h')
    let g:gitLogDiff.target_file = fnamemodify(a:target, ':p')
  endif

  " プレビューのキャッシュをリセットして、開き直し時に必ず再描画させる
  let g:gitLogDiff.last_commit = ''
  let g:gitLogDiff.last_file = ''
  let g:gitLogDiff.last_diff_by_file_commit = ''
  call git_log_diff#diff_name_status#reset()

  " カレントディレクトリを保存して、移動
  let l:old_cwd = getcwd()
  execute 'cd ' . fnameescape(g:gitLogDiff.target_dir)

  " git ログを取得。systemlist のリスト形式を使うことでシェルを介さず、
  " cmd.exe ではシングルクォートが効かない問題やパス内の空白を回避する。
  " （リスト形式では % のエスケープも不要）
  let l:cmd = ['git', '-c', 'core.quotepath=false', 'log',
        \ '--date=format-local:%Y-%m-%d %H:%M',
        \ '--pretty=format:%h %cd %s %an %d']
  " ターゲットファイルが指定されている場合は、そのファイルのログのみ表示
  if !empty(g:gitLogDiff.target_file)
    call extend(l:cmd, ['--', g:gitLogDiff.target_file])
  endif
  let l:output = systemlist(l:cmd)

  " git ログが取得できない（git リポジトリでない等）場合は
  " バッファを作らずディレクトリ移動フロートを開く
  if v:shell_error != 0
    execute 'cd ' . fnameescape(l:old_cwd)
    echohl WarningMsg | echo 'git log を取得できません: ' . g:gitLogDiff.target_dir | echohl None
    call git_log_diff#dir_changer#open()
    return
  endif

  enew
  setlocal buftype=nofile
  execute 'file ' . g:gitLogDiff.LOG_BUF

  setlocal modifiable
  call setline(1, l:output)
  setlocal nomodifiable
  set cursorline
  set nolist
  
  call git_log_diff#mapping#setup_log_buffer()

  " 元のディレクトリに戻る
  execute 'cd ' . fnameescape(l:old_cwd)
endfunction

