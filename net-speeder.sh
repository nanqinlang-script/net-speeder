#!/bin/bash
Green_font="\033[32m" && Red_font="\033[31m" && Font_suffix="\033[0m"
Info="${Green_font}[Info]${Font_suffix}"
Error="${Red_font}[Error]${Font_suffix}"
echo -e "${Green_font}
#======================================
# Project: net-speeder
# Version: 1.0
# Author: nanqinlang
# Blog:   https://www.nanqinlang.com
# Github: https://github.com/nanqinlang
#======================================${Font_suffix}"


#check system
check_system(){
	cat /etc/issue | grep -q -E -i "debian" && release="debian"

	if [[ "${release}" = "debian" ]]; then
		echo -e "${Info} system is debian "
		else echo -e "${Error} not support!" && exit 1
	fi
}

#check root
check_root(){
	if [[ "`id -u`" = "0" ]]; then
	echo -e "${Info} user is root"
	else echo -e "${Error} must be root user" && exit 1
	fi
}

#check ovz
check_ovz(){
	apt-get install virt-what -y
	virt=`virt-what`
}

#required workplace directory
directory(){
	[[ ! -d /home/net-speeder ]] && mkdir -p /home/net-speeder
	cd /home/net-speeder
}

install(){
	check_system
	check_root
	directory

	apt-get update && apt-get install build-essential libnet1-dev libpcap0.8-dev -y
	wget https://raw.githubusercontent.com/nanqinlang/net-speeder/master/net-speeder.c

	check_ovz
	if [[ "${virt}" = "openvz" ]]; then
		echo -e "${Info} virt is OpenVZ " && gcc -O2 -o net-speeder net-speeder.c -lpcap -lnet $1 -DCOOKED
	elif [[ "${virt}" = "kvm" || "${virt}" = "xen" ]]; then
		echo -e "${Info} virt is ${virt} " && gcc -O2 -o net-speeder net-speeder.c -lpcap -lnet $1
	else
		echo -e "${Error} not support virt " && exit 1
	fi
	
	if [[ -f net-speeder ]]; then
		echo -e "${Info} make process finished"
	else
		echo -e "${Error} make process failed, please check!" && exit 1
	fi
	
	start
}

start(){
	check_system
	check_root
	directory
	check_ovz
	if [[ "${virt}" = "openvz" ]]; then
		echo -e "${Info} virt is OpenVZ " && nohup ./net-speeder venet0 "ip" &
	elif [[ "${virt}" = "kvm" || "${virt}" = "xen" ]]; then
		echo -e "${Info} virt is ${virt}" && nohup ./net-speeder eth0 "ip" &
	else
		echo -e "${Error} not support virt " && exit 1
	fi
	
	status
}

status(){
	pid=`ps -ef|grep "net-speeder"|grep -v "grep"|awk '{print $2}'`
	if [[ -z ${pid} ]]; then
		echo -e "${Error} net-speeder not running, please check!" && exit 1
		else echo -e "${Info} net-speeder is running"
	fi
}

uninstall(){
	killall net-speeder
	rm -rf /home/net-speeder
	echo -e "${Info} netspeeder is uninstalled "
}

#${command}
command=$1
if [[ "${command}" = "" ]]; then
	echo -e "${Info}command not found, usage: ${Green_font}{ install | start | uninstall }${Font_suffix}" && exit 0
else
	command=$1
fi
case "${command}" in
	 install)
	 install
	 ;;
	 start)
	 start
	 ;;
	 status)
	 status
	 ;;
	 uninstall)
	 uninstall
	 ;;
esac
