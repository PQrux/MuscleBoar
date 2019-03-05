#!/bin/bash
#Script criado por Guilherme Correia, Guilherme NBeubaner, Guilherme Frutuoso e Edilson Júnior.
#Menu para configurações básicas e avançadas para o Squid

while true
do
tit="Muscle_Boar"
actornot=$(service squid3 status | grep "Active" | grep "dead")
if [ -z $actornot ]; then opt1="Desligar"; else opt1="Ligar"; fi
opcao=$(dialog --title "$tit" --stdout --menu "\n\nInforme A opção para configurar seu Proxy:" 0 0 0 \
	1 "$opt1" \
	2 'Lista De Bloqueio' \
	3 'Proxy Avançado' \
	4 'Restaurar Padrão' \
	5 'Sobre os Desenvolvedores' \
	6 'Sair' )

case $opcao in

	1)
			if [ $opt1 = "Desligar" ]; then
			dialog --title "$tit" --yesno "Se você desativar o Squid, as máquinas na \
			rede interna não terão acesso à rede externa. Você tem certeza que quer realizar essa operação?" 0 0
			/etc/boar/menu/lig/desligar.sh

			else
				/etc/boar/menu/lig/ligar.sh
			fi
	;;

	2) /etc/boar/menu/listas_bloqueio/par1.sh
	;;
	3) while true
		do
		actornot2=$(grep intercept /etc/squid3/squid.conf)
		if [ -z $actornot2 ]; then opt2="Configurar"; else opt2="Ativar"; fi

		dialog --title "$tit" --msgbox "Você está entrando em Proxy Avançado, Aqui você terá \
		configurações como: Proxy Transparente e Autenticação" 0 0

		PA=$(dialog --title "$tit" --stdout --menu "\n\nInforme a Opção de Proxy Avançado:" 0 0 0 \
			1 "Ativar o Proxy Transparente" \
			2 "$opt2 Proxy de Autenticação" \
			3 "Sair" )
		case $PA in
		1) /etc/boar/menu/proxy_avancado/proxy_t/proxy_t.sh
		;;
		2) /etc/boar/menu/proxy_avancado/proxy_a/proxy_a.sh
		;;
		3) break
		esac
		done
	;;
	4)	/etc/boar/menu/restaurar_padrao/default.sh
	;;

	5)
		dialog --title $tit --msgbox "\n              BEM-VINDO AO MUSCLE BOAR v1.0 \
\n\nO programa MUSCLE BOAR foi desenvolvido por alunos \
da turma R3M da escola SENAI Prof. Vicente Amato como metodo de obtenção de nota \
para a matéria Programação para Redes \
administrada pelo Prof. Fernando Leonid.\n\n\n \
 Este programa foi criado por: \n \
Edilson Junior \n	 Proxy de Autenticação e Design\n \
Guilherme Correia \n	 Design de Menus\n \
Guilherme Frutuoso \n	 Lista de Bloqueios e Design\n \
Guilherme Neubaner \n	 Instalação/Pré-Configuração e Restauração\n " 0 0

	;;

	6)	dialog --title $tit --infobox "Xau!" 0 0
		exit
	;;
esac

done
