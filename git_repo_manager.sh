#!/usr/bin/env bash
# Git Repo Manager
# By Daniel Louis
# Created: 11/02/2026
# This Bash script will help manage the git repos installed on the local machine 

git_repo_manager(){
	echo "Managing Git Repos"

	echo "Select a option: "
	echo "1. exit"
	read input

	while true; do 

		case "$input" in 
			"1")
				exit 0
				;;
			*) 
				echo "please type the number alone from your selection"
				;;
		esac
	done 
}

git_repo_manager