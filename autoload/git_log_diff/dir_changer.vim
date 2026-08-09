" カレントディレクトリ変更用のフロートウィンドウ
"   j / k : カーソル上下
"   h     : 親ディレクトリへ
"   l     : カーソル上のディレクトリへ入る
"   <CR>  : 表示中のディレクトリをカレントディレクトリに変更
"   q/Esc : 閉じる

let s:state = {}
let s:HEADER_LINES = 2

function! git_log_diff#dir_changer#open() abort
  " 親ディレクトリを開き、カレントディレクトリにカーソルを当てる
  let l:cur = fnamemodify(getcwd(), ':p:h')
  let l:parent = fnamemodify(l:cur, ':h')
  let s:state.cwd = (l:parent ==# l:cur) ? l:cur : l:parent
  let s:state.entries = []

  let s:state.buf = nvim_create_buf(v:false, v:true)

  let l:width = float2nr(min([&columns - 4, 70]))
  let l:height = float2nr(min([&lines - 4, 22]))
  let l:opts = {
        \ 'relative': 'editor',
        \ 'width': l:width,
        \ 'height': l:height,
        \ 'col': (&columns - l:width) / 2,
        \ 'row': (&lines - l:height) / 2,
        \ 'style': 'minimal',
        \ 'border': 'rounded',
        \ 'title': ' Change Directory ',
        \ }
  let s:state.win = nvim_open_win(s:state.buf, v:true, l:opts)
  call nvim_win_set_option(s:state.win, 'cursorline', v:true)

  call s:setup_keymaps()
  call s:render()

  " カレントディレクトリのエントリにカーソルを移動
  call s:focus(fnamemodify(l:cur, ':t'))
endfunction

" 指定した名前のディレクトリエントリにカーソルを当てる
function! s:focus(name) abort
  let l:idx = index(s:state.entries, a:name . '/')
  if l:idx >= 0
    call s:place_cursor(s:first_line() + l:idx)
  endif
endfunction

function! s:setup_keymaps() abort
  let l:buf = s:state.buf
  let l:o = {'silent': v:true, 'nowait': v:true, 'noremap': v:true}
  call nvim_buf_set_keymap(l:buf, 'n', 'j', '<cmd>call git_log_diff#dir_changer#move(1)<CR>', l:o)
  call nvim_buf_set_keymap(l:buf, 'n', 'k', '<cmd>call git_log_diff#dir_changer#move(-1)<CR>', l:o)
  call nvim_buf_set_keymap(l:buf, 'n', 'h', '<cmd>call git_log_diff#dir_changer#parent()<CR>', l:o)
  call nvim_buf_set_keymap(l:buf, 'n', 'l', '<cmd>call git_log_diff#dir_changer#enter()<CR>', l:o)
  call nvim_buf_set_keymap(l:buf, 'n', '<CR>', '<cmd>call git_log_diff#dir_changer#confirm()<CR>', l:o)
  call nvim_buf_set_keymap(l:buf, 'n', 'q', '<cmd>call git_log_diff#dir_changer#close()<CR>', l:o)
  call nvim_buf_set_keymap(l:buf, 'n', '<Esc>', '<cmd>call git_log_diff#dir_changer#close()<CR>', l:o)
endfunction

function! s:render() abort
  let l:dir = s:state.cwd
  let l:entries = []
  let l:names = readdir(l:dir)
  if type(l:names) == v:t_list
    for l:name in sort(l:names)
      if isdirectory(l:dir . '/' . l:name)
        call add(l:entries, l:name . '/')
      endif
    endfor
  endif
  let s:state.entries = l:entries

  let l:lines = [l:dir, repeat('─', nvim_win_get_width(s:state.win) - 2)] + l:entries
  if empty(l:entries)
    call add(l:lines, '(サブディレクトリなし)')
  endif

  call nvim_buf_set_option(s:state.buf, 'modifiable', v:true)
  call nvim_buf_set_lines(s:state.buf, 0, -1, v:false, l:lines)
  call nvim_buf_set_option(s:state.buf, 'modifiable', v:false)

  call s:place_cursor(s:HEADER_LINES + 1)
endfunction

function! s:first_line() abort
  return s:HEADER_LINES + 1
endfunction

function! s:last_line() abort
  return s:HEADER_LINES + max([len(s:state.entries), 1])
endfunction

function! s:place_cursor(line) abort
  let l:line = max([s:first_line(), min([a:line, s:last_line()])])
  call nvim_win_set_cursor(s:state.win, [l:line, 0])
endfunction

function! s:selected() abort
  let l:idx = line('.') - s:first_line()
  if l:idx < 0 || l:idx >= len(s:state.entries)
    return ''
  endif
  return s:state.entries[l:idx]
endfunction

function! git_log_diff#dir_changer#move(delta) abort
  call s:place_cursor(line('.') + a:delta)
endfunction

function! git_log_diff#dir_changer#parent() abort
  let l:parent = fnamemodify(s:state.cwd, ':h')
  if l:parent ==# s:state.cwd
    return
  endif
  " 元居たディレクトリ名を覚えておき、親に移動後カーソルを当てる
  let l:from = fnamemodify(s:state.cwd, ':t')
  let s:state.cwd = l:parent
  call s:render()
  call s:focus(l:from)
endfunction

function! git_log_diff#dir_changer#enter() abort
  let l:name = s:selected()
  if empty(l:name)
    return
  endif
  let s:state.cwd = fnamemodify(s:state.cwd . '/' . l:name, ':p:h')
  call s:render()
endfunction

function! git_log_diff#dir_changer#confirm() abort
  " カーソルの当たっているディレクトリをカレントにする
  " （サブディレクトリが無い場合は表示中のディレクトリを使う）
  let l:name = s:selected()
  if !empty(l:name)
    let l:dir = fnamemodify(s:state.cwd . '/' . l:name, ':p:h')
  else
    let l:dir = s:state.cwd
  endif
  call git_log_diff#dir_changer#close()
  execute 'cd ' . fnameescape(l:dir)
  " 既存の GitLogDiff バッファを閉じて、新しいディレクトリで開き直す
  call git_log_diff#common#close_all_buffer()
  " ウィンドウが複数あるときだけ集約する（1つだけだと
  " :only が "Already one window" を表示して hit-enter 待ちになるため）
  if winnr('$') > 1
    only
  endif
  call git_log_diff#git_log_buffer#open(l:dir)
  echo 'cwd: ' . l:dir
endfunction

function! git_log_diff#dir_changer#close() abort
  if has_key(s:state, 'win') && nvim_win_is_valid(s:state.win)
    call nvim_win_close(s:state.win, v:true)
  endif
endfunction
