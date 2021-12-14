local wezterm = require("wezterm");
return {
	font = wezterm.font("Fira Code"),
	color_scheme = "OneHalfDark" ,
	font_size = 16,
	send_composed_key_when_left_alt_is_pressed=false,
	send_composed_key_when_right_alt_is_pressed=true,
	native_macos_fullscreen_mode=true,
	keys = {
		{key="e",mods="SUPER",action=wezterm.action{SplitHorizontal={}}},
		{key="e",mods="SUPER|CTRL",action=wezterm.action{SplitVertical={}}},
		{key="j",mods="CTRL|ALT",action=wezterm.action{ActivatePaneDirection="Left"}},
		{key="k",mods="CTRL|ALT",action=wezterm.action{ActivatePaneDirection="Right"}},
		{key="J",mods="CTRL|ALT",action=wezterm.action{ActivatePaneDirection="Down"}},
		{key="K",mods="CTRL|ALT",action=wezterm.action{ActivatePaneDirection="Up"}},
		{key="L",mods="CTRL",action="DisableDefaultAssignment"},
	}
}
