# Defined in /tmp/fish.xrYABv/gen_system_token.fish @ line 1
function gen_system_token
	set _id $argv[1]
	set _secret $argv[2]
	set _nonce $argv[3]
	printf "%s%s%s" $_id $_secret $_nonce | md5sum | cut -d " " -f1 | xargs
end
