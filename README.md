# git-log-diff.vim

A Vim plugin for displaying git log diffs within Vim.

## Installation

To install this plugin, use your favorite Vim plugin manager. For example, using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'ytkayamura/git-log-diff.vim'
```

## Usage

Once installed, you can use the plugin to display git log diffs by running the following command in Vim:

```vim
:GitLogDiff
```

## Feature: Display Diff Results

- In the log buffer, select a commit and press `p` to display the result of `git diff --name-status` in a new buffer.
- In the name-status buffer, select a file and press `p` to display the diff of that file in a diff buffer.

## Keybinding Example

To bind the command to `<leader>gl`, add the following to your `.vimrc` or `init.vim`:

```vim
nnoremap <leader>gl :GitLogDiff<CR>
```

## To Do
- カーソルが動いたら必ず次のサブウィンドウの表示を変える
- 各ウィンドウを開いたら最初にカーソルがあたっている情報から次のサブウィンドウを開く
- ファイル指定ログ表示
- ２つの指定コミット間のDiff表示

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License.
