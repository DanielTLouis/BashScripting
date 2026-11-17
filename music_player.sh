#!/usr/bin/env bash
# Terminal Music Player
# By Daniel Louis
# Created: 11/13/2026
# This Bash script will play an audio clip within the terminal with a visual progression bar 

config_file="$HOME/.music_player/.mus_pla"
play_lists="$HOME/.music_player/.play_list"
dir="$HOME/.music_player/"
music_directory="$HOME/Music"

update_dir(){
    
}

#Adds the config files 
add(){
    #Check and add config directory 
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || {
            echo "Error: Could not create $dir" >&2
            return 1
        }
    fi
    #Check and add config doc if it does not exist
    if [[ ! -f "$config_file" ]]; then
        touch "$config_file" || {
            echo "Error: Could not create $config_file" >&2
            return 1
        }
    fi
    #Check and add the Play List file that will save playlists 
    if [[ ! -f "$play_lists" ]]; then
        touch "$play_lists" || {
            echo "Error: Could not create $play_lists" >&2
            return 1
        }
    fi
}

play(){
    width=${width:-60}
    divider=$(printf '%*s\n' "$width" '' | tr ' ' '=')
    echo "$divider"
	echo "       Bash Music Player       "
	echo "$divider"

    add

    ####
    #Print what the Music Directory is: ~/Music by default 
    if [[ ! -f "$config_file" ]]; then
        echo "Music Directory: $HOME/Music"
    else 
        ##TODO make dir = config file
        key="dir"
        dir=$(awk -F= -v key="$key" '$1 == key {print substr($0, index($0, "=") + 1); exit}' "$config_file")
        echo "Music Directory: $dir"
    fi
    #Songs Found: 24
    ####

    while true; do
        echo "1) List Songs"
        echo "2) Play Song"
        echo "3) Play Random Song"
        echo "4) Create Playlist"
        echo "5) View Playlists"
        echo "6) Shuffle Playlist"
        echo "7) Play Playlist"
        echo "8) Change Music Directory"
        echo "9) Exit"

        echo -n "Select an option:"
        read input
        case "$input" in 
            1)
                echo "Listing Songs"
                ;;
            2)
                echo "Play Song"
                ;;
            3) 
                echo "Play Random Song"
                ;;
            4)
                echo "Create Playlist"
                ;;
            5)
                echo "View Playlists"
                ;;
            6) 
                echo "Shuffle Playlist"
                ;;
            7) 
                echo "Play Playlist"
                ;;
            8) 
                echo "Change Music Directory"
                update_dir "$@"
                ;;
            9)
                exit 0
                ;;
            *) 
                echo "Please select from the list."
                ;;
        esac
    done
}

play "$@"
