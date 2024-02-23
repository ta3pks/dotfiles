evaluate-commands %sh{
    plugins="~/.kak_plugins"
    mkdir -p "$plugins"
    [ ! -e "$plugins/plug.kak" ] && \
        git clone -q https://github.com/andreyorst/plug.kak.git "$plugins/plug.kak"
    printf "%s\n" "source '$plugins/plug.kak/rc/plug.kak'"
}
plug "andreyorst/plug.kak" noload
plug "raiguard/kak-one" theme config %{
    colorscheme one-darker
}
plug "kakoune-lsp/kakoune-lsp" do %{
    mkdir -p ~/.config/kak/lsp
    cp -n kak-lsp.toml ~/.config/kak/lsp/
} config %{
	lsp-auto-hover-enable
	lsp-inlay-hints-enable global
	# lsp-inlay-diagnostics-enable global
	set-option global lsp_hover_anchor true
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
