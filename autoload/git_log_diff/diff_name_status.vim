let s:resize_done = 0

function! git_log_diff#diff_name_status#open()
  " カレントディレクトリを保存して、移動
  let l:old_cwd = getcwd()
  execute 'cd ' . g:gitLogDiff.target_dir

  let commit = split(getline('.'), ' ')[0]
  
  " 前回と同じコミットの場合はスキップ
  if commit ==# g:gitLogDiff.last_commit
    execute 'cd ' . l:old_cwd
    return
  endif
  let g:gitLogDiff.last_commit = commit

  let current_win = win_getid()
  let existing_buf = 0
  let existing_win = 0

  " バッファを開く、または上書き準備
  call git_log_diff#common#FindOrCreateBuffer(g:gitLogDiff.DIFF_NAME_STATUS_BUF, commit, 'split')

  " バッファの内容を更新
  let l:git_diff_output = systemlist('git diff --name-status ' . git_log_diff#common#GetParentCommit(commit) . ' ' . commit)
  let l:filtered_output = []
  if exists('g:gitLogDiff.target_file')
    " ファイル指定の場合は、そのファイルを先頭に表示
    let l:relative_target_file = fnamemodify(g:gitLogDiff.target_file, ':.')
    " gitルートからの相対パスを取得
    let l:git_prefix = system('git rev-parse --show-prefix')
    let l:git_prefix = substitute(l:git_prefix, '\n\+$', '', '') " 改行を削除
    let l:relative_target_file = l:git_prefix . l:relative_target_file
    " パスの/をエスケープし、タブまたはスペースの後にファイル名が来るようにパターンを修正
    let l:escaped_target_file = escape(l:relative_target_file, '/')
    echo l:escaped_target_file
    let l:target_file_line = filter(copy(l:git_diff_output), 'v:val =~# "\\V\\s\\+" . l:escaped_target_file . "\\$"')
    call extend(l:filtered_output, l:target_file_line)
    let l:other_lines = filter(copy(l:git_diff_output), 'v:val !~# "\\V\\s\\+" . l:escaped_target_file . "\\$"')
    call extend(l:filtered_output, l:other_lines)
  else
    let l:filtered_output = l:git_diff_output
  endif
  call setline(1, l:filtered_output)

  set nolist
  set tabstop=6
  set cursorline
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
  " 最初のファイルのdiffを表示
  call git_log_diff#diff_by_file#open()


  call git_log_diff#mapping#setup_diff_name_status_buffer()
  
  call win_gotoid(current_win)

  if !s:resize_done
    call git_log_diff#common#ResizeBuffer(g:gitLogDiff.LOG_BUF, g:gitLogDiff.diff_win_resize)
    let s:resize_done = 1
  endif

  " 元のディレクトリに戻る
  execute 'cd ' . l:old_cwd
endfunction

