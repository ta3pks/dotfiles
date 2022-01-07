local wezterm = require("wezterm");
return {
	font = wezterm.font("Fira Code"),
	color_scheme = "OneHalfDark" ,
	font_size = 16,
	send_composed_key_when_left_alt_is_pressed=false,
	send_composed_key_when_right_alt_is_pressed=true,
	native_macos_fullscreen_mode=true,
	hide_tab_bar_if_only_one_tab=true,
	use_fancy_tab_bar=false,
	tab_bar_at_bottom=true,
	keys = {
		{key="e",mods="SUPER",action=wezterm.action{SplitHorizontal={}}},
		{key="e",mods="SUPER|CTRL",action=wezterm.action{SplitVertical={}}},
		{key="j",mods="SUPER|ALT",action=wezterm.action{ActivatePaneDirection="Left"}},
		{key="k",mods="SUPER|ALT",action=wezterm.action{ActivatePaneDirection="Right"}},
		{key="J",mods="SUPER|ALT",action=wezterm.action{ActivatePaneDirection="Down"}},
		{key="K",mods="SUPER|ALT",action=wezterm.action{ActivatePaneDirection="Up"}},
		{key="L",mods="CTRL",action="DisableDefaultAssignment"},
	}
}
