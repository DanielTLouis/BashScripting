# System Health Monitor
# By Daniel Louis
# Created: 10/08/2026
# This Bash Script will output system health and warnings if present 

## !! Run this in Sublime Editor with 'CTRL + B'


health_monitor(){
	echo "========================================"
	echo "       Linux System Health Report       "
	echo "========================================"


	echo "[ SYSTEM ]"

	hostname=$(hostname)
    echo "	Hostname: ${hostname}"

    #	OS: Ubuntu 22.04.5 LTS
    distribution=$(lsb_release -a 2>/dev/null | grep "Distributor" | cut -f2)
		# 2>/dev/null will send the error stream to null instead of stdout, to avoid the line "No LSB modules are available." from being printed
	echo "    OS: $distribution"
	version=$(lsb_release -a 2>/dev/null | grep "Description" | cut -f2)
	echo "    Version: $version"

    kernel=$(uname -r)
	echo "    Kernel Version: $kernel"

    uptime=$(uptime | cut -d, -f1)
	echo "    System Uptime: $uptime"


	echo "[ HARDWARE ]"

    cpu_model=$(lscpu | grep "Model name" | cut -d: -f2 | sed 's/^[[:space:]]*//')
	echo "    CPU Model: $cpu_model"

    echo "    Number of CPU Cores/Threads: "
	cores=$(lscpu | grep "Core" | cut -d: -f2 |  sed 's/^[[:space:]]*//')
	thread=$(lscpu | grep "Thread" | cut -d: -f2 |  sed 's/^[[:space:]]*//')
	echo "        Core(s) per socket: $cores"
	echo "        Thread(s) per core: $thread"

    installed_ram=$(awk '/MemTotal/ {printf "%.0fGiB", $2/1024/1024}' /proc/meminfo)
	echo "    RAM Installed: $installed_ram"


	echo "[ MEMORY ]"
    #	RAM Total:     31Gi
    #	RAM Used:      5.6Gi
    #	RAM Available: 24Gi
    #	Swap Used:     0B


	echo "[ STORAGE ]"
    percent=$(df -h --total | grep "total" | awk '{print $5}')
	echo "    Disk Usage Percentage: $percent"
    

	echo "[ SERVICES ]"
    #	Running Services: 185
    #	Failed Services: 0
    #	Status: Normal

	echo "[ NETWORK ]"
    #	nterface: enp1s0
    #	IP Address: 192.168.1.100
    #	DNS: 192.168.1.1


	echo "[ HEALTH ]"
    #	CPU:       Normal
    #	Memory:    Normal
    #	Disk:      Normal
    #	Swap:      Normal
    #	Services:  Normal
    #   Storage:   Normal


	echo "========================================"
}

health_monitor