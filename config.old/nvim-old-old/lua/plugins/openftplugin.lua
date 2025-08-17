local m = {}

function m.open_ft_plugin()
	local ft = vim.o.filetype
	if ft == nil or ft == "" then
		print("unknown ft")
	else
		vim.cmd("tabnew " .. require("utils").vimrc_dir() .. "after/ftplugin/" .. ft .. ".vim")
	end
end

return m
