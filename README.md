# fzf-opencommit

## Table of Contents

- [fzf-opencommit](#fzf-opencommit)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Installation](#installation)
    - [Download fzf-opencommit to your home directory](#download-fzf-opencommit-to-your-home-directory)
    - [Using key bindings](#using-key-bindings)
  - [Usage](#usage)
  - [License](#license)

## Overview

This is a shell plugin that allows you to execute [`opencommit`](https://github.com/di-sukharev/opencommit) commands using keyboard shortcuts utilizing [`junegunn/fzf`](https://github.com/junegunn/fzf), [`di-sukharev/opencommit`](https://github.com/di-sukharev/opencommit).

## Installation

### Download [fzf-opencommit](https://github.com/gumob/fzf-opencommit) to your home directory

```shell
wget -O ~/.fzfopencommit https://raw.githubusercontent.com/gumob/fzf-opencommit/main/fzf-opencommit.sh
```

### Using key bindings

Source `fzf` and `fzf-opencommit` in your run command shell.
By default, no key bindings are set. If you want to set the key binding to `Ctrl+O`, please configure it as follows:

```shell
cat <<EOL >> ~/.zshrc
export FZF_OPENCOMMIT_KEY_BINDING="^O"
source ~/.fzfopencommit
EOL
```

`~/.zshrc` should be like this.

```shell
source <(fzf --zsh)
export FZF_OPENCOMMIT_KEY_BINDING='^O'
source ~/.fzfopencommit
```

Source run command

```shell
source ~/.zshrc
```

## Usage

Using the shortcut key set in `FZF_OPENCOMMIT_KEY_BINDING`, you can execute `fzf-opencommit`, which will display a list of `ghq` and `git fuzzy` commands.

To run `fzf-opencommit` without using the keyboard shortcut, enter the following command in the shell:

```shell
fzf-opencommit
```

## License

This project is licensed under the MIT License. The MIT License is a permissive free software license that allows for the reuse, modification, distribution, and sale of the software. It requires that the original copyright notice and license text be included in all copies or substantial portions of the software. The software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement.
