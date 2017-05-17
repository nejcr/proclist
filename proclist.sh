#!/bin/bash


user_passed=""
number_passed=""

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
