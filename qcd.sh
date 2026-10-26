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
	echo "Insatlling qcd"
	#Add alias to call 'qcd'
    script_path=$(readlink -f "${BASH_SOURCE[0]}")
    if [ ! -d "$HOME/.local/bin" ]; then
        mkdir -p "$HOME/.local/bin"
    fi
    cp "$script_path" "$HOME/.local/bin"
    chmod +x "$HOME/.local/bin/qcd.sh"

   local bashrc="$HOME/.bashrc"

    if grep -qE '^[[:space:]]*qcd[[:space:]]*\(\)' "$bashrc"; then
        echo "The qcd function already exists in .bashrc."
    else
        cat >> "$bashrc" <<'EOF'

# Quick Change Directory function
qcd() {
    source "$HOME/.local/bin/qcd.sh"
    command_qcd "$@"
}
EOF
        echo "QCD function added to .bashrc"
    fi

    #Create Config File
    if [[ ! -f "$config_file" ]]; then
	    touch "$config_file" || {
	        echo "Error: Could not create $config_file" >&2
	        return 1
	    }
	fi 

}

uninstall(){
	echo "Uninstalling qcd"
	echo "Removing configuration file"
	if [ -f "$HOME/.qcd" ]; then 
		rm "$HOME/.qcd"
	else 
		echo "No configuration file found. Moving on."
	fi

	echo "Removing source file"
	if [ -f "$HOME/.local/bin/qcd.sh" ]; then
		rm "$HOME/.local/bin/qcd.sh"
	else
		echo "Source File not found. Moving on."
	fi

	echo "Removing alias"
	echo "Removing qcd function"

	local bashrc="$HOME/.bashrc"

	if grep -qE '^[[:space:]]*qcd[[:space:]]*\(\)[[:space:]]*\{' "$bashrc"; then
	    if sed -i '/^[[:space:]]*qcd[[:space:]]*()[[:space:]]*{/,+4d' "$bashrc"; then
	        unset -f qcd
	        echo "Quick Change Directory function removed."
	    else
	        echo "Error: Failed to remove qcd function from .bashrc." >&2
	        return 1
	    fi
	else
	    echo "Quick Change Directory function was not found in .bashrc."
	    unset -f qcd
	fi

}


shortcut_exists() {
    local key="$1"

    [[ -f "$config_file" ]] || return 1

    grep -qE "^${key}=" "$config_file"
}


command_qcd(){
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
		-l|--list)
			if [[ -f "$config_file" ]]; then
				cat "$HOME/.qcd" || {
					echo "Error: Could not open $config_file" >&2
	        		return 1
				}
			fi
			;;
		*)
			if shortcut_exists "$1"; then
				key="$1"
			    path=$(awk -F= -v key="$key" '$1 == key {print substr($0, index($0, "=") + 1); exit}' "$config_file")
			    cd -- "$path" || return 1
			else
				if [[ $# -eq 0 ]]; then
					cd $HOME
				else
				    # The supplied argument was not one of the supported keys
	 				echo "qcd: unknown key '$1'"
	 				retun -1
 				fi
			fi
			# Helpfully print the current directory name to indicate where you are
 			echo "Curent Directory:"
 			pwd
 			;;
 	esac

}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    command_qcd "$@"
fi
