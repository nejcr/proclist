#!/bin/bash

if [ -z "$1" ]; then
  echo "Kot argument skripti $(basename $0) morate podati ime vaše skripte."
  exit 1
fi

if ! [ -x "$1" ]; then
  echo "Datoteka z imenom $1 ne obstaja ali pa ni izvršljiva"
  exit 2
fi

id student &>/dev/null || { echo "V sistemu morate imeti uporabnika student"; exit 3; }

echo -n "Geslo za $(whoami):"
read geslo

#v nadaljevanju so primeri testov, ne pa vsi testi, ki bodo uporabljeni pri preverjanju delovanja oddane rešitve

###################################### testiranje stikal ###########################
#napačno stikalo
izpis=$(./$1 -l 2>&1)
status=$?
#izpis napake (ni važno kam)
[ "$(echo "$izpis")" = "Napaka: neznano stikalo -l." ] && tocke1=$(($tocke1+1))

#ustrezni izhodni status
[ $status -gt 0 ] && tocke1=$(($tocke1+1))

#izpis napake na ustrezen izhod
izpis=$(./$1 -l 2>&1 1>/dev/null)
[ "$(echo $izpis)" = "Napaka: neznano stikalo -l." ] && tocke1=$(($tocke1+1))
tocke=$((tocke+tocke1))
out="$out\n$(echo -e "Napaka: neznano stikalo.\t\t$tocke1/3: skupaj=$tocke\n")"


########################(ukaz n) Napaka: argument ni številka.
izpis=$(./$1 -n a 2>&1)
status=$?
#izpis napake (ni važno kam)
[ "$(echo "$izpis")" = "Napaka: argument ni številka." ] && tocke3=$(($tocke3+1))

#ustrezni izhodni status
[ $status -gt 0 ] && tocke3=$(($tocke3+1))

#izpis napake na ustrezen izhod
izpis=$(./$1 -n a 2>&1 1>/dev/null)
[ "$(echo $izpis)" = "Napaka: argument ni številka." ] && tocke3=$(($tocke3+1))
tocke=$((tocke+tocke3))
out="$out\n$(echo -e "Napaka: argument ni številka.\t\t$tocke3/3: skupaj=$tocke\n")"


#izpis brez stikal
izpis=$(echo -n q | ./$1 2>&1)
#preverimo če je glava OK
#je izpis ok (ni vazno koliko je presledkov)
echo -e "$izpis" | grep -q "UPORABNIK *PID *UKAZ *PPID *(UKAZ) *P *CPU"
status=$?
[ $status -eq 0 ] && tocke4=$(($tocke4+1))
tocke=$((tocke+tocke4))
out="$out\n$(echo -e "Prava glava\t\t\t\t$tocke4/1: skupaj=$tocke")"





echo -e "$izpis" | grep "UPORABNIK"
echo -ne "\033[6n"            # ask the terminal for the position
read -s -d\[ garbage          # discard the first part of the response
read -s -d R foo              # store the position in bash variable 'foo'
clear 
echo -e "$out"
y=$(echo "$foo" | cut -d';' -f1)

#pravi uporabnik
u=$(echo q | ./$1 | head -n $(($y-1)) | tail -1 | cut -d" " -f1)
[ $u = $(whoami) ] && tocke6=$(($tocke6+2)) 
tocke=$((tocke+tocke6))
echo -e "Pravi uporabnik\t\t\t\t$tocke6/2: skupaj=$tocke"


#ustvarimo 5 procesov
xhost + > /dev/null
echo "$geslo" | sudo -S &>/dev/null su - student -c xclock & &>/dev/null
sleep 1
echo "$geslo" | sudo -S &>/dev/null su - student -c xeyes & &>/dev/null
sleep 1
echo "$geslo" | sudo -S &>/dev/null su - student -c xlogo & &>/dev/null
sleep 1
echo "$geslo" | sudo -S &>/dev/null su - student -c 'xclock -d' & &>/dev/null
sleep 1
echo "$geslo" | sudo -S &>/dev/null su - student -c 'xeyes -center "#674F0D"' & &>/dev/null
sleep 1

#izpis procesov za studenta
izpis=$(echo -n q | ./$1 -u student 2>&1)

vrstica1="student1 +[0-9]+ +xeyes + [0-9]+ *\(su\) +[-0-9]+ +[0-9]+\.[0-9]+ *"
vrstica2="student1 +[0-9]+ +xclock + [0-9]+ *\(su\) +[-0-9]+ +[0-9]+\.[0-9]+ *"
vrstica3="student1 +[0-9]+ +xlogo + [0-9]+ *\(su\) +[-0-9]+ +[0-9]+\.[0-9]+ *"
vrstica4="student1 +[0-9]+ +xeyes + [0-9]+ *\(su\) +[-0-9]+ +[0-9]+\.[0-9]+ *"
vrstica5="student1 +[0-9]+ +xclock + [0-9]+ *\(su\) +[-0-9]+ +[0-9]+\.[0-9]+ *"



echo -e "$izpis" | tr -d "\n" | grep -q -E "$vrstica1" && tocke8=$(($tocke8+1)) 
echo -e "$izpis" | tr -d "\n" | grep -q -E "$vrstica1$vrstica2" && tocke8=$(($tocke8+1))
echo -e "$izpis" | tr -d "\n" | grep -q -E "$vrstica1$vrstica2$vrstica3" && tocke8=$(($tocke8+1))
echo -e "$izpis" | tr -d "\n" | grep -q -E "$vrstica1$vrstica2$vrstica3$vrstica4" && tocke8=$(($tocke8+1))
echo -e "$izpis" | tr -d "\n" | grep -q -E "$vrstica1$vrstica2$vrstica3$vrstica4$vrstica5" && tocke8=$(($tocke8+1))
tocke=$((tocke+tocke8))
echo -e "Izpis procesov za studenta\t\t$tocke8/5: skupaj=$tocke"


#preverjanja ukazov in parmatrov: u+uporabnik
izpis=$(echo -ne "u student\n q" | ./$1)
echo -e "$izpis" | tr -d "\n" | grep -q -E "$vrstica1$vrstica2$vrstica3$vrstica4$vrstica5" && tocke10=$(($tocke10+2))
tocke=$((tocke+tocke10))
echo -e "Ukaz u + uporabnik\t\t\t$tocke10/2: skupaj=$tocke"

#preverjanja ukazov in parmatrov: n+število
izpis=$(echo -ne "n 1\n q" | ./$1 -u student)
echo -e "$izpis" | tr -d "\n" | grep -q -E "$vrstica1" && tocke11=$(($tocke11+2)) 
tocke=$((tocke+tocke11))
echo -e "Ukaz n + stevilo\t\t\t$tocke11/2: skupaj=$tocke"


echo "$geslo" | sudo -S killall -u student &>/dev/null #pobijemo vse procese studenta

#Napake:
#preverjanja ukazov in parmatrov: u+uporabnik
izpis=$(echo -ne "u UporabnikKiNeObstaja\n q" | ./$1 -u root)
echo -e "$izpis" | tr -d "\n" | grep -q -E "Napaka: neznan uporabnik\." && tocke13=$(($tocke13+2))
tocke=$((tocke+tocke13))
echo -e "Ukaz u + napačen uporabnik\t\t$tocke13/2: skupaj=$tocke"

exit
