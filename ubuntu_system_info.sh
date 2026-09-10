# Ubunto System Info
# By Daniel Louis
# Created: 08/14/2026
# This Bash Script will output system information for systems running Ubuntu

## !! Run this in Sublime Editor with 'CTRL + B'

# Prints total amount of usable memory for the system 
#echo "Memory:"
#free -h | awk '/^Mem:/ {print "Total Available memory:", $2}'

# Prints the search path to indicate where applications are located 
#echo $PATH


system_info()
{
	echo "==============================================="
	echo "            UBUNTU SYSTEM INFORMATION          "
	echo "==============================================="

	echo 
	echo "[ SYSTEM ]"
	echo 
	#Distribution name 
	distribution=$(lsb_release -a 2>/dev/null | grep "Distributor" | cut -f2)
		# 2>/dev/null will send the error stream to null instead of stdout, to avoid the line "No LSB modules are available." from being printed
	echo "    Distribution Name: $distribution"
	#Ubuntu version
	version=$(lsb_release -a 2>/dev/null | grep "Description" | cut -f2)
	echo "    Version: $version"
	#Release/codename
	release=$(lsb_release -a 2>/dev/null | grep "Release" | cut -f2)
	echo "    Release: $release"
	#Kernel version
	kernel=$(uname -r)
	echo "    Kernel Version: $kernel"
	#System architecture
	sys_arc=$(uname -m)
	echo "    System Architecture: $sys_arc"
	#Hostname
	hostname=$(hostname)
	echo "    Hostname: $hostname"
	#System uptime
	uptime=$(uptime | cut -d, -f1)
	echo "    System Uptime: $uptime"

	echo 
	echo "[ HARDWARE ]"
	echo 
	#CPU model
	cpu_model=$(lscpu | grep "Model name" | cut -d: -f2 | sed 's/^[[:space:]]*//')
	## Remove leading white space from string with sed | sed 's/^[[:space:]]*//'
	echo "    CPU Model: $cpu_model"
	#Number of CPU cores/threads
	echo "    Number of CPU Cores/Threads: "
	cores=$(lscpu | grep "Core" | cut -d: -f2 |  sed 's/^[[:space:]]*//')
	thread=$(lscpu | grep "Thread" | cut -d: -f2 |  sed 's/^[[:space:]]*//')
	echo "        Core(s) per socket: $cores" 
	echo "        Thread(s) per core: $thread"
	#CPU architecture
	architecure=$(lscpu | grep "Architecture" | cut -d: -f2 |  sed 's/^[[:space:]]*//')
	echo "    CPU Architecture: $architecure"
	#RAM installed
	installed_ram=$(awk '/MemTotal/ {printf "%.0fGiB", $2/1024/1024}' /proc/meminfo)
	echo "    RAM Installed: $installed_ram"
	#RAM currently available
	ava_ram=$(free -h | awk '/^Mem:/ {print $4}') 
	echo "    RAM Currently Available: $ava_ram"
	#Swap memory
	swap=$(free -h | awk '/^Swap:/ {print $2}')
	echo "    Swap Memory: $swap"
	#Motherboard information
	BOARD=$(cat /sys/devices/virtual/dmi/id/board_name 2>/dev/null)
	if [ -n "$BOARD" ]; then
	    echo "    Motherboard Serial Number: $BOARD"
	else
	    echo "    Motherboard: Unavailable"
	fi
	#BIOS/UEFI information
	vendor=$(cat /sys/class/dmi/id/bios_vendor)
	version=$(cat /sys/class/dmi/id/bios_version)
	bios_date=$(cat /sys/class/dmi/id/bios_date) 
	echo "    BIOS / UEFI Information:"
	echo "        BIOS Vendor: $vendor"
	echo "        BIOS Version: $version"
	echo "        BIOS Date: $bios_date"

	echo
	echo "[ STORAGE ]"
	echo 
	#Total disk space
	total=$(df -h --total | grep "total" | awk '{print $2}')
	echo "    Total Disk Space: $total"
	#Used disk space
	used=$(df -h --total | grep "total" | awk '{print $3}')
	echo "    Used Disk Space: $used"
	#Available disk space
	avl=$(df -h --total | grep "total" | awk '{print $4}')
	echo "    Available Disk Space: $avl"
	#Disk usage percentage
	percent=$(df -h --total | grep "total" | awk '{print $5}')
	echo "    Disk Usage Percentage: $percent"
	#List of mounted filesystems
	echo "    List of Mounted Filesystems: "
	files=$(df -h | awk 'NR > 1 {print $1}') 
	##NR>1 will skip the first output of "Filesystem" 
	for i in $files; do
		echo "        $i"
	done
	#Root filesystem usage
	root_usage=$(df -h /)
	echo "    Root Filesystem Usage: "
	df -h / | awk '{printf "        %-12s %-7s %-7s %-7s %-5s\n", $1, $2, $3, $4, $5}'
	#Information about attached drives
	disks=$(lsblk -d -o NAME,SIZE,TYPE,MODEL | grep ' disk ')
	echo "    Mounted Disks: "
	lsblk -d -o NAME,SIZE,TYPE,MODEL | awk '$3 == "disk" {printf "        %s %s %s %s\n", $1, $2, $3, $4}'

	echo
	echo "[ Network Information ]"
	echo 
	#Hostname
	hostname=$(hostname)
	echo "    Hostname: $hostname"
	#Network interfaces
		# get netowrk names 
		#() around the command to put the output into an array 
	eth_list=($(ip link | grep "[1-9]:"  | cut -d \  -f2 | cut -d: -f1))
	eth_status_list=($(ip link | grep "[1-9]:"  | cut -d \  -f9))
	echo "    Network Interface And Statues: "
	for i in "${!eth_list[@]}"; do
		echo "        $((i+1)): ${eth_list[i]}, ${eth_status_list[i]}" 
	done
	#IP addresses
	echo "    IP Addresses for UP Interfaces: "
	for i in "${!eth_status_list[@]}"; do
		if [ "${eth_status_list[i]}" == "UP" ]; then
			ip_address=$(ip a show ${eth_list[i]} | grep -w "inet" | cut -d\  -f6)
			echo "        IP for ${eth_list[i]}: $ip_address"
		fi
	done
	#MAC addresses
	echo "    MAC Addresses for Interfaces:"
	for i in "${!eth_list[@]}"; do
		if [ "${eth_list[i]}" == "lo" ]; then
			mac_address=$(ip a show ${eth_list[i]} | grep "link" | cut -d\  -f6)
			echo "        $((i+1)): ${eth_list[i]}, $mac_address"
		else
			mac_address=$(ip a show ${eth_list[i]} | grep "link/ether" | cut -d\  -f6)
			echo "        $((i+1)): ${eth_list[i]}, $mac_address"
		fi
	done
	#Default gateway
	echo "    Default Gateway: $(ip route show default | sed 's/default via //' )"

	# DNS configuration
	echo "    Current DNS Servers:"

	resolvectl dns | awk '
	/^Link/ {
	    interface = $0
	    sub(/^.*\(/, "", interface)
	    sub(/\).*$/, "", interface)

	    printf "        Interface: %s\n", interface

	    if (NF > 3) {
	        for (i = 4; i <= NF; i++)
	            printf "            DNS: %s\n", $i
	    } else {
	        printf "            DNS: None\n"
	    }
	}'
	#Network connectivity status
	if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
		echo "    Internet Access: Connected"
	else
		echo "    Internet Access: Disconnected"
	fi

	echo
	echo "[ User Information ]"
	echo 
	#Current username
	echo -e "    Current User: $USER"
	#Logged-in users
	users=$(users)
	echo "    Logged-in  Users:"
	for i in $users; do
		echo "        $i"
	done
	#User's home directory
	echo "    User's Home Directory: $HOME"
	#Current shell
	echo "    Current Shell: $SHELL"
	#User ID / group ID
	uid=$(id | cut -d\  -f1)
	echo "    User ID: $uid"
	gid=$(id | cut -d\  -f2)
	echo "    Group ID: $gid"
	#Number of users currently logged in
	echo "    Number of users currently logged in: ${#users[@]}"

	echo
	echo "[ System Resources ]"
	echo 
	#Current CPU usage
	echo "    Current CPU Usage: $(top -bn1 | awk '/Cpu\(s\)/ {print 100 - $8}')%"
	#Memory usage
	echo "    Memory Usage: $(free | awk '/Mem:/ {printf "%.1f%%", $3/$2 * 100}')"
	#Swap usage
	echo "    Swap Usage: $(free -h | awk '/Swap:/ {print $3}')"
	#Disk usage
	echo "    Disk Usage: $(df / | awk 'NR==2 {print $5}')"
	#System load
	echo "    System Load: $(awk '{print $1}' /proc/loadavg)"
	#Number of running processes
	echo "    Running Processes: $(ps -e --no-headers | wc -l)"

	echo
	echo "[ Process Information ]"
	echo 
	#Number of running processes
	echo "    Running Processes: $(ps -e --no-headers | wc -l)"
	#Highest CPU-consuming processes
	echo "    Highest CPU-Consuming Processes:"
	ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 | awk '{printf "        %-8s %-20s %s%%\n", $1, $2, $3}'
	#Highest memory-consuming processes
	echo "    Highest Memory-Consuming Processes:"
	ps -eo pid,comm,%mem --sort=-%mem | head -n 6 |
		awk '{printf "        %-8s %-20s %s%%\n", $1, $2, $3}'
	#Current user's processes
	user_process=$(ps -u "$USER" --no-headers | wc -l)
	echo "    Current User's Processes: $user_process"
	#System process count
	echo "    System Processes: $(ps -eo user= | grep '^root$' | wc -l)"

	echo
	echo "[ Security Information ]"
	echo 
	#Firewall status
	firewall_active=$(systemctl is-active ufw)
	echo "    Firewall Satus (Uncomplicated Firewall): $firewall_active"
	#Current user privileges
	echo "    Current User: $(whoami)"
	echo "        User ID: $(id -u)"
	echo "        Primary Group: $(id -gn)"

	if groups | grep -qw sudo; then
	    echo "        Sudo Privileges: Yes"
	else
	    echo "        Sudo Privileges: No"
	fi
	#Whether the script is running as root
	if [ "$EUID" -eq 0 ]; then
	    echo "    Running as root: Yes"
	else
	    echo "    Running as root: No"
	fi
	#Failed login attempts
	if [ -r /var/log/btmp ]; then
	    echo "    Failed Login Attempts: $(lastb -w 2>/dev/null | wc -l)"
	else
	    echo "    Failed Login Attempts: Requires root permissions"
	fi
	#SSH status
	ssh_active=$(systemctl is-active ssh)
	echo "    SSH Status: $ssh_active"


	echo
	echo "[ Software Information ]"
	echo 
	#Number of installed packages
	installed_packages=$(dpkg --get-selections | grep -v deinstall | wc -l)
	echo "    Number of Installed Packages: $installed_packages"
	#Available package updates
	package_updates=$(apt list --upgradable 2>/dev/null | tail -n +2 | wc -l)
	echo "    Available Package Updates: $package_updates"
	#Package manager information
	if command -v apt >/dev/null 2>&1; then
    	package_manager="APT"
	elif command -v dnf >/dev/null 2>&1; then
	    package_manager="DNF"
	elif command -v yum >/dev/null 2>&1; then
	    package_manager="YUM"
	elif command -v pacman >/dev/null 2>&1; then
	    package_manager="Pacman"
	else
	    package_manager="Unknown"
	fi
	echo "    Package Manager: $package_manager"
	#Python version
	if command -v python >/dev/null 2>&1; then
		python_version=$(python --version | awk '{printf "%s ", $2}')
	elif command -v python3 >/dev/null 2>&1; then
		python_version=$(python3 --version | awk '{printf "%s ", $2}')
	else
		python_version="Unknown"
	fi 
	echo "    Python Version: $python_version"
	#Bash version
	if command -v bash >/dev/null 2>&1; then
		bash_version=$(bash --version | head -n 1 | awk '{print $4}')
	else 
		bash_version="Unkonwn"
	fi
	echo "    Bash Version: $bash_version)"
	#Git version
	if command -v git >/dev/null 2>&1; then
		git_version=$(git --version | awk '{printf "%s ", $3}')
	else
		git_version="Unknown"
	fi
	echo "    Git Version: $git_version"

	echo
	echo "[ Services ]"
	echo 
	#Running services
	running=$(systemctl list-units --type=service --state=running --no-legend | wc -l)
	echo "    Runing Services: $running"
	#Failed services
	failed=$(systemctl --failed --type=service --no-legend | wc -l)
	echo "    Failed Serices: $failed"
	#SSH
	ssh_active=$(systemctl is-active ssh)
	echo "    SSH Status: $ssh_active"
	#Firewall
	firewall_active=$(systemctl is-active ufw)
	echo "    Firewall Satus (Uncomplicated Firewall): $firewall_active"
	#Cron
	cronjobs=$(crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$' | wc -l)
	echo "    Number of Cron Jobs: $cronjobs"
	#Network services
	echo "    Network Services: "
	systemctl list-units --type=service --state=running --no-legend |
		grep -Ei 'network|networking|systemd-networkd|NetworkManager|dhcp|ssh' |
		awk '{printf "        %s\n", $1}'

	echo
	echo "[ System Logs ]"
	echo 
	#Recent system errors
	echo "    Recent System Errors:"
	journalctl -p err -n 5 --no-pager -o cat | awk '{printf "         %s\n", $0}'
	#Recent warnings
	echo "    Recent System Warnings:"
	journalctl -p warning -n 5 --no-pager -o cat | awk '{printf "         %s\n", $0}'
	#Boot messages
	echo "    Boot Messages:"
	journalctl -b -n 5 --no-pager -o cat | awk '{printf "         %s\n", $0}'
	#Kernel messages
	echo "    Kernel Messages:"
	if [ -r /var/log/btmp ]; then
	    dmesg | tail -n 5 | awk '{printf "         %s\n", $0}'
	else
	    echo "        Kernel Logs: Requires root permissions"
	fi
	#Authentication events
	echo "    Authentication Events:"
	journalctl -t sudo -t sshd -n 5 --no-pager -o cat | awk '{printf "         %s\n", $0}'

	echo
	echo "[ System Activity ]"
	echo 
	#Current date/time
	echo "    Date: $(date)"
	#System uptime
	uptime=$(uptime | cut -d\  -f3-5 | cut -d, -f1)
	echo "    System Uptime: $uptime"
	#Last reboot
	echo "    Last Reboot: "
	last reboot | head -n 1 | awk '{printf "        %-7s %-2s %-7s %-19s %-4s %-2s %-4s %-7s %-2s %-7s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}'
	#Last logged-in user
	last_user=$(last | head -n1 | cut -d\  -f1)
	last_time=$(last | head -n1 | cut -d\  -f29-32)
	echo "    Last Logged-in User: $last_user; Since $last_time"

	echo
	echo "[ System Health Summary ]"
	echo 
	#This could be the final section of your script and give the user an overall picture:
	#CPU: Normal / High
	#Memory: Normal / High
	#Disk: Normal / Warning / Critical
	#Swap: Normal / High
	#Firewall: Enabled / Disabled
	#Failed services: None / Detected
	#Available updates: None / Available
}

system_info 