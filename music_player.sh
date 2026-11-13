#!/usr/bin/env bash
# Terminal Music Player
# By Daniel Louis
# Created: 11/13/2026
# This Bash script will play an audio clip within the terminal with a visual progression bar 

play(){
    width=${width:-60}
    divider=$(printf '%*s\n' "$width" '' | tr ' ' '=')
    echo "$divider"
	echo "       Bash Music Player       "
	echo "$divider"

    while true; do
        echo "1) List Songs"
        echo "2) 2) Play Song"
        echo "3) Play Random Song"
        echo "4) Create Playlist"
        echo "5) View Playlists"
        echo "6) Shuffle Playlist"
        echo "7) Play Playlist"
        echo "8) Exit"

        echo -n "Select an option:"
        read input

    done

    ####
    #Music Directory: ~/Music
    #Songs Found: 24

    #1) List Songs
    #2) Play Song
    #3) Play Random Song
    #4) Create Playlist
    #5) View Playlists
    #6) Shuffle Playlist
    #7) Stop Playback
    #8) Exit

    #Select an option: _
    ####
}

play "$@"
