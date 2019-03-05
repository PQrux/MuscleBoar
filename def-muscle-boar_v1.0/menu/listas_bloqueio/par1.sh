#!/bin/bash
tit="--title MUSCLE_BOAR"
while true
do
	op=$(dialog $tit --menu "Este é o menu de configuração de listas de palavras, escolha uma das opções abaixo para realizar o bloqueio ou desbloquear algo: " 0 0 0 \
	1 "Palavras" \
	2 "Extensões" \
	3 "Domínios" \
	4 "IPs" \
	5 "Voltar" --stdout)
	case $op in
	1)
	while [ $? = 0 ]; do
		usu=$(cat /etc/squid3/block_list/block.txt|xargs -I@ echo "@ \n")
		sit=$(dialog $tit --menu "Escolha: " 0 0 0 \ 1 "Bloquear palavra" \ 2 "Remover palavra bloqueada" \ 3 "Listar Palavras bloqueadas" --stdout)
		if [ $sit = 1 ]; then
			bp=$(dialog --inputbox "DIGITE A PALAVRA QUE DESEJA BLOQUEAR.\nLista de palavras já bloqueadas:\n\n $usu" 0 0 --stdout)
			echo $bp >> /etc/squid3/block_list/block.txt
			squid3 -k reconfigure
		elif [ $sit = 2 ]; then
			rmp=$(dialog --inputbox "DIGITE A PALAVRA BLOQUEADA QUE DESEJA REMOVER.\nLista de palavras bloqueadas:\n\n $usu" 0 0 --stdout)
			sed -i "s/$rmp//" /etc/squid3/block_list/block.txt
			squid3 -k reconfigure
		elif [ $sit = 3 ]; then
			dialog $tit --msgbox "Lista de palavras bloqueadas:\n\n $usu" 0 0
		fi
		dialog $tit --yesno "Deseja Bloquear ou Remover alguma outra palavra?" 0 0
	done
	;;
	2)
	while [ $? = 0 ]; do
		usu=$(cat /etc/squid3/block_list/block-ext|xargs -I@ echo "@ \n")
		sit=$(dialog $tit --menu "Escolha: " 0 0 0 \ 1 "Bloquear extensão" \ 2 "Remover extensão bloqueada" \ 3 "Lista de extensões bloqueadas" --stdout)
			if [ $sit = 1 ]; then
			bp=$(dialog --inputbox "DIGITE A EXTENSÃO QUE DESEJA BLOQUEAR.\nLista de extensões bloqueadas:\n\n $usu" 0 0 --stdout)
			ext=".*(\.|-)$bp($|\?|\&)"
			echo "$ext" >> /etc/squid3/block_list/block-ext
			squid3 -k reconfigure
		elif [ $sit = 2 ]; then
			rmp=$(dialog --inputbox "DIGITE A EXTENSÃO BLOQUEADA QUE DESEJA REMOVER.\nLista de extensões bloqueadas:\n\n $usu" 0 0 --stdout)
			sed -i "s/.*[)]$rmp[(].*//" /etc/squid3/block_list/block-ext
			squid3 -k reconfigure
		elif [ $sit = 3 ]; then
			dialog $tit --msgbox "Lista de extensões bloqueadas:\n\n $usu" 0 0
		fi
		dialog $tit --yesno "Deseja Bloquear ou Remover alguma outra extensão?" 0 0
	done
	;;
	3)
	while [ $? = 0 ]; do
		usu=$(cat /etc/squid3/block_list/block-dmn|xargs -I@ echo "@ \n")
		sit=$(dialog $tit --menu "Escolha: " 0 0 0 \ 1 "Bloquear domínio" \ 2 "Remover domínio bloqueado" \ 3 "Lista de domínios bloqueados" --stdout)
			if [ $sit = 1 ]; then
			bp=$(dialog --inputbox "DIGITE A DOMÍNIO QUE DESEJA BLOQUEAR. Lista de domínios bloqueados:\n\n $usu" 0 0 --stdout)
			echo $bp >> /etc/squid3/block_list/block-dmn
			squid3 -k reconfigure
		elif [ $sit = 2 ]; then
			rmp=$(dialog --inputbox "DIGITE O DOMÍNIO BLOQUEADO QUE DESEJA REMOVER.\nLista de domínios bloqueados:\n\n $usu" 0 0 --stdout)
			sed -i "s/$rmp//" /etc/squid3/block_list/block-dmn
			squid3 -k reconfigure
		elif [ $sit = 3 ]; then
			dialog $tit --msgbox "Lista de domínios bloqueados:\n\n $usu" 0 0
		fi
		dialog $tit --yesno "Deseja Bloquear ou Remover algum outro domínio?" 0 0
	done
	;;
	4)
iptest ()
{
	ver=$(echo $bp |grep -E "([1-9])([0-9]?)\.([0-9])([0-9]?){2}\.([0-9])([0-9]?){2}\.([0-9])([0-9]?){2}")
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
	while [ $? = 0 ]; do
		usu=$(cat /etc/squid3/block_list/block-ip|xargs -I@ echo "@ \n")
		sit=$(dialog --menu "Escolha: " 0 0 0 \ 1 "Bloquear IP" \ 2 "Remover IP bloqueado" 3 "Lista de IPs bloqueados" --stdout)
			if [ $sit = 1 ]; then
			bp=$(dialog --inputbox "DIGITE O IP QUE DESEJA BLOQUEAR.\nLista de IPs bloqueados:\n\n $usu" 0 0 --stdout)
			xax=$(iptest)
			if [ "$xax" = "errado" ]; then
				dialog $tit --msgbox "O IP digitado é um IP inválido, tente novamente." 0 0
			else
				echo $bp >> /etc/squid3/block_list/block-ip
				squid3 -k reconfigure
			fi
		elif [ $sit = 2 ]; then
			bp=$(dialog --inputbox "DIGITE O IP BLOQUEADO QUE DESEJA REMOVER.\nLista de IPs bloqueados:\n\n $usu" 0 0 --stdout)
			xax=$(iptest)
			if [ "$xax" = "errado" ]; then
				dialog $tit --msgbox "O IP digitado é um IP inválido, tente novamente." 0 0
			else
				sed -i "s/$bp//" /etc/squid3/block_list/block-ip
				squid3 -k reconfigure
			fi
		elif [ $sit = 3 ]; then
			dialog $tit --msgbox "Lista de IPs bloqueados:\n\n $usu" 0 0
		fi
		dialog $tit --yesno "Deseja Bloquear ou Remover algum outro IP?" 0 0
	done
	;;
	5)
		break
	;;
	esac
done
