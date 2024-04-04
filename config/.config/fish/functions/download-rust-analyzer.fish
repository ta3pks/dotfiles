# Defined in /tmp/fish.EIUP23/download-analyzer.fish @ line 1
function download-rust-analyzer
	set -l VERS (curl https://github.com/rust-analyzer/rust-analyzer/releases/latest -L |grep 'tag/[v.0-9\-]*' -o | sed 's/tag\///' | head -n 1)
	curl -L https://github.com/rust-analyzer/rust-analyzer/releases/download/$VERS/rust-analyzer-linux > /usr/local/bin/rust-analyzer
	chmod +x /usr/local/bin/rust-analyzer
end
