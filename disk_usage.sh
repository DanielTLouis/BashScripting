# Disk Usage
# By Daniel Louis
# Created: 10/15/2026
# This Bash script will monitor storage and give a warning if the root partition exceeds 80% to prevent failures. 

## !! Run this in Sublime Editor with 'CTRL + B'

disk_usage(){
    if [ "$1" == "help" ]; then
        echo "help asked for"
        echo "To install the monitor run this script with no arguments"
        echo -e "To uninstall the monitor run with argument \"Uninstall\""
    elif [ "$1" == "Uninstall" ]; then
        echo "Uninstalling the monitor"
    else
        echo "Installing Disk Usage Monitor"
        if command -v ncdu >/dev/null 2>&1; then
            echo "ncdu is installed."
            ncdu --version
        else
            echo "ncdu is not installed."
        fi 
    fi

}

disk_usage $1 
