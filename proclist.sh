#!/bin/bash


user_passed="$(whoami)"
number_passed="$(tput lines)"

while [[ $# -ge 1 ]];do
 key=$1
	case $key in 

	-u)
		exists=$(grep -c $2":" /etc/passwd)
		if [ $exists -eq 0 ]; then
			echo "Napaka: neznan uporabnik." >&2
			exit 1
		fi
		user_passed=$2

	shift 2 ;;


	-n)

		if ! [[ "$2" =~ ^[0-9]+$ ]]; then
			echo "Napaka: argument ni številka." >&2
			exit 2
		fi
		number_passed=$2
		echo "$number"

	shift 2 ;;



	*)

		echo "Napaka: neznano stikalo $1." >&2
		exit 3
		;;
	esac
done

output(){

echo ""
echo ""
echo "UPORABNIK       PID    UKAZ  PPID   (UKAZ)              P        CPU" 
proclist=$(ps  h -u "$user_passed" -o pid:1 --sort=-start_time)
niz=""
for a_pid in ${proclist} ; do
p_name=$(ps h -p "$a_pid" -o comm)
a_ppid=$(ps h -p "$a_pid" -o ppid)
parent_name=$(ps -o comm= $a_ppid)

niz="$p_name  $parent_name   \n"
done
echo -e "$niz" 
niz=""
}

while true; do
clear  
output 
read -s -t 1 -n 1 pressed_c 

if [ "$pressed_c" = "u" ];then

        clear
        output 
        tput cup 0 0
        echo -n "Uporabnik: "
        tput cup 0 10
        read user_pressed
	exists=$(grep -c $user_pressed":" /etc/passwd)
                if [ $exists -eq 0 ]; then
			tput reset
                        echo "Napaka: neznan uporabnik." >&2
                        exit 4
                fi
	user_passed=$user_pressed


fi


if [ "$pressed_c" = "n" ]; then

	echo "$n"

fi


if [ "$pressed_c" = "k" ]; then

	echo "$k"

fi


if [ "$pressed_c" = "q" ]; then

	exit 0;

fi



sleep 1 

done

