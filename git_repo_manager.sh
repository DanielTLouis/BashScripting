#!/usr/bin/env bash
# Git Repo Manager
# By Daniel Louis
# Created: 11/02/2026
# This Bash script will help manage the git repos installed on the local machine 

#Function to print the help menu
help(){
	echo "Git Repo Manager Help"
	echo "-------------------------"
    echo "use the alias 'grm' for commandline alias"
    echo
    echo "grm <option>"
    echo "-h,--help               		This help message"
    echo "-i,--install            		To install the script to be a permanent alias on the machine"
    echo "-u,--uninstall          		To uninstall the qcd previously installed"
    echo "No options will run the program"
}

#Function to install his to the bash terminal 
install(){
	echo "Installing Git Repo Manager"
	script_path=$(readlink -f "${BASH_SOURCE[0]}")
    if [ ! -d "$HOME/.local/bin" ]; then
        mkdir -p "$HOME/.local/bin"
    fi
    cp "$script_path" "$HOME/.local/bin"

    chmod +x "$HOME/.local/bin/git_repo_manager.sh"
    if grep -qE '^[[:space:]]*alias[[:space:]]+grm=' "$HOME/.bashrc"; then
        echo "The grm alias already exists."
    else
        if [ ! -d "$HOME/.local/share/applications" ]; then
            mkdir -p "$HOME/.local/share/applications"
        fi
        cat >> "$HOME/.bashrc" <<EOF
alias grm="$HOME/.local/bin/git_repo_manager.sh"
EOF
    fi
    source ~/.bashrc
}

#Function to uninstall already installed version 
uninstall(){
	echo "Uninstalling Git Repo Manager"
	rm "$HOME/.local/bin/git_repo_manager.sh"

	#TODO remove alias and cron 
    local bashrc="$HOME/.bashrc"
    if grep -qE '^[[:space:]]*alias[[:space:]]+grm=' "$bashrc"; then
        if sed -i '/^[[:space:]]*alias[[:space:]]\+grm=/d' "$bashrc"; then
            unalias grm 2>/dev/null
            echo "Git Repo Manager alias removed."
        else
            echo "Error: Failed to remove alias from .bashrc."
            return 1
        fi
    else
        echo "Git Repo Manager alias was not found in .bashrc."
        unalias grm 2>/dev/null
    fi
    unalias grm
    source ~/.bashrc
}

#Function that will check for any flags added to the function call 
check_flags(){
	case "$1" in 
		-h|--help)
			help
			exit 0
			;;
		-i|--install)
			install
			exit 0
			;;
		-u|--uninstall)
			uninstall
			exit 0
			;;
		*)
			return
			;;
	esac
}

#Function to view the commit history for a repo
view_commit_his(){
	local repo_path="$1"

    echo "Commit History: $(basename "$repo_path")"
    echo "---------------------------------------"

    if ! git -C "$repo_path" log -10 \
        --format="%h | %as | %an | %s"; then

        echo "Error: Unable to retrieve commit history."
        return 1
    fi
}

#Function to select what repo to print the defails for 
choose_repo(){
	while true; do
		echo "Select a repo to view the details for:"
		choice_list=()
		index=1
		for i in $1; do
			echo "$index - $i"
			choice_list+=("$i")
			((index+=1))
		done
		echo "0 - Return to menu"
		read input 

		if [[ "$input" == "0" ]]; then
			return 
		elif ! [[ "$input" =~ ^[0-9]+$ ]]; then
			echo "Please select an option from the list"
		elif (( input >= index )); then
			echo "Please select an option from the list"
		else
			if [ "$2" == "1" ];then
				view_repo_details "${choice_list[input-1]}"
			elif [ "$2" == "2" ]; then
				view_commit_his "${choice_list[input-1]}"
			fi
		fi
	done
}

#Function to select and print the details for a single repo 
view_repo_details() {
    local repo_path="$1"

    if ! git -C "$repo_path" rev-parse \
        --is-inside-work-tree &>/dev/null; then
        echo "Error: Invalid Git repository."
        return 1
    fi

    echo "=================================="
    echo "Repository: $(basename "$repo_path")"
    echo "=================================="

    echo "Location:"
    git -C "$repo_path" rev-parse --show-toplevel

    echo
    echo "Current Branch:"
    git -C "$repo_path" branch --show-current

    echo
    echo "Local Branches:"
    git -C "$repo_path" branch

    echo
    echo "Remote Repositories:"
    git -C "$repo_path" remote -v

    echo
    echo "Most Recent Commit:"
    git -C "$repo_path" log -1 \
        --format="Hash: %h%nAuthor: %an%nDate: %as%nMessage: %s"
}

#Function to automatically check for repo updates 
update(){
	echo "Fetching remote updates..."
    echo

    while IFS= read -r -d '' repo; do

        repo_path=$(dirname "$repo")
        repo_name=$(basename "$repo_path")

        echo "Repository: $repo_name"

        # Check whether the repository has remotes
        if [[ -z "$(git -C "$repo_path" remote)" ]]; then
            echo "No remote configured. Skipping."
            echo "-----------------------------"
            continue
        fi

        # Fetch updates from all configured remotes
        if git -C "$repo_path" fetch --all; then
            echo "Fetch completed successfully."
        else
            echo "Error: Failed to fetch updates."
        fi

        echo "-----------------------------"

    done < <(find "$HOME" -name ".git" -print0 2>/dev/null)
}

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

	check_flags "$1"

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
				echo "Repository Details: "
				choose_repo "$list" "1"
				input="r"
			;;
			"3")
				echo "Checking All Repository Statuses:"
				check_status "$list"
				input="r"
				;;
			"4")
				echo "Fetching Remote Updates"
				update 
				input="r"
				;;
			"5")
				echo "Viewing Commit History"
				choose_repo "$list" "2"
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