#!/usr/bin/env bash
# NASA APOD Background 
# By Daniel Louis
# Created: 11/02/2026
# This Bash script will set the NASA APOD to your Desktop Background and will do it daily if installed

download_image(){
	curl -L "$1" -o "$HOME/.APOD_IMAGE/apod_image.jpg"
}

set_background(){
	image_file="$HOME/.APOD_IMAGE/apod_image.jpg"

	if [[ -f "$image_file" ]]; then
	    image_uri="file://$image_file"

	    gsettings set org.gnome.desktop.background picture-uri "$image_uri"
	    gsettings set org.gnome.desktop.background picture-uri-dark "$image_uri"

	    echo "Desktop background updated."
	else
	    echo "Error: Image file not found." >&2
	    exit 1
	fi
}

install_cron() {
    local script_path="$HOME/.local/bin/apod_to_background.sh"
    local cron_job="0 0 * * * $script_path >> $HOME/apod.log 2>&1"
    local cron_job_reboot="@reboot $script_path >> $HOME/apod.log 2>&1"
    local existing_cron

    existing_cron=$(crontab -l 2>/dev/null || true)

    if ! grep -Fqx "$cron_job" <<< "$existing_cron"; then
        existing_cron+=$'\n'"$cron_job"
    fi

    if ! grep -Fqx "$cron_job_reboot" <<< "$existing_cron"; then
        existing_cron+=$'\n'"$cron_job_reboot"
    fi

    if printf '%s\n' "$existing_cron" | crontab -; then
        echo "APOD TO BACKGROUND cron jobs installed."
    else
        echo "Error: Failed to install cron jobs." >&2
        return 1
    fi
}

uninstall_cron() {
    local script_path="$HOME/.local/bin/apod_to_background.sh"

    # Check whether the crontab contains the APOD job
    if ! crontab -l 2>/dev/null | grep -Fq "$script_path"; then
        echo "APOD cron job was not found."
        return 0
    fi

    # Remove the APOD job while preserving other cron jobs
    crontab -l 2>/dev/null | grep -Fv "$script_path" | crontab -

    if [[ $? -eq 0 ]]; then
        echo "APOD cron job successfully removed."
    else
        echo "Error: Unable to remove APOD cron job." >&2
        return 1
    fi
}

uninstall(){
	echo "Uninstalling NASA APOD Background"

    echo "Removing recurring cron jobs"
    uninstall_cron || return 1

    echo "Removing source file"
    rm -f "$HOME/.local/bin/apod_to_background.sh"

    echo "Uninstall complete"
}

install(){
	echo "Installing Nasa APOD Background"
	mkdir -p "$HOME/.local/bin" || return 1

    cat > "$HOME/.local/bin/apod_to_background.sh" <<'EOF'
#!/usr/bin/env bash

download_image(){
	curl -L "$1" -o "$HOME/.APOD_IMAGE/apod_image.jpg"
}

set_background(){
	image_file="$HOME/.APOD_IMAGE/apod_image.jpg"

	if [[ -f "$image_file" ]]; then
	    image_uri="file://$image_file"

	    gsettings set org.gnome.desktop.background picture-uri "$image_uri"
	    gsettings set org.gnome.desktop.background picture-uri-dark "$image_uri"

	    echo "Desktop background updated."
	else
	    echo "Error: Image file not found." >&2
	    exit 1
	fi
}

NASA_APOD(){

	year=$(date +"%y")
	month=$(date +"%m")
	day=$(date +"%d")
	formated_date="${year}${month}${day}"

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
			json_reponse=$(curl -s \
					"https://science.nasa.gov/wp-json/wp/v2/apod-basic/${formated_date}" \
					| jq '{
					    date,
					    title,
					    media_type,
					    url,
					    hdurl
					}'
			)
			hdurl=$(echo "${json_reponse}" | jq -r '.hdurl')
			hdurl="${hdurl%\"}"
			hdurl="${hdurl#\"}"

			#Download the Image 
			download_image "$hdurl" 

			set_background

			;;
	esac
}

NASA_APOD "$@"
EOF
    chmod +x "$HOME/.local/bin/apod_to_background.sh"
    install_cron
}

help(){
	echo "Nasa APOD Background - help"
    echo "-------------------------"
    echo
    echo "-h,--help               		This help message"
    echo "-i,--install            		To install the script to be a permanent program that will run daily"
    echo "-u,--uninstall          		To uninstall the NASA APOD Background previously installed"
}


NASA_APOD(){

	year=$(date +"%y")
	month=$(date +"%m")
	day=$(date +"%d")
	formated_date="${year}${month}${day}"

	# Define the cases for the inputs 
	case "$1" in 
		-h|--help)
			help
			;;
		-i|--install)
			install
			;;
		-u|--uninstall)
			uninstall
			;;
		*)
			echo "Set APOD to Desktop Background"
			if [ ! -d "$HOME/.APOD_IMAGE/" ]; then 
				mkdir -p "$HOME/.APOD_IMAGE/"
			fi
			json_reponse=$(curl -s \
					"https://science.nasa.gov/wp-json/wp/v2/apod-basic/${formated_date}" \
					| jq '{
					    date,
					    title,
					    media_type,
					    url,
					    hdurl
					}'
			)
			hdurl=$(echo "${json_reponse}" | jq -r '.hdurl')
			hdurl="${hdurl%\"}"
			hdurl="${hdurl#\"}"
			#echo "$hdurl"

			#Download the Image 
			download_image "$hdurl" 

			set_background

			echo "Desktop Background Set to The Image of the Day: ${month}/${day}/${year}"
			;;
	esac


}

NASA_APOD "$@"