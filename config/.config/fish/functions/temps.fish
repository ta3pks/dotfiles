function temps
for i in (seq 2 12)
          printf "\e[31m%d\e[0m" $i ; rssh $i "bash check_temp.sh"&
      end
end
