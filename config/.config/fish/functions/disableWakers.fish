function disableWakers
	for i in (grep enabled /proc/acpi/wakeup )
		if test ! (string match -ir peg "$i")
			echo "$i" | cut -f1|sudo tee /proc/acpi/wakeup 
		end
	end
end

