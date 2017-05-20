#!/bin/bash
user_passed="$(whoami)"
declare -a array

while [[ $# -ge 1 ]]; do
    key=$1

	case $key in 
	-u)
		exists=$(grep -c $2":" /etc/passwd)
		if [ $exists -eq 0 ]; then
			echo "Napaka: neznan uporabnik." >&2
			exit 1
		fi
		user_passed=$2
	    shift 2
    ;;
	-n)
		if ! [[ "$2" =~ ^[0-9]+$ ]]; then
			echo "Napaka: argument ni številka." >&2
			exit 2
		fi
        number_passed=$2
    	shift 2
    ;;

	*)
        echo "Napaka: neznano stikalo $1." >&2
	    exit 3
	;;
	esac

done


output() {
    unset array

    if [ -z ${number_passed+x} ]; then
        line_number=$(($(tput lines)-4))
    else
        line_number=$number_passed
    fi

    proclist=$(ps h -u "$user_passed" -o pid:1 --sort=-start_time )
    c=0
    for pid in ${proclist}; do
        ppid=$(ps hp $pid -o ppid:1)
        name=$(ps hp $pid -o comm:1)
        ppid_name=$(echo \($(ps hp $ppid -o comm:1 2>/dev/null)\))
        prior=$(ps hp $pid -o nice:1)
        cpu=$(ps hp $pid -o pcpu:1)
        array[c]=$(printf "%-10s %-7s %-20s %-7s %-20s %-5s %-5s\n" "$user_passed" "$pid" "$name" "$ppid" "$ppid_name" "$prior" "$cpu")
        c=$(($c+1))
    done

    tput reset
    printf "\n\n%-10s %-7s %-20s %-7s %-20s %-5s %-5s\n" "UPORABNIK" "PID" "UKAZ" "PPID" "(UKAZ)" "P" "CPU"
    printf "%s\n" "${array[@]}" | head -n $(($line_number))
}





while true; do
    output 

    read -s -t 1 -n 1 pressed_c 
    
    if [ "$pressed_c" = "u" ]; then
        tput cup 0 0
        echo -n "Uporabnik: "
        tput cup 0 11
        read user_pressed
    	exists=$(grep -c $user_pressed":" /etc/passwd)
        if [ $exists -eq 0 ]; then
            tput reset
	    echo "Napaka: neznan uporabnik." 
	    exit 4
        fi
    	user_passed=$user_pressed
    fi
    
    if [ "$pressed_c" = "n" ]; then
    	tput cup 0 0
        echo -n "Število: "
        tput cup 0 11
	read number_pressed
	if ! [[ "$number_pressed" =~ ^[0-9]+$ ]]; then
		tput reset 
		echo "Napaka: argument ni številka." >&2
                exit 6
        fi
	number_passed=$number_pressed


    fi
    
    if [ "$pressed_c" = "k" ]; then
    	echo "k"
    fi
    
    if [ "$pressed_c" = "q" ]; then
    	exit 0;
    fi

    sleep 1
done
