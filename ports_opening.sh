#!/bin/bash
# Options
. <(wget -qO- https://raw.githubusercontent.com/f5nodes/logo/main/colors.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/f5nodes/logo/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script opens specified ports"
		echo
		echo -e "${C_LGn}Usage${RES}: script ${C_LGn}[OPTIONS]${RES} ${C_LGn}[ARGUMENTS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h, --help  show the help page"
		echo
		echo -e "${C_LGn}Arguments${RES} - any ports to open separated by spaces"
		echo
		return 0
		;;
	*|--)
		break
		;;
	esac
done

# Functions
main() {
	echo -e "${C_LGn}Port(s) opening...${RES}"
	if sudo ufw status | grep -q "Status: active"; then
		sudo ufw allow 22
		for open_this_port in "$@"; do
			sudo ufw allow "$open_this_port"
		done
	else
		if ! dpkg --get-selections | grep -qP "(?<=iptables-persistent)([^de]+)(?=install)"; then
			echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
			echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
			sudo apt install iptables-persistent -y
		fi
		for open_this_port in "$@"; do
			sudo iptables -I INPUT -p tcp --dport "$open_this_port" -j ACCEPT
		done
		sudo netfilter-persistent save
	fi
	unset open_this_port
	echo -e "${C_LGn}Done!${RES}"
}

# Actions
main