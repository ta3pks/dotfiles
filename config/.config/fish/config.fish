set -ax PATH  ~/.cargo/bin ~/.cabal/bin ~/.ghcup/bin ~/.gem/ruby/2.6.0/bin /snap/bin ~/Android//Sdk/platform-tools ~/android-studio/bin /usr/lib/dart/bin ~/Android/Sdk/emulator
set -ax PATH $HOME/.local/bin ~/.mybin ~/go/bin ~/bitcoin/bin/ ~/.gem/ruby/2.7.0/bin/ /usr/local/bin/ ~/adb-fastboot/current/
set -x LC_ALL en_US.UTF-8
set -x GPG_TTY (tty)
set -x EDITOR nvim
set -x TERMINAL xterm
set -x TERM screen-256color-bce
set -x GOPATH ~/go
set -x GOBIN $GOPATH/bin
if test (which thefuck)
	thefuck --alias | source
	function f
		fuck
	end
end
test -f ~/.nix-profile/etc/profile.d/nix.sh && bass source ~/.nix-profile/etc/profile.d/nix.sh
# set -x http_proxy socks5://127.0.0.1:9050
# set -x https_proxy socks5://127.0.0.1:9050
# set -x all_proxy socks5://127.0.0.1:9050
function fishcfg
	$EDITOR ~/.config/fish/config.fish
end
function i3cfg
	$EDITOR ~/.config/i3/config
end
function statuscfg
	$EDITOR ~/.config/i3status-rust/config.toml
end
function terminatorcfg
	$EDITOR ~/.config/terminator/config
end
function i3dir
	cd ~/.config/i3/
end
function fish_prompt
	set_color red
	printf "%s >" (prompt_pwd)
	set_color green
	printf "<"
	set_color blue
	printf "> "
end

if not functions -q fisher
	set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
	curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
	fish -c fisher
end
# set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
source ~/.asdf/asdf.fish
