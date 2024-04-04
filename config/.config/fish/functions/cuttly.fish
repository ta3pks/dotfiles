# Defined in /tmp/fish.y2EviK/cuttly.fish @ line 2
function cuttly
	set -l keypath ~/.cuttly.key
	if test -n "$argv[1]"  && test "init" = "$argv[1]"
		if test -z "$argv[2]" 
			echo "missing key arg please call cuttly init <apikey>"
			return
		else
			echo "$argv[2]">$keypath
			return
		end
	else if ! test -f "$keypath"
		echo "missing api key please run cuttly init <apikey>"
		return
	else if test -z "$argv[1]"
		echo "missing argument please specify url to shorten cuttly <url>"
		return
	end
	set -l resp (curl "https://cutt.ly/api/api.php?short=$argv[1]&key="(cat "$keypath") 2>/dev/null)
	if test (echo "$resp"|jq '.url.status') -ne 7
		echo "$resp"
	else
		set -l link (echo "$resp"|jq '.url.shortLink'|xargs)
		echo "$link"|xclip -selection clipboard
		echo "$link copied to clipboard"
	end
end
