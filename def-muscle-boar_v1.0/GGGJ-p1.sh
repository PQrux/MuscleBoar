#!/bin/bash
################################## PADRÕES ###########################################
clear
pacote="squid3 apache2 dialog srg"
ipteste="10.107.132.20"
black="\033[m"
blue="\033[0;44m"
red="\033[0;41m"

################################## INICIALIZAÇÃO ######################################
echo -e $blue"\n\nInicializando o Assistente de configuração do Squid...\n\n"$black
dpkg -l |grep squid > /dev/null
a1=$?
dpkg -l |grep dialog > /dev/null
a2=$?
dpkg -l |grep apache > /dev/null
a3=$?
dpkg -l |grep srg > /dev/null
a4=$?
if [ 0 != $a1 -a $a2 -a $a3 -a $a4 ]; then
	printf $red"Algumas dependências não estão instaladas!!! Deseja iniciar a instalação agora? (s/n).\n:"$black
	read want
	case $want in
	n|N|nao|Nao|Não|não|NAO|NÃO)
		echo -e $red"Impossível prosseguir devido à não existencia\nde algumas dependencias na maquina... Saindo do programa..."$black
	exit
	;;
	s|S|SIM|Sim|sim)
		echo -e $blue"\n\nInicializando processo de instalação..."
		echo -e "Testando conectividade com o repositório..."$black
		apt-get update > /dev/null 2>/dev/null
		if [ $? != 0 ]; then
			printf $blue"Sem conectividade com o repositório, deseja\nque o assistente de instalação configure o repositório automaticamente?(s/n)\n:"$black
			read repos
			case $repos in
			n|N|nao|Nao|Não|não|NAO|NÃO)
				echo -e $red"Impossível prosseguir devido à não existencia de algumas dependencias na máquina... Saindo do programa..."$black
				exit
			;;
			s|S|SIM|Sim|sim)
				pin=$(ping $ipteste -c 1 | grep received|cut -d" " -f4)
				case $pin in
				1)
					echo ""
				;;
				*)
					echo -e $blue"Configurando interfaces de rede..."$black
					echo -e "source /etc/network/interfaces.d/*\nauto lo\niface lo inet loopback\n\nauto eth0\nallow-hotplug eth0\niface eth0 inet dhcp" > /etc/network/interfaces
					service networking restart
					pin=$(ping $ipteste -c 1 | grep received|cut -d" " -f4)
					case $pin in
					1)
						echo ""
					;;
					*)
						echo -e $red"Impossível prosseguir devido à falta de conectividade com o repositório, reveja suas configurações de rede na máquina virtual e tente novamente..."$black
						exit
					;;
					esac
				;;
				esac
				echo -e $blue"Iniciando processo de configuração do repositório..."$black
				mkdir /mnt/repo
				mount -t nfs 10.107.132.20:/home/celso/FTP/Linux/DEBIAN8.5 /mnt/repo
				seq 8|xargs -I@ echo "deb file:/mnt/repo/dvd@ jessie main contrib" > /etc/apt/sources.list
				apt-get update > /dev/null 2>/dev/null
				if [ $? != 0 ]; then
					echo -e $red"Impossível prosseguir devido à falta de conectividade com o repositório, reveja suas configurações de rede na máquina virtual e tente novamente..."$black
					exit
				else
					echo -e $blue"Conectado ao repositório... Iniciando processo de instalação do squid..."$black
				fi
			;;
			*)
				echo -e $red"Opção inválida... Saindo do programa..."$black
				exit
			;;
			esac
		else
			echo -e $blue"Conectado ao repositório... Iniciando processo de instalação do squid..."$black
		fi
		apt-get install $pacote -y --force-yes
	;;
	*)
		echo -e $red"Opção inválida... Saindo do programa..."$black
		exit
	;;
	esac
