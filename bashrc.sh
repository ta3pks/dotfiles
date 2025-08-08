export TERM=xterm-256color
#PROMPT_COMMAND='PS1_CMD1=$(gitprompt-rs)'; export PS1='\[\e[96m\]\w\[\e[0m\] ${PS1_CMD1} '
. "$HOME/.cargo/env"
#eval "$(direnv hook bash)"
#eval "$(zoxide init bash)"
export CARGO_TARGET_DIR="$HOME/.rust_build"
export PATH="$PATH:/opt/nvim-linux64/bin:$HOME/Apps"
alias bashrc="nvim ~/dotfiles/bashrc.sh&&source ~/dotfiles/bashrc.sh"
alias zshrc="nvim ~/.zshrc&&source ~/.zshrc"
export EDITOR=nvim
alias vim=nvim
alias sshcfg="nvim ~/.ssh/config"
alias yarn="corepack yarn"
export DENO_INSTALL="/home/nikos/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
if [ -f "$HOME/.env" ]; then
  . "$HOME/.env"
fi
if [ -f "$HOME/.bash_aliases" ]; then
  . "$HOME/.bash_aliases"
fi
unix_ts() {
  date --date="@$1"
}
# set completion-ignore-case On
