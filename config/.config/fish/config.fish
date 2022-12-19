 fish_default_key_bindings
# fish_vi_key_bindings
set -ax PATH  ~/.cargo/bin ~/.cabal/bin ~/.ghcup/bin ~/.gem/ruby/2.6.0/bin /snap/bin ~/Android//Sdk/platform-tools ~/android-studio/bin ~/Android/Sdk/emulator
set -ax PATH $HOME/.local/bin ~/.mybin ~/go/bin ~/bitcoin/bin/ ~/.gem/ruby/2.7.0/bin/ /usr/local/bin/ ~/adb-fastboot/current/ $JAVA_HOME/bin
set -x LC_ALL en_US.UTF-8
set -x GPG_TTY (tty)
set -x EDITOR nvim
set -x TERMINAL xterm
set -x TERM screen-256color-bce
set -x GOPATH ~/go
set -x GOBIN $GOPATH/bin
if test -f /opt/homebrew/bin/brew
	eval (/opt/homebrew/bin/brew shellenv)
end
if test (which thefuck)
	thefuck --alias | source
	function f
		fuck
	end
end
# set -x http_proxy socks5://127.0.0.1:9050
# set -x https_proxy socks5://127.0.0.1:9050
# set -x all_proxy socks5://127.0.0.1:9050
function sshcfg
	$EDITOR ~/.ssh/config
end
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
if test -f /opt/homebrew/opt/asdf/libexec/asdf.fish
	source /opt/homebrew/opt/asdf/libexec/asdf.fish
else if test -f ~/.asdf/asdf.fish
	source ~/.asdf/asdf.fish
end
# ghcup-env
set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME
test -f /home/nikos/.ghcup/env ; and set -gx PATH $HOME/.cabal/bin /home/nikos/.ghcup/bin $PATH
alias rss=newsboat
alias snvim="sudo -E nvim"
set -x __CARGO_FIX_YOLO 1

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

fish_add_path /opt/homebrew/opt/libpq/bin
set -x PGPASSWORD postgres
fish_add_path /opt/homebrew/opt/llvm/bin

source /opt/homebrew/opt/asdf/libexec/asdf.fish
fish_add_path ~/.local/share/nvim/lsp_servers/rust
fish_add_path ~/.local/share/nvim/lsp_servers/taplo/bin
fish_add_path ~/.flutter_dir/bin/

# pnpm
set -gx PNPM_HOME "/Users/nikos/Library/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end
