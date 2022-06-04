# Apart.vim

*A simple auto-bracket/quote plugin for Vim.*

This plugin is designed to work for all file types, but offers additional
functionality for the [S-expression](https://en.wikipedia.org/wiki/S-expression)
based languages.


## Installation

> **Note** Apart only works on Vim 8.2+ with Vim9script, so it **won't**
> work on Neovim.

> **Warning** This plugin is still a work-in-progress.  Until it reaches v1.0,
> expect backwards incompatible changes.

Installation of Apart can be performed by using your preferred plugin management
solution.  If you don't have a Vim package manager I recommend using Vim
8 packages by running the following 2 commands in your shell.

```sh
git clone https://github.com/axvr/apart.vim ~/.vim/pack/plugins/start/apart
vim +'helptags ~/.vim/pack/plugins/start/apart/doc/' +q
```


## Usage

After installation Apart.vim will instantly start working.  It comes with some
decent defaults for many common languages.

To learn about all the configuration options available run the following in Vim:

```vim
:help apart.txt
```


## Legal

*No Rights Reserved.*

All source code, documentation and associated files packaged with apart.vim are
dedicated to the public domain.  A full copy of the [CC0][] (Creative Commons
Zero 1.0 Universal) public domain dedication should have been provided with this
extension in the `COPYING` file.

The author is not aware of any patent claims which may affect the use,
modification or distribution of this software.


[CC0]: https://creativecommons.org/publicdomain/zero/1.0/
