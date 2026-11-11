#!/usr/bin/env bash
# Git Repo Manager
# By Daniel Louis
# Created: 11/02/2026
# This Bash script will help manage the git repos installed on the local machine 

#Function to check the status of all github repos 
check_status(){
	echo "Checking all Git repositories..."
    echo

    echo "Status Meaning: "
    echo
    echo "Symbol	Meaning"
	echo " M	      Modified file, not staged"
	echo "M	          Modified file, staged"
	echo "??	      Untracked file"
	echo "A	          New file staged for commit"
	echo " D	      Deleted file, not staged"

	while IFS= read -r -d '' repo; do

    	NM=0
		M=0
		QQ=0
		A=0
		D=0

        repo_path=$(dirname "$repo")
        repo_name=$(basename "$repo_path")

        echo "Repository: $repo_name"

        git -C "$repo_path" status --short
        response=$(git -C "$repo_path" status --short)
        while IFS= read -r line; do
		    symbol="${line:0:2}"
		    file_path="${line:3}"

		    if [[ "$symbol" == " M" ]]; then 
		    	((NM+=1))
		    elif [[ "$symbol" == "M " ]]; then
		    	((M+=1))
		    elif [[ "$symbol" == "??" ]]; then
		    	((QQ+=1))
		    elif [[ "$symbol" == "A " ]]; then
		    	((A+=1))
		    elif [[ "$symbol" == " D" ]]; then
		    	((D+=1))
		    fi
		done <<< "$response"

		echo
		echo "Repository Change Summary:"
		echo "Modified (Unstaged): $NM, Modified (Staged): $M, Untracked Files: $QQ, Added (Staged): $A, Deleted (Unstaged): $D"

        echo "-----------------------------"

    done < <(find "$HOME" -name ".git" -print0 2>/dev/null)
}

#Fuinciton to list the git repos 
list_repos(){
	#list=$(find "$HOME" -name ".git" -print 2>/dev/null)

	for i in $1; do
		repo_name=$(basename "$(dirname "$i")")
		echo "    Repo Name: $repo_name"
		echo "    Path: $i"
		echo 
	done
}

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

#Main driver function 
git_repo_manager(){
	echo "Managing Git Repos"

	if ! check_git; then
		exit 1 
	fi 
	list=$(find "$HOME" -name ".git" -print 2>/dev/null)

	choices 
	
	read input

	while true; do 

		case "$input" in 
			"1")
				echo "List of all Repositories: "
				list_repos "$list" 
				input="r"
			;;
			"2")
				echo "View Repository Details"
				input="r"
			;;
			"3")
				echo "Checking All Repository Statuses:"
				check_status "$list"
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

#Calling the driver function 
git_repo_manager "$@" 