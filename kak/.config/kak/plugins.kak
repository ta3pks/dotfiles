evaluate-commands %sh{
    plugins="$HOME/.kak_plugins"
    mkdir -p "$plugins"
    [ ! -e "$plugins/plug.kak" ] && \
        git clone -q https://github.com/andreyorst/plug.kak.git "$plugins/plug.kak"
    printf "%s\n" "source '$plugins/plug.kak/rc/plug.kak'"
}
plug "andreyorst/plug.kak" noload
plug "tom-huntington/simple-git-gutter.kak"
plug "h-youhei/kakoune-surround" config %{
    declare-user-mode surround
    map global user s ":enter-user-mode surround<ret>" -docstring "enter surround mode"
    map global surround s ':surround<ret>' -docstring 'surround'
    map global surround c ':change-surround<ret>' -docstring 'change'
    map global surround d ':delete-surround<ret>' -docstring 'delete'
    map global surround t ':select-surrounding-tag<ret>' -docstring 'select tag'
}
plug chambln/kakoune-readline config %{
    map global insert <tab> <c-n>
    map global insert <s-tab> <c-p>
    map global insert <c-p> <up>
    map global insert <c-n> <down>
    hook global WinCreate .* readline-enable
}
plug "raiguard/kak-one" theme config %{
    colorscheme one-darker
}
plug "kakoune-lsp/kakoune-lsp" do %{
    ln -s ~/.config/kak/lsp ~/.config/kak-lsp
} config %{
	# lsp-inlay-diagnostics-enable global
	set-option global lsp_hover_anchor true
	set global lsp_diagnostic_line_error_sign '║'
        set global lsp_diagnostic_line_warning_sign '┊'

        define-command ne -docstring 'go to next error/warning from lsp' %{ lsp-find-error --include-warnings }
        define-command pe -docstring 'go to previous error/warning from lsp' %{ lsp-find-error --previous --include-warnings }
        define-command ee -docstring 'go to current error/warning from lsp' %{ lsp-find-error --include-warnings; lsp-find-error --previous --include-warnings }

        define-command lsp-restart -docstring 'restart lsp server' %{ lsp-stop; lsp-start }
        
            map global  user l ":enter-user-mode lsp<ret>" -docstring "enter lsp commands"
    	    lsp-inlay-hints-enable global
            set-option global lsp_auto_highlight_references true
            set-option global lsp_hover_anchor false
            # lsp-auto-hover-enable
            echo -debug "Enabling LSP for filtetype %opt{filetype}"
            lsp-enable-window
        

        hook global WinSetOption filetype=(rust) %{
            set window lsp_server_configuration rust.clippy_preference="on"
        }

        hook global WinSetOption filetype=rust %{
            hook window BufWritePre .* %{
                evaluate-commands %sh{
                    test -f rustfmt.toml && printf lsp-formatting-sync
                }
            }
        }
        hook global KakEnd .* lsp-exit
}
plug "andreyorst/powerline.kak" defer kakoune-themes %{
  powerline-theme pastel
} defer powerline %{
  powerline-format global "git lsp bufname filetype mode_info lsp line_column position"
  set-option global powerline_separator_thin ""
  set-option global powerline_separator ""
} config %{
  powerline-start
}
plug "evanrelf/byline.kak" config %{
  require-module "byline"
}
