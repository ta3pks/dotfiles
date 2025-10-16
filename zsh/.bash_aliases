alias dedectadb="clickhouse client -u default --password atlas123 -d dedecta"
alias dedectacluster="clickhouse client -d dedecta --port 9001"
alias bash_aliases="nvim ~/.bash_aliases && source ~/.bash_aliases"
alias rustcfg="nvim ~/.cargo/config.toml"
alias dedectadbcli="clickhouse-cli --vi-mode -u default --arg-password atlas123 --database dedecta"
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
	rsync -vahurz --progress ~/.rust_build/x86_64-unknown-linux-gnu/"$1" dedecta:/usr/local/bin/
}
alias dedecta="ssh dedecta -t tmux a"
alias ap=ansible-playbook
CLUSTER_IPS=(
	# 178.162.244.146
	# 178.162.244.147
	# 178.162.244.148
	# 178.162.244.149
	# 178.162.244.150
	# 178.162.244.151
	# 178.162.244.152
	# 178.162.244.153
	# 178.162.244.154
	# 178.162.244.155
	# 94.237.88.229
	# 94.237.24.205
	# 94.237.98.26
	# 94.237.31.148
	# 94.237.103.171
	# 94.237.80.35
	# 94.237.99.70
	# 85.9.204.89
	# 94.237.93.79
	# 5.22.214.67
	138.199.140.164
	138.199.140.163
	138.199.140.162
	138.199.140.161
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
	clickhouse-cli --vi-mode --host localhost --port 8124 -d dedecta "${@:2}"
}
dccl() {
	clickhouse client --host localhost --port 8124 -d dedecta "${@:2}"
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
alias o="opencode"
alias or="opencode run"
