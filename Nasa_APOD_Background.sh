#!/usr/bin/env bash
# NASA APOD Background 
# By Daniel Louis
# Created: 11/02/2026
# This Bash script will set the NASA APOD to your Desktop Background and will do it daily if installed

NASA_APOD(){

	# Define the cases for the inputs 
	case "$1" in 
		-h|--help)
			help
			;;
		-i|--install)
			;;
		-u|--uninstall)
			;;
		*)
			echo "Set APOD to Desktop Background"
			if [ ! -d "$HOME/.APOD_IMAGE/" ]; then 
				mkdir -p "$HOME/.APOD_IMAGE/"
			fi

			;;
	esac


}

NASA_APOD "$@"