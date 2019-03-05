#!/bin/bash
tit='--colors --title MUSCLE_BOAR'
titr='--colors --title \Z1MUSCLE_BOAR'
naosim=$(dialog $titr --stdout --inputbox "\nTem certeza de que deseja restaurar o Muscle Boar para sua \
configuração original? Isso APAGARÁ TODAS as suas mudanças, desde a instalação do programa! \
\n\nSe realmente tem certeza de que deseja realizar esta ação escreva na caixa de dialogo:  \
RESTAURAR" 0 0)
if [ "$naosim" = "RESTAURAR" ]
then
	cd /etc/boar
	touch /etc/boar/certificado.mb
	cp srg.conf /etc/srg/srg.conf
	name=$(hostname)
	rm -r /etc/squid3/block_list
	mkdir /etc/squid3/block_list
	cp block_list/* /etc/squid3/block_list/
	rm /etc/squid3/squid_passwd
	touch /etc/squid3/squid_passwd
	rm /etc/squid3/squid.conf
	touch /etc/squid3/squid.conf
	cat squid.conf|sed -r "s/%NOME%/$name/" >/etc/squid3/squid.conf
	rm /var/www/html/*
	echo -e "#!/bin/bash\n/etc/boar/GGGJ-p1.sh" > /usr/local/sbin/muscleboar
	chmod +x /usr/local/sbin/muscleboar
﻿;(
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
) | dialog --title "MUSCLE BOAR" --gauge "O Muscle Boar está sendo restaurado às suas configurações padrão... Aguarde um instante..." 10 60 0
else
	dialog $titr --msgbox "\n\nRestauração não concluída... Retornando ao menu principal..." 0 0
	exit
fi
