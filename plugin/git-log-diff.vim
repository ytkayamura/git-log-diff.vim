let g:gitLogDiff = {}
let g:gitLogDiff.BUF_NAME_PREFIX = 'GitLogDiff:'
let g:gitLogDiff.LOG_BUF = g:gitLogDiff.BUF_NAME_PREFIX . 'Log'
let g:gitLogDiff.DIFF_NAME_STATUS_BUF = g:gitLogDiff.BUF_NAME_PREFIX . 'DiffOnlyName:'
let g:gitLogDiff.DIFF_BY_FILE_BUF = g:gitLogDiff.BUF_NAME_PREFIX . 'DiffByFile:'
let g:gitLogDiff.last_commit = ''
let g:gitLogDiff.last_file = ''
let g:gitLogDiff.last_diff_by_file_commit = ''
let g:gitLogDiff.target_file = ''

command! -nargs=? -complete=file GitLogDiff call s:git_log(<f-args>)
command! GitLogDiffClose call git_log_diff#common#close_all_buffer()
nnoremap <leader>gl :execute 'GitLogDiff ' . expand('%:p:h')<CR>

" オートコマンドグループを作成
augroup GitLogDiffGroup
    autocmd!
    autocmd CursorMoved * call git_log_diff#common#OnCursorMovedChangePreview()
augroup END

function! s:git_log(...) abort
    " 引数が指定されている場合はそれを使用
    if a:0 > 0
        let l:target = a:1
    " カレントバッファがファイルの場合はそのパスを使用
    elseif filereadable(expand('%:p'))
        let l:target = expand('%:p')
    " それ以外の場合はカレントディレクトリを使用
    else
        let l:target = getcwd()
    endif

    call git_log_diff#git_log_buffer#open(l:target)
endfunction
