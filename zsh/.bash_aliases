alias open='xdg-open'
alias bash_aliases="nvim ~/.bash_aliases && source ~/.bash_aliases"
alias rustcfg="nvim ~/.cargo/config.toml"
alias pbcopy="xclip -selection clipboard"
alias cupdate="cargo update"
alias cupgrade="cargo upgrade"
alias apt="sudo apt"
alias mdp="make deploy restart logs"
alias gpt="ollama run mistral"
alias gvp="git vup"
alias snvim="sudo /opt/nvim-linux64/bin/nvim"
alias fnvim="fzf | xargs nvim"
# alias gpt="tgpt -m"
alias psql="sudo -u postgres psql"
alias px_psql="sudo -u postgres psql -d proxy"
ipi() {
  curl -L "https://ipapi.co/json"
}
export PX="http://localhost:6080"
set_proxy() {
  export HTTP_PROXY=$PX
  export ALL_PROXY=$PX
  export HTTPS_PROXY=$PX
}
unset_proxy() {
  unset HTTP_PROXY
  unset ALL_PROXY
  unset HTTPS_PROXY
}
alias ap=ansible-playbook
alias gmain="git merge main"

alias claude="CLAUDE_BYPASS_PERMISSIONS=1 claude --dangerously-skip-permissions  --allow-dangerously-skip-permissions   --teammate-mode tmux "
alias o="opencode"
alias or="opencode run"

vllm() {
  HSA_OVERRIDE_GFX_VERSION=11.0.0 python3.12 -m vllm.entrypoints.openai.api_server \
    --model "$1" \
    --gpu-memory-utilization 0.9
}
