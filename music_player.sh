#!/usr/bin/env bash
# Terminal Music Player
# By Daniel Louis
# Created: 11/13/2026
# This Bash script will play an audio clip within the terminal with a visual progression bar 

config_file="$HOME/.music_player/.mus_pla_config"
play_lists="$HOME/.music_player/.play_list"
config_dir="$HOME/.music_player/"
dir="$HOME/Music"

songs_found(){
    local song_count
    song_count=$(find "$dir" -type f \( \
    -iname "*.mp3" -o \
    -iname "*.flac" -o \
    -iname "*.wav" -o \
    -iname "*.ogg" \
\) | wc -l)

    echo "$song_count"
}

update_dir(){
        #Check and add config doc if it does not exist
    if [[ ! -f "$config_file" ]]; then
        touch "$config_file" || {
            echo "Error: Could not create $config_file" >&2
            return 1
        }
    fi

    echo "Current Music Directory: $dir"

    read -r -p "Enter new music directory: " input || return 1


    while true; do

         #check if the new directory is the old one 
        if [[ -z "$input" ]]; then
            echo "No changes made."
            return 0
        fi

        # Expand ~/Music if entered
        if [[ "$input" == "~/"* ]]; then
            input="$HOME/${input#\~/}"
        fi
        if [[ ! -d "$input" ]]; then
            echo -e "Directory Does not exist, please enter an existing directory or type \"Exit\""
            echo -n "Please Enter a new directory: "
            read input
        elif [[ "$input" == "Exit" || "$input" == "exit" ]]; then
            return 0
        else
            echo "Setting new directory"
            key="dir"
            new_dir=$(cd -- "$input" && pwd -P) || return 1
            sed -i "s|^${key}=.*|${key}=${new_dir}|" "$config_file"

            echo "Directory has been updated to $new_dir"
            return 0
        fi
    done
}

#Adds the config files 
add(){
    #Check and add config directory 
    if [[ ! -d "$config_dir" ]]; then
        mkdir -p "$config_dir" || {
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
       echo "dir=$dir" > "$config_file" || {
            echo "Error: Could not write to $config_file" >&2
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

    while true; do

        ####
        #Print what the Music Directory is: ~/Music by default 
        if [[ ! -f "$config_file" ]]; then
            echo "Music Directory: $HOME/Music"
        else 
            key="dir"
            dir=$(awk -F= -v key="$key" '$1 == key {print substr($0, index($0, "=") + 1); exit}' "$config_file")
            echo "Music Directory: $dir"
        fi
        #Songs Found: 24
        number=$(songs_found)
        echo "Songs Found: $number"
        ####

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
