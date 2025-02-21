function! git_log_diff#mapping#setup_log_buffer() abort
  nnoremap <buffer> <silent> p :call git_log_diff#diff_name_status#open()<CR>
  nnoremap <buffer> <silent> q :call git_log_diff#common#close_all_buffer()<CR>
  nnoremap <buffer> <silent> <C-n> j:call git_log_diff#diff_name_status#open()<CR>
  nnoremap <buffer> <silent> <C-p> k:call git_log_diff#diff_name_status#open()<CR>
  execute 'nnoremap <buffer> <silent> <C-j> :call git_log_diff#common#ActivateBuffer("' . g:gitLogDiff.LOG_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-h> :call git_log_diff#common#ActivateBuffer("' . g:gitLogDiff.DIFF_NAME_STATUS_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-k> :call git_log_diff#common#ActivateBuffer("' . g:gitLogDiff.DIFF_NAME_STATUS_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-l> :call git_log_diff#common#ActivateBuffer("' . g:gitLogDiff.DIFF_BY_FILE_BUF . '")<CR>'
endfunction

function! git_log_diff#mapping#setup_diff_name_status_buffer() abort
  nnoremap <buffer> <silent> p :call git_log_diff#diff_by_file#open()<CR>
  nnoremap <buffer> <silent> q :call git_log_diff#common#close_all_buffer()<CR>
  nnoremap <buffer> <silent> <C-n> j:call git_log_diff#diff_by_file#open()<CR>
  nnoremap <buffer> <silent> <C-p> k:call git_log_diff#diff_by_file#open()<CR>
  execute 'nnoremap <buffer> <silent> <C-j> :call git_log_diff#common#ActivateBuffer("' . g:gitLogDiff.LOG_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-h> :call git_log_diff#common#ActivateBuffer("' . g:gitLogDiff.DIFF_NAME_STATUS_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-k> :call git_log_diff#common#ActivateBuffer("' . g:gitLogDiff.DIFF_NAME_STATUS_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-l> :call git_log_diff#common#ActivateBuffer("' . g:gitLogDiff.DIFF_BY_FILE_BUF . '")<CR>'
endfunction

function! git_log_diff#mapping#setup_diff_by_file_buffer() abort
  nnoremap <buffer> <silent> q :call git_log_diff#common#close_all_buffer()<CR>
  execute 'nnoremap <buffer> <silent> <C-j> :call git_log_diff#common#ActivateBuffer("' . g:gitLogDiff.LOG_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-h> :call git_log_diff#common#ActivateBuffer("' . g:gitLogDiff.DIFF_NAME_STATUS_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-k> :call git_log_diff#common#ActivateBuffer("' . g:gitLogDiff.DIFF_NAME_STATUS_BUF . '")<CR>'
  execute 'nnoremap <buffer> <silent> <C-l> :call git_log_diff#common#ActivateBuffer("' . g:gitLogDiff.DIFF_BY_FILE_BUF . '")<CR>'
endfunction

