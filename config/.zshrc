autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '\ee' edit-command-line
if type brew &>/dev/null; then
	FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

	autoload -Uz compinit
	compinit
fi
. /opt/homebrew/etc/profile.d/z.sh
alias zshrc="nvim ~/.zshrc&&source ~/.zshrc"
alias aliases="nvim ~/.zsh.aliases&&source ~/.zsh.aliases"
if test -f /opt/homebrew/opt/asdf/libexec/asdf.sh; then
	source /opt/homebrew/opt/asdf/libexec/asdf.sh
elif test -f ~/.asdf/asdf.sh; then
	source ~/.asdf/asdf.sh
fi
export PATH=$PATH:~/.local/bin
export EDITOR=nvim
export VISUAL=$EDITOR

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.zsh.aliases ] && source ~/.zsh.aliases
[ -f ~/.ssh/secret_env ] && source ~/.ssh/secret_env
export LC_CTYPE="en_US.UTF-8"
PS1='%~ -> '
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

