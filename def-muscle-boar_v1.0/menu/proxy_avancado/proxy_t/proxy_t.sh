#!/bin/bash
tit='--colors --title MUSCLE_BOAR'
titr='--colors --title \Z1MUSCLE_BOAR'
grep "intercept" /etc/squid3/squid.conf > /dev/null
if [ $? = 0 ]; then
	dialog $tit --msgbox "\nO proxy transparente já está ativo neste servidor!" 0 0
else
	dialog $tit --yesno "\nA ativação do proxy transparente fará com que o \
proxy com autenticação pare de funcionar, suas configurações não serão apagadas, apenas \
ficarão inativas.\nVocê pode reativar o proxy com autenticação na opção: Proxy Avançado > \
Ativar proxy com autenticação.\n\nVocê tem certeza de que deseja ativar o proxy transparente?" 0 0
	if [ $? != 0 ]; then
		echo ""
	else
		sed -ri "s/http_port 3128 */http_port 3128 intercept/" /etc/squid3/squid.conf
		sed -ri "s/([#]?)*auth_param/#auth_param/" /etc/squid3/squid.conf
		sed -ri "s/([#]?)*acl autentic/#acl autentic/" /etc/squid3/squid.conf
		sed -ri "s/([#]?)*http_access allow autentic/#http_access allow autentic/" /etc/squid3/squid.conf
﻿		;(
		service squid3 restart &
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
		) | dialog --title "MUSCLE BOAR" --gauge "O Muscle Boar está reiniciando o proxy...\n\nAguarde um instante..." 10 60 0
	fi
fi