else
echo -e $blue"Concluído..."$black
fi
############################### PRE-CONFIGURAÇÃO ###################################################
####################################################################################
iptest ()
{
	ver=$(echo $cep |grep -E "([1-9])([0-9]?)\.([0-9])([0-9]?){2}\.([0-9])([0-9]?){2}\.([0-9])([0-9]?){2}")
	if [ -z $ver ]
	then
		echo "errado"
	else
		full=255
		ver2=$(echo $ver|cut -d\. -f1)
		ver3=$(echo $ver|cut -d\. -f2)
		ver4=$(echo $ver|cut -d\. -f3)
		ver5=$(echo $ver|cut -d\. -f4)
		if [ $full -lt $ver2 ]; then
			echo "errado"
		else
			if [ $full -lt $ver3 ]; then
				echo "errado"
			else
				if [ $full -lt $ver4 ]; then
					echo "errado"
				else
					if [ $full -lt $ver5 ]; then
						echo "errado"
					else
						echo "certo"
					fi
				fi
			fi
		fi
	fi
}
###############################################################################
masctest ()
{
	ver=$(echo $cep2|grep -E "((254\.|252\.|248\.|240\.|224\.|192\.|128\.|0\.)0\.0\.0)|(255\.(254\.|252\.|248\.|240\.|224\.|192\.|128\.|0\.)0\.0)|(255\.255\.(254\.|252\.|248\.|240\.|224\.|192\.|128\.|0\.)0)|(255\.255\.255\.(254|252|248|240|224|192|128|0))")
	if [ -z $ver ]
	then
		echo "errado"
	else
		echo "certo"
	fi
}
###############################################################################
tit='--colors --title MUSCLE_BOAR'
titr='--colors --title \Z1MUSCLE_BOAR'
##############################
dialog $tit --msgbox "\n              BEM-VINDO AO MUSCLE BOAR v1.0 \
\n\nO programa MUSCLE BOAR foi desenvolvido por alunos \
da turma R3M da escola SENAI Prof. Vicente Amato como metodo de obtenção de nota \
para a matéria Programação para Redes \
administrada pelo Prof. Fernando Leonid." 0 0
if [ -f "/etc/boar/certificado.mb" ]; then
	echo "que bom" > /dev/null
