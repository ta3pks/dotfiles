PS1="\w \[\e[31m\]>\[\e[0m\]\[\e[32m\]<>\[\e[0m\] "
#if thefuck exists create alias f for it
which thefuck > /dev/null
if [ $? -eq 0 ]
then
	eval $(thefuck --alias)
	alias f=fuck
fi
if [ -f $HOME/.asdf/asdf.sh ]; then
	source $HOME/.asdf/asdf.sh
	source $HOME/.asdf/completions/asdf.bash
fi
if [ -f $HOME/.cargo/env ]; then
	source $HOME/.cargo/env
fi
which npm > /dev/null && PATH="$PATH:$(npm config --global get prefix)/bin"
function disableWakers () {
	for waker in $(grep enabled /proc/acpi/wakeup|cut -f1); do
		echo $waker | sudo tee /proc/acpi/wakeup
	done
}
test -f ~/.mybin/z.sh && . ~/.mybin/z.sh
which nvim > /dev/null && EDITOR=nvim || EDITOR=vim
alias bashrc="$EDITOR ~/.bashrc"
alias kittycfg="$EDITOR ~/.config/kitty/kitty.conf"
if [ -d ~/.local/share/bash-completion/completions ]
then
	for f in $(ls ~/.local/share/bash-completion/completions)
	do 
		. "$HOME/.local/share/bash-completion/completions/$f"
	done
fi
if [ -e /home/nikos/.nix-profile/etc/profile.d/nix.sh ]; then . /home/nikos/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
. "$HOME/.cargo/env"
