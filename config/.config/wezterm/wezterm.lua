local wezterm = require("wezterm");
return {
	font = wezterm.font("Fira Code"),
	color_scheme = "OneHalfDark",
	font_size = 16,
	send_composed_key_when_left_alt_is_pressed = false,
	send_composed_key_when_right_alt_is_pressed = true,
	native_macos_fullscreen_mode = true,
	hide_tab_bar_if_only_one_tab = true,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,
	keys = {
		{ key = "e", mods = "SUPER", action = wezterm.action { SplitHorizontal = {} } },
		{ key = "e", mods = "SUPER|CTRL", action = wezterm.action { SplitVertical = {} } },
		{ key = "k", mods = "SUPER|ALT", action = wezterm.action { ActivatePaneDirection = "Prev" } },
		{ key = "j", mods = "SUPER|ALT", action = wezterm.action { ActivatePaneDirection = "Next" } },
		{ key = "L", mods = "CTRL", action = "DisableDefaultAssignment" },
		{ key = "Z", mods = "CTRL", action = "DisableDefaultAssignment" },
		{ key = "z", mods = "SUPER", action = "TogglePaneZoomState" },
	},
	key_tables = {
		copy_mode = {
			{ key = "Escape", mods = "NONE", action = wezterm.action { CopyMode = "Close" } },
			{ key = "h", mods = "NONE", action = wezterm.action { CopyMode = "MoveLeft" } },
			{ key = "j", mods = "NONE", action = wezterm.action { CopyMode = "MoveDown" } },
			{ key = "k", mods = "NONE", action = wezterm.action { CopyMode = "MoveUp" } },
			{ key = "l", mods = "NONE", action = wezterm.action { CopyMode = "MoveRight" } },
			-- Enter search mode to edit the pattern.
			-- When the search pattern is an empty string the existing pattern is preserved
			{ key = "/", mods = "NONE", action = wezterm.action { Search = { CaseSensitiveString = "" } } },
			-- navigate any search mode results
			{ key = "n", mods = "NONE", action = wezterm.action { CopyMode = "NextMatch" } },
			{ key = "N", mods = "SHIFT", action = wezterm.action { CopyMode = "PriorMatch" } },
			{ key = "v", mods = "NONE", action = wezterm.action { CopyMode = { SetSelectionMode = "Cell" } } },
			{ key = "V", mods = "NONE", action = wezterm.action { CopyMode = { SetSelectionMode = "Line" } } },
			{ key = "V", mods = "SHIFT", action = wezterm.action { CopyMode = { SetSelectionMode = "Line" } } },
			{ key = "v", mods = "CTRL", action = wezterm.action { CopyMode = { SetSelectionMode = "Block" } } },
		},
		search_mode = {
			{ key = "Escape", mods = "NONE", action = wezterm.action { CopyMode = "Close" } },
			-- Go back to copy mode when pressing enter, so that we can use unmodified keys like "n"
			-- to navigate search results without conflicting with typing into the search area.
			{ key = "Enter", mods = "NONE", action = "ActivateCopyMode" },
		},
	},
	--quick_select_patterns={
	--	--"[a-zA-Z.]+",-- any word with a possible dot in it
	--}
}
