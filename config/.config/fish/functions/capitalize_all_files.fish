function capitalize_all_files
	for i in (ls $argv[1])	
		mv -v ( string replace -a "//" "/" "$argv[1]/$i") (string replace -a "//" "/" "$argv[1]/"(string upper $i))
	end
end

