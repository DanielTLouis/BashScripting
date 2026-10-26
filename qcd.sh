#!/usr/bin/env bash
# Disk Usage
# By Daniel Louis
# Created: 10/26/2026
# This Bash script will run or install a Quick CD command to navigate to commonly used driectories set by the user 

#Might want to change this location / let the user move the config file 
config_file="$HOME/.qcd"

help(){
	echo "Quick Change Directory - help"
    echo "-------------------------"
    echo "use the alias 'qcd' for commandline alias"
    echo
    echo "qcd <option>"
    echo "-h,--help               		This help message"
    echo "-i,--install            		To install the script to be a perminate alias on the machine"
    echo "-U,--Uninstall          		To uninstall the qcd previously installed"
    echo "-a,--add <alias> <file path>  To add an alias that will perminately be stored"
    echo "-r,--remove <alias>           To remove a previously set alias"
    echo "-l,--list                     To list all alias for qcd"

}

add(){
	if [[ ! -f "$config_file" ]]; then
	    touch "$config_file" || {
	        echo "Error: Could not create $config_file" >&2
	        return 1
	    }
	fi 

	echo -e "adding new path and alias $2\n $3"
	if [ -d "$3" ];then
		if grep -qE "^$2=" "$config_file"; then
			echo "Alias alread saved to qcd, please choice another."
		else
			#Adding alias to config_file in patter alias=/path
			cat >> "$config_file" <<EOF 
$2=$3
EOF
			echo "Directory $3 with qcd alias $2 added."
			echo "Please use the following command"
			echo "qcd $2"
		fi
	else
		echo -e"The file path does not exist.\n Please check and try to add again."
	fi
}

remove(){
	echo "Removing alias $2"
	if [[ ! -f "$config_file" ]]; then
	    echo "Configuration File does not exist."
	    echo "Please add alias with the --add flag to continue using qcd"
	fi 

	if grep -qE "^$2=" "$config_file"; then
		sed -i "s/^$2=.*/ /" "$config_file"
		echo "Alias has been removed"
	else
		echo "Alias does not exist for qcd"
	fi

}

install(){
	echo "Insatlling"
}

uninstall(){
	echo "Uninstalling"
	echo "Removing configuration file"
	if [ -f "$HOME/.qdc" ]; then 
		rm "$HOME/.qcd"
	fi
}

lookup(){
	config_file="$HOME/.qcd"

	shortcut_exists() {
	    local key="$1"

	    [[ -f "$config_file" ]] || return 1

	    grep -qE "^${key}=" "$config_file"
	}

	# Example usage
	if shortcut_exists "projects"; then
	    echo "Shortcut exists."
	else
	    echo "Shortcut does not exist."
	fi
}

qcd(){
	# Define the cases for the inputs 
	case "$1" in 
		-h|--help)
			help
			;;
		-a|--add)
			add "$@"
			;;
		-r|--remove)
			remove "$@"
			;;
		-i|--install)
			install
			;;
		-u|--uninstall)
			uninstall
			;;
		-l|list)
			if [[ -f "$config_file" ]]; then
				cat "$HOME/.qcd" || {
					echo "Error: Could not open $config_file" >&2
	        		return 1
				}
			fi
			;;
		*)
			lookup 
			# The supplied argument was not one of the supported keys
 			echo "qcd: unknown key '$1'"
 			retun -1
 			;;
 	esac

 	# Helpfully print the current directory name to indicate where you are
 	pwd
}


#qcd "$@"
qcd --add home /home/