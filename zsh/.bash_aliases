alias REDACTED_PROJECTdb="clickhouse-cli  -u default --arg-password REDACTED_PASSWORD --database REDACTED_PROJECT --vi-mode"
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
deploy_build() {
	rsync -vahurz --progress ~/.rust_build/x86_64-unknown-linux-gnu/"$1" REDACTED_PROJECT:/usr/local/bin/
}
alias ap=ansible-playbook
alias gmain="git merge main"
CLUSTER_IPS=(
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	# REDACTED_IP
	REDACTED_IP
	REDACTED_IP
	REDACTED_IP
	REDACTED_IP
)
cluster_ip() {
	random_ip=${CLUSTER_IPS[$RANDOM % ${#CLUSTER_IPS[@]}]}
	if [[ -n "$1" && "$1" =~ ^[0-9]+$ ]]; then
		selected_ip=${CLUSTER_IPS[$1]}
		echo "using cluster ip ${CLUSTER_IPS[$1]}"
	else
		selected_ip=$random_ip
		echo "using random cluster ip $selected_ip"
	fi
}
dccli() {
	clickhouse-cli --vi-mode --host localhost --port 8124 -d REDACTED_PROJECT "${@:2}"
}
dccl() {
	clickhouse client --host localhost --port 8124 -d REDACTED_PROJECT "${@:2}"
}
dssh() {
	cluster_ip "$@"
	ssh root@"$selected_ip"
}
add_rm_current_ip_to_cluster() {
	if [[ "$1" == "rm" ]]; then
		if [[ -n "$2" ]]; then
			ip=$2
		else
			echo "Error: IP address is required for remove operation"
			echo "Usage: add_rm_current_ip_to_cluster rm <ip>"
			return 1
		fi
		echo "removing ip $ip from cluster"
		ansible -m 'community.general.ufw' -a "src=$ip rule=allow delete=true" db\*
	elif [[ "$1" == "add" ]]; then
		if [[ -n "$2" ]]; then
			ip=$2
		else
			ip=$(ipi | jq '.ip')
		fi
		comment=${3:-"tmp ip"}
		echo "adding ip $ip to cluster with comment '$comment'"
		ansible -m 'community.general.ufw' -a "src=$ip comment='$comment' rule=allow" db\*
	else
		echo "Usage: add_rm_current_ip_to_cluster [add|rm] [ip] [comment]"
		return 1
	fi
}
claude_test() {
	curl -x $PX https://api.anthropic.com/v1/models \
		--header "x-api-key: $ANTHROPIC_API_KEY" \
		--header "anthropic-version: 2023-06-01"
}
ask_claude() {
	curl https://api.anthropic.com/v1/messages \
		-x $PX \
		--header "x-api-key: $ANTHROPIC_API_KEY" \
		--header "anthropic-version: 2023-06-01" \
		--header "content-type: application/json" \
		--data "{ \"model\": \"claude-3-7-sonnet-20250219\", \"max_tokens\": 1024, \"messages\": [ {\"role\": \"user\", \"content\": \"$1\" }]}"
}
alias claude="CLAUDE_BYPASS_PERMISSIONS=1 claude --dangerously-skip-permissions  --allow-dangerously-skip-permissions   --teammate-mode tmux "
alias o="opencode"
alias or="opencode run"
