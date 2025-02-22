let g:gitLogDiff = {}
let g:gitLogDiff.BUF_NAME_PREFIX = 'GitLogDiff:'
let g:gitLogDiff.LOG_BUF = g:gitLogDiff.BUF_NAME_PREFIX . 'Log'
let g:gitLogDiff.DIFF_NAME_STATUS_BUF = g:gitLogDiff.BUF_NAME_PREFIX . 'DiffOnlyName:'
let g:gitLogDiff.DIFF_BY_FILE_BUF = g:gitLogDiff.BUF_NAME_PREFIX . 'DiffByFile:'
let g:gitLogDiff.last_commit = ''
let g:gitLogDiff.last_file = ''
let g:gitLogDiff.last_diff_by_file_commit = ''
let g:gitLogDiff.target_file = ''

command! -nargs=? -complete=file GitLogDiff call git_log_diff#git_log_buffer#open(<f-args>)
command! GitLogDiffClose call git_log_diff#common#close_all_buffer()
nnoremap <leader>gl :execute 'GitLogDiff ' . expand('%:p:h')<CR>

" オートコマンドグループを作成
augroup GitLogDiffGroup
    autocmd!
    autocmd CursorMoved * call git_log_diff#common#OnCursorMovedChangePreview()
augroup END
