service squid3 stop &
(
sleep 3
qq=$(ps aux|grep "/etc/init.d/squid3 stop"|grep -v "grep")
pct=0
q1=2
while [ $pct -lt 100 ]; do
	pct=$(( $pct + 1 ))
	qq=$(ps aux|grep "/etc/init.d/squid3 stop"|grep -v "grep")
	if [ -z "$qq" ]; then q1=$(($q1+92)); fi
	echo "$pct"
	sleep .4
	if [ $q1 -eq 94 ]
	then
		pct=90
	fi
done
) | dialog --title "MUSCLE BOAR" --gauge "O Muscle Boar está Desligando o proxy...\n\nAguarde um instante..." 10 60 0
