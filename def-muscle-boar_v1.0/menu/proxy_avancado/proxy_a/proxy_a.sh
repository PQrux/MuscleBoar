#!/bin/bash
tit='--colors --title MUSCLE_BOAR'
titr='--colors --title \Z1MUSCLE_BOAR'
while true
do
grep "intercept" /etc/squid3/squid.conf > /dev/null
if [ $? != 0 ]; then
opt=$(dialog $tit --menu --stdout "\nVOCE ENTROU NA CONFIGURAÇÃO DO PROXY DE AUTENTICAÇÃO" 0 0 0 \
1 "Alterar/Criar Usuário" \
2 "Remover Usuário" \
3 "Voltar ao menu principal")
case $opt in
1)
usu=$(cat /etc/squid3/squid_passwd|cut -d":" -f1|xargs -I@ echo "@ \n")
sus=$(dialog $tit --inputbox --stdout "\nSegue abaixo a lista dos usuários já existentes, Digite o nome de um deles para alterar sua senha ou digite outro nome para adicionar um novo usuário:\n\n\n $usu\n" 0 0)
htpasswd /etc/squid3/squid_passwd "$sus"
if [ $? != 0 ]; then
dialog $tit --msgbox "Usuário não adicionado, verifique se a senha está correta e tente novamente." 0 0
else
dialog $tit --msgbox "Usuário adicionado/alterado com sucesso!" 0 0
squid3 -k reconfigure
fi
;;
2)
usu=$(cat /etc/squid3/squid_passwd|cut -d":" -f1|xargs -I@ echo "@ \n")
sus=$(dialog $tit --inputbox --stdout "\nSegue abaixo a lista dos usuários já existentes, Digite o nome de um deles para remover:\n\n\n $usu\n" 0 0)
grep "$sus" /etc/squid3/squid_passwd
if [ $? != 0 ]; then
dialog $tit --msgbox "Usuário não encontrado, verifique o nome e tente novamente." 0 0
else
sed -ri "s/$sus.*//" /etc/squid3/squid_passwd
dialog $tit --msgbox "Usuário removido com sucesso!" 0 0
squid3 -k reconfigure
fi
;;
3)
	break
;;
esac
else
	dialog $tit --yesno "\nA configuração do proxy autenticação fará com que o \
proxy transparente pare de funcionar, suas configurações não serão apagadas, apenas \
ficarão inativas.\nVocê pode reativar o proxy transparente na opção: Proxy Avançado > \
Ativar Proxy Autenticação.\n\nVocê tem certeza de que deseja ativar o proxy com autenticação?" 0 0
	if [ $? != 0 ]; then
		echo ""
	else
		sed -ri "s/http_port 3128 .*/http_port 3128/" /etc/squid3/squid.conf
		sed -ri "s/([#]?)*auth_param/auth_param/" /etc/squid3/squid.conf
		sed -ri "s/([#]?)*acl autentic/acl autentic/" /etc/squid3/squid.conf
		sed -ri "s/([#]?)*http_access allow autentic/http_access allow autentic/" /etc/squid3/squid.conf
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
done
