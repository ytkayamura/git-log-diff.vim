let g:gitLogDiff = {}
let g:gitLogDiff.BUF_NAME_PREFIX = 'GitLogDiff:'
let g:gitLogDiff.LOG_BUF = g:gitLogDiff.BUF_NAME_PREFIX . 'Log'
let g:gitLogDiff.DIFF_NAME_STATUS_BUF = g:gitLogDiff.BUF_NAME_PREFIX . 'DiffOnlyName:'
let g:gitLogDiff.DIFF_BY_FILE_BUF = g:gitLogDiff.BUF_NAME_PREFIX . 'DiffByFile:'

command! -nargs=? -complete=dir GitLogDiff call git_log_diff#git_log_buffer#open(<f-args>)
command! GitLogDiffClose call git_log_diff#common#close_all_buffer()
nnoremap <leader>gl :execute 'GitLogDiff ' . expand('%:p:h')<CR>

