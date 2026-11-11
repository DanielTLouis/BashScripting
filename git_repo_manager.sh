#!/usr/bin/env bash
# Git Repo Manager
# By Daniel Louis
# Created: 11/02/2026
# This Bash script will help manage the git repos installed on the local machine 

#Funciton to make sure git is installed before running the applicaiton 
check_git(){
	if ! command -v git &>/dev/null; then
        echo "Error: Git is not installed."
        echo "Install Git using: sudo apt install git"
        return 1
    fi

    echo "Git is installed."
    git --version
    return 0
}

#Function to print the choices for the user to select 
choices(){
	echo "Select a option: "
	echo "1) List Repositories"
	echo "2) View Repository Details"
	echo "3) Check All Repository Statuses"
	echo "4) Fetch Remote Updates"
	echo "5) View Commit History"
	echo "6) Exit"
}

git_repo_manager(){
	echo "Managing Git Repos"

	if ! check_git; then
		exit 1 
	fi 

	choices 
	
	read input

	while true; do 

		case "$input" in 
			"1")
				echo "List Repositories"

				input="r"
			;;
			"2")
				echo "View Repository Details"
				input="r"
			;;
			"3")
				echo "Check All Repository Statuses"
				input="r"
				;;
			"4")
				echo "Fetch Remote Updates"
				input="r"
				;;
			"5")
				echo "View Commit History"
				input="r"
				;;
			"6")
				exit 0
				;;
			"r")
				choices
				read input
				;;
			*) 
				echo "please type the number alone from your selection"
				read input
				;;
		esac
	done 
}

git_repo_manager