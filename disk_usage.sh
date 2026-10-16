# Disk Usage
# By Daniel Louis
# Created: 10/15/2026
# This Bash script will monitor storage and give a warning if the root partition exceeds 90% to prevent failures. 

## !! Run this in Sublime Editor with 'CTRL + B'

print_help() {
    echo "Disk Usage Monitor - help"
    echo "-------------------------"
    echo "use the alias 'diskusage' for commandline alias"
    echo
    echo "disk_usage <option>"
    echo "-h,--help               This help message"
    echo "                        To install the monitor run this script with no arguments"
    echo "-U,--Uninstall          To uninstall the monitor previously installed"
    echo "-l,--log   <file path>  To set the log destination, enter the path after the flag"
    echo "  -d,--default          Will set the log directory to the default"
    echo "    Add this argument after -l,--log"
    echo "-r.--run                To run the health check manually, output to log"
    echo "  --toScreen,-t         Print the output of run to terminal as well as the log"
    echo "    Add this argument after -r,--run"
}

install() {
    echo "Installing Disk Usage Monitor"

    #if command -v ncdu >/dev/null 2>&1; then
    #    echo "ncdu is installed."
    #    ncdu --version
    #else
    #    echo "ncdu is not installed."
    #    echo "ncdu is required, please install"
    #    return 1 
    #    #TODO try to install ncdu first 
    #fi 

    #Add alias to call 'diskusage'
    script_path=$(readlink -f "${BASH_SOURCE[0]}")
    if [ ! -d "$HOME/.local/bin" ]; then
        mkdir -p "$HOME/.local/bin"
    fi
    cp "$script_path" "$HOME/.local/bin"
    chmod +x "$HOME/.local/bin/disk_usage.sh"
    if grep -qE '^[[:space:]]*alias[[:space:]]+diskusage=' "$HOME/.bashrc"; then
        echo "The diskusage alias already exists."
    else
        if [ ! -d "$HOME/.local/share/applications" ]; then
            mkdir -p "$HOME/.local/share/applications"
        fi
        cat >> "$HOME/.local/share/applications/disk-usage.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Disk Usage Monitor
Comment=Check root filesystem disk usage
Exec=gnome-terminal -- bash -c "$HOME/.local/bin/disk_usage.sh --run; echo; read -p 'Press Enter to close...'"
Icon=utilities-system-monitor
Terminal=false
Categories=System;Utility;
EOF
        cat >> "$HOME/.bashrc" <<EOF
alias diskusage="$HOME/.local/bin/disk_usage.sh"
EOF
        source "$HOME/.bashrc"
        type diskusage
        echo "Alias set to diskusage"
    fi

    if [ ! -d "${log_path}" ]; then
        mkdir "${log_path}"
        echo "${log_path} created and will be the log destination"
    fi
    #ADD cron job to call run every so often
    if command -v crontab >/dev/null 2>&1; then
        install_cron
    else
        echo "Error: crontab is not installed."
        return 1
    fi
}

uninstall() {
    echo "Uninstalling the monitor"
    unexpected_files=$(find "$log_path/" -maxdepth 1 -type f \
    ! -name "disk_usage.log" \
    ! -name "cron.log" \
    ! -name "disk_usage-rolled.log" \
    -print)

    if [ -n "$unexpected_files" ]; then
        echo "Unexpected files found in the log directory:"
        echo "$unexpected_files"
        for file in disk_usage.log cron.log disk_usage-rolled.log; do
            if [[ -f "$log_path/$file" ]]; then
                rm -- "$log_path/$file" || {
                    echo "Error removing $file"
                    return 1
                }
            fi
        done
        echo "will not remove log directory"
    else
        echo "Removing log directory"
        rm -r "$log_path"
    fi
    if [ -f "$HOME/.disk_usage_config" ]; then
        echo "removing config files"
        rm "$HOME/.disk_usage_config"
    fi

    #TODO remove alias and cron 
    local bashrc="$HOME/.bashrc"
    if grep -qE '^[[:space:]]*alias[[:space:]]+diskusage=' "$bashrc"; then
        if sed -i '/^[[:space:]]*alias[[:space:]]\+diskusage=/d' "$bashrc"; then
            unalias diskusage 2>/dev/null
            echo "Disk Usage Monitor alias removed."
        else
            echo "Error: Failed to remove alias from .bashrc."
            return 1
        fi
    else
        echo "Disk Usage Monitor alias was not found in .bashrc."
        unalias diskusage 2>/dev/null
    fi
    unalias diskusage

    local desktop_file="$HOME/.local/share/applications/disk-usage.desktop"

    if [[ -f "$desktop_file" ]]; then
        if rm -- "$desktop_file"; then
            echo "Disk Usage Monitor desktop shortcut removed."
        else
            echo "Error: Failed to remove desktop shortcut."
            return 1
        fi
    else
        echo "Disk Usage Monitor desktop shortcut was not found."
    fi    

    echo "Script has been removed"
    rm "$HOME/.local/bin/disk_usage.sh"

    source "$HOME/.bashrc"
}