else
	dialog $titr --yesno "\nO SISTEMA DETECTOU QUE ESTA É A SUA PRIMEIRA VEZ UTILIZANDO O MUSCLE BOAR, PORTANTO SERÁ \
	NECESSÁRIA A PRÉ-CONFIGURAÇÃO DE ALGUNS COMPONENTES DO MUSCLE BOAR.\n
	ESTE PROCESSO IRÁ RESETAR O ARQUIVO /etc/squid3/squid.conf, PORÉM SERÁ CRIADA UMA CÓPIA DE \
	SEGURANÇA SALVA COMO /etc/squid3/squid.conf.bkp\n\n
	VOCÊ CONCORDA QUE O MUSCLE BOAR REALIZE AS MUDANÇAS ACIMA?" 0 0
	if [ $? != 0 ]; then
		dialog $titr --msgbox "PRÉ-CONFIGURAÇÃO NÃO CONCLUÍDA!!\n\nSAINDO DO MUSCLE BOAR..." 0 0
		exit
	else
		mkdir /etc/boar
		cd /
		arc=$(find / -type d -name def-muscle-boar_v1.0|head -1)
		cd $arc
		cp -r ./* /etc/boar/
		touch /etc/boar/certificado.mb
		cd /etc/boar
		mv /etc/srg/srg.conf /etc/srg/srg.conf.bkp
		cp srg.conf /etc/srg/srg.conf
		#sed -i "s/# e.g. log_file/log_file/" /etc/srg/srg.conf
		#sed -ri "s/# e.g. output_dir \"\/var\/www\/srg_reports\"/output_dir \"\/var\/www\/html\"/" /etc/srg/srg.conf
		name=$(hostname)
		mv /etc/squid3/squid.conf /etc/squid3/squid.conf.bkp
		mkdir /etc/squid3/block_list
		cp block_list/* /etc/squid3/block_list/
		touch /etc/squid3/squid_passwd
		touch /etc/squid3/squid.conf
		cat squid.conf|sed -r "s/%NOME%/$name/" >/etc/squid3/squid.conf
		rm /var/www/html/index.html
		echo "0-59/5  * * * * srg" > /var/spool/cron/crontabs/root
		echo -e "#!/bin/bash\n/etc/boar/GGGJ-p1.sh" > /usr/local/sbin/muscleboar
		chmod +x /usr/local/sbin/muscleboar
		chmod -R +x /etc/boar/*
		srg
	fi
fi
####################################################################################
testip=""
while [ -z $testip ]; do
	testip=$(ifconfig eth1 2>/dev/null| grep "inet"|head -1|cut -d" " -f13)
	if [ -z $testip ]
	then
		dialog $tit --msgbox "Para o funcionamento do Muscle Boar e do proxy squid, \
		é importante que seja configurada uma segunda interface de rede, portanto, esta \
		configuração será realizada na próxima página." 0 0
		mii-tool eth1
		if [ $? != 0 ]; then
			dialog $titr --msgbox "SEGUNDA PLACA DE REDE NÃO ENCONTRADA\n\nO muscle \
boar não poderá realizar a configuração de IP da segunda interface de rede \
pois, a mesma não existe. Para tentar esta etapa novamente insira uma nova \
placa de rede e tente novamente.\n\nPulando processo..." 0 0
			testip=2132
		else
			cep=$(dialog $tit --stdout --inputbox "Por favor informe o endereço IP:" 0 0)
			xax=$(iptest)
			while [ $xax = "errado" ]
			do
				cep=$(dialog $titr --stdout --inputbox "ENDEREÇO IP INCORRETO\n\n \
					Por favor informe o endereço IP novamente" 0 0)
				xax=$(iptest)
			done
			####
			cep2=$(dialog $tit --stdout --inputbox "Por favor informe a máscara de sub-rede:" 0 0)
			xax2=$(masctest)
			while [ $xax2 = "errado" ]
			do
				cep2=$(dialog $titr --stdout --inputbox "MASCARA DE SUB-REDE INCORRETA\n\n \
					Por favor informe a máscara de sub-rede novamente novamente" 0 0)
				xax2=$(masctest)
			done
			###
			echo -e "\nauto eth1\nallow-hotplug eth1\niface eth1 inet static\naddress $cep\nnetmask $cep2" >> /etc/network/interfaces
			/etc/init.d/networking restart
		fi
	else
		echo "eth1 ok"
	fi
done
testmasc=$(ifconfig eth1 2>/dev/null| grep "inet"|head -1|cut -d":" -f4)
pt=$(echo $testip|cut -d"." -f1,2,3)
pt2=$(echo $testip|sed -r "s/(..?.?[.]){2}.?[.]..?.?/$pt.0/")
pt3="$pt2/$testmasc"
echo $pt3
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -s $pt3 -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -s $pt3 -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3128
#iptables -t nat -d $pt3 -A PREROUTING -p tcp --dport 3128 -j REDIRECT --to-port 80
(
service squid3 restart &
sleep 3
qq=$(ps aux|grep "/etc/init.d/squid3 stop"|grep -v "grep")
pct=0
q1=2
while [ $pct -lt 100 ]; do
	pct=$(( $pct + 1 ))
	if [ $pct -lt 35 ]; then
		frase="Olá senhor usuário ROOT!! Bom-dia! (Este script realmente sabe quando dar bom dia, boa tarde/noite!)"
	elif [ $pct -lt 70 ];then
		frase="haha! Trollei!\n deu preguiça de ensiná-lo à fazer isso \o/"
	else
		frase="Finalizando...\n"
	fi
	qq=$(ps aux|grep "/etc/init.d/squid3 stop"|grep -v "grep")
	if [ -z "$qq" ]; then q1=$(($q1+92)); fi
	echo "XXX"
	echo "$frase \n\n\nO Muscle Boar está sendo iniciado..."
	echo "XXX"
	echo "$pct"
	sleep .4
	if [ $q1 -eq 94 ]
	then
		pct=90
	fi
done
)| dialog --title "MUSCLE BOAR" --gauge "\n\n\n\nO Muscle Boar está sendo iniciado..." 10 60 0
squid3 -k reconfigure > /dev/null 2> /dev/null
squid3 -k reconfigure > /dev/null 2> /dev/null
(while true; do sleep 5m; srg 2>/dev/null; done) &
/etc/boar/menu/Muscle_Boar.sh
