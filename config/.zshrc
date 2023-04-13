. /opt/homebrew/etc/profile.d/z.sh
export LC_CTYPE="en_US.UTF-8"
alias zshrc="nvim ~/.zshrc&&source ~/.zshrc"
alias aliases="nvim ~/.zsh.aliases&&source ~/.zsh.aliases"
PS1='%~ -> '
if test -f /opt/homebrew/opt/asdf/libexec/asdf.sh; then
	source /opt/homebrew/opt/asdf/libexec/asdf.sh
elif test -f ~/.asdf/asdf.sh; then
	source ~/.asdf/asdf.sh
fi


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.zsh.aliases ] && source ~/.zsh.aliases