log() {
    local temp_log_path
    local unexpected_files
    local file
    local move_failed=0

    if [[ "$2" == "-d" || "$2" == "--default" || -z "$2" ]]; then
        temp_log_path="$HOME/disk_usage_log/"
    else
        temp_log_path="$2"
    fi

    # Ensure the destination directory exists.
    if ! mkdir -p -- "$temp_log_path"; then
        echo "Error: Could not create destination directory."
        return 1
    fi

    # Move the expected log files if they exist.
    for file in disk_usage.log cron.log disk_usage-rolled.log; do
        if [[ -f "$log_path/$file" ]]; then
            if ! mv -- "$log_path/$file" "$temp_log_path/"; then
                echo "Error: Failed to move $file"
                move_failed=1
            fi
        fi
    done

    # Stop if any file move failed.
    if [[ "$move_failed" -ne 0 ]]; then
        echo "Log directory was not removed."
        return 1
    fi

    # Find unexpected files or subdirectories.
    unexpected_files=$(find "$log_path" -mindepth 1 -maxdepth 1 \
        ! -name "disk_usage.log" \
        ! -name "cron.log" \
        ! -name "disk_usage-rolled.log" \
        -print)

    if [[ -n "$unexpected_files" ]]; then
        echo "Unexpected items found in the log directory:"
        echo "$unexpected_files"
        echo "Will not remove log directory."
    else
        # The directory should now be empty.
        if rmdir -- "$log_path"; then
            echo "Log directory removed."
        else
            echo "Could not remove log directory; it may not be empty."
        fi
    fi

    log_path="$temp_log_path"

    touch "$config_file" || return 1
    printf 'log_path=%q\n' "$log_path" > "$config_file" || return 1

    echo "Log directory has been updated to $log_path"
}

install_cron() {
    local script_path
    local cron_job

    script_path="$HOME/.local/bin/disk_usage.sh"
    cron_job="*/15 * * * * $script_path --run >> /home/dan/disk_usage_log/cron.log 2>&1"

    # Check whether the job already exists
    if crontab -l 2>/dev/null | grep -Fqx "$cron_job"; then
        echo "Disk Usage Monitor cron job already exists."
        return 0
    fi

    # Add the job while preserving existing cron jobs
    {
        crontab -l 2>/dev/null
        echo "$cron_job"
    } | crontab -

    if [ $? -eq 0 ]; then
        echo "Disk Usage Monitor cron job installed."
    else
        echo "Error: Failed to install cron job."
        return 1
    fi
}

disk_usage(){
    log_path="$HOME/disk_usage_log/"
    config_file="$HOME/.disk_usage_config"

    # Load saved path, or use default
    log_path="$HOME/disk_usage_log/"
    if [ -f "$config_file" ]; then
        source "$config_file"
    fi

    if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
       print_help

    elif [ "$1" == "--Uninstall" ] || [ "$1" == "-U" ]; then
        uninstall
        
    elif [ "$1" == "--log" ] || [ "$1" == "-l" ]; then
        log "$@"

    elif [ "$1" == "--run" ] || [ "$1" == "-r" ]; then
        #check size of log and purge rotate if to large
        touch "${log_path}/disk_usage.log"
        log_size=$(du -B1 "${log_path}/disk_usage.log" | awk '{print $1}')

        if [ "$log_size" -ge 1000000000 ]; then
            mv "${log_path}/disk_usage.log" "${log_path}/disk_usage-rolled.log"
        fi
        if [ "$2" == "--toScreen" ] || [ "$2" == "-t" ]; then

            echo "Output to screen: "
            usage=$(df / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
            if [ "$usage" -gt 90 ]; then
                echo "WARNING: Root filesystem usage is above 90%!"
                echo "Current usage: ${usage}%"
                #ncdu -x /
            else
                echo "Root filesystem usage: ${usage}%"
                echo "Disk usage is within limits."
            fi
        fi
        usage=$(df / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
        if [ "$usage" -gt 90 ]; then
            cat >> "$log_path/disk_usage.log" <<EOF
========================================
Disk Usage Report
Date: $(date)
Root Usage: ${usage}%
WARNING: Root filesystem usage is above 90%!
========================================
EOF
            #TODO escalate warning to user 
            #ncdu -x /
        else
            cat >> "$log_path/disk_usage.log" <<EOF
========================================
Disk Usage Report
Date: $(date)
Root Usage: ${usage}%
Disk usage is within limits.
========================================

EOF
        fi

    else
        install 
    fi

}

#"$@" will accept all passed variable "$1" will only accept one argument 
disk_usage "$@"
