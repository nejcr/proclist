
#!/bin/bash


output(){
echo "                   "
echo "                   "
echo "                   "
echo "now is ---->$(ps nejcr)"
echo "                   "
}

while true;do
clear
output &
read -s -t 1 -n 1 username
if [ "$username" = "u" ];then

	clear
	output 
	tput cup 0 0
	echo -n "Uporabnik: "
	tput cup 0 10
	read typing

fi
sleep 1 &


done
