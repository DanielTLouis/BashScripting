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
	lscpu | grep "Model name"
	#Number of CPU cores/threads
	lscpu
	#CPU architecture
	#RAM installed
	#RAM currently available
	#Swap memory
	#Motherboard information
	#BIOS/UEFI information

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
	files=$(df -h | awk '{print $1}')
	for i in $files; do
		echo "        $i"
	done
	#Root filesystem usage
	#Information about attached drives

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
	#Memory usage
	#Swap usage
	#Disk usage
	#System load
	#Number of running processes

	echo
	echo "[ Process Information ]"
	echo 
	#Number of running processes
	#Highest CPU-consuming processes
	#Highest memory-consuming processes
	#Current user's processes
	#System process count

	echo
	echo "[ Security Information ]"
	echo 
	#Firewall status
	#Firewall rules summary
	#Current user privileges
	#Whether the script is running as root
	#Failed login attempts
	#SSH status

	echo
	echo "[ Software Information ]"
	echo 
	#Number of installed packages
	#Available package updates
	#Package manager information
	#Important installed software
	#Python version
	#Bash version
	#Git version

	echo
	echo "[ Services ]"
	echo 
	#Running services
	#Failed services
	#Important services such as:
	#SSH
	#Network services
	#Firewall
	#Cron
	#Number of active services

	echo
	echo "[ System Logs ]"
	echo 
	#You could have a section that summarizes:
	#Recent system errors
	#Recent warnings
	#Boot messages
	#Kernel messages
	#Authentication events

	echo
	echo "[ System Activity ]"
	echo 
	#Current date/time
	#System uptime
	#Last reboot
	#Last logged-in user
	#Recent system activity

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