export PLUGINS_DIR="$HOME/.bash_plugins"
# if [[ -f "$PLUGINS_DIR/fzf-tab-completion/bash/fzf-bash-completion.sh" ]] 
# then 
#         # echo here
#         source "$PLUGINS_DIR/fzf-tab-completion/bash/fzf-bash-completion.sh"
#         _fzf_bash_completion_loading_msg() { echo "${PS1@P}${READLINE_LINE}" | tail -n1; }
#         bind -x '"\t": fzf_bash_completion'
# fi
export TERM=xterm-256color
PROMPT_COMMAND='PS1_CMD1=$(gitprompt-rs)'; export PS1='\[\e[96m\]\w\[\e[0m\] ${PS1_CMD1} '
. "$HOME/.cargo/env"
eval "$(direnv hook bash)"
eval "$(zoxide init bash)"
export CARGO_TARGET_DIR="$HOME/.rust_build"
export PATH="$PATH:/opt/nvim-linux64/bin"
alias bashrc="nvim ~/dotfiles/bashrc.sh&&source ~/.bashrc"
export EDITOR=nvim
alias vim=nvim
 export DENO_INSTALL="/home/nikos/.deno"
 export PATH="$DENO_INSTALL/bin:$PATH"
 if [ -f "$HOME/.env" ]; then
    . "$HOME/.env"
fi
if [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
fi
set completion-ignore-case On
