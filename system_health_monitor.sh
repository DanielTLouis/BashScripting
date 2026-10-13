# System Health Monitor
# By Daniel Louis
# Created: 10/08/2026
# This Bash Script will output system health and warnings if present 

## !! Run this in Sublime Editor with 'CTRL + B'


health_monitor(){
	if [ -n "$TERM" ]; then
    	width=$(tput cols 2>/dev/null)
	else
	    width=60
	fi

	width=${width:-60}
	divider=$(printf '%*s\n' "$width" '' | tr ' ' '=')
	echo "$divider"
	echo "       Linux System Health Report       "
	echo "$divider"


	echo "[ SYSTEM ]"

	hostname=$(hostname)
    echo "	Hostname: ${hostname}"

    #	OS: Ubuntu 22.04.5 LTS
    distribution=$(lsb_release -a 2>/dev/null | grep "Distributor" | cut -f2)
		# 2>/dev/null will send the error stream to null instead of stdout, to avoid the line "No LSB modules are available." from being printed
	echo "	OS: $distribution"
	version=$(lsb_release -a 2>/dev/null | grep "Description" | cut -f2)
	echo "	Version: $version"

    kernel=$(uname -r)
	echo "	Kernel Version: $kernel"

    uptime=$(uptime | cut -d, -f1)
	echo "	System Uptime: $uptime"


	echo "[ HARDWARE ]"

    cpu_model=$(lscpu | grep "Model name" | cut -d: -f2 | sed 's/^[[:space:]]*//')
	echo "	CPU Model: $cpu_model"

    echo "	Number of CPU Cores/Threads: "
	cores=$(lscpu | grep "Core" | cut -d: -f2 |  sed 's/^[[:space:]]*//')
	thread=$(lscpu | grep "Thread" | cut -d: -f2 |  sed 's/^[[:space:]]*//')
	echo "		Core(s) per socket: $cores"
	echo "		Thread(s) per core: $thread"

    installed_ram=$(awk '/MemTotal/ {printf "%.0fGiB", $2/1024/1024}' /proc/meminfo)
	echo "	RAM Installed: $installed_ram"


	echo "[ MEMORY ]"
	echo "	RAM"
    #	RAM Total:     31Gi
    installed_ram=$(awk '/MemTotal/ {printf "%.0fGiB", $2/1024/1024}' /proc/meminfo)
	echo "		RAM Total: $installed_ram"
    #	RAM Used:      5.6Gi
    used_ram=$(free -h | awk '/^Mem:/ {print $3}')
    echo "		RAM Used: $used_ram"
    #	RAM Available: 24Gi
    ava_ram=$(free -h | awk '/^Mem:/ {print $4}') 
	echo "		RAM Currently Available: $ava_ram"

	echo "	Swap"

	swap_total=$(free -h | awk '/^Swap:/ {print $2}')
	echo "		Swap Used: $swap_total"
    #	Swap Used:     0B
    swap_used=$(free -h | awk '/^Swap:/ {print $3}')
	echo "		Swap Used: $swap_used"


	echo "[ STORAGE ]"
    percent=$(df -h --total | grep "total" | awk '{print $5}')
	echo "	Disk Usage Percentage: $percent"
    

	echo "[ SERVICES ]"
    #	Running Services: 185
    running=$(systemctl list-units --type=service --state=running --no-legend | wc -l)
	echo "    Runing Services: $running"
    #	Failed Services: 0
    failed=$(systemctl --failed --type=service --no-legend | wc -l)
	echo "    Failed Serices: $failed"
    

	echo "[ NETWORK ]"
    #	nterface: enp1s0
    eth_list=($(ip link | grep "[1-9]:"  | cut -d \  -f2 | cut -d: -f1))
	eth_status_list=($(ip link | grep "[1-9]:"  | cut -d \  -f9))
	echo "    Network Interface And Statues: "
	for i in "${!eth_list[@]}"; do
		echo "        $((i+1)): ${eth_list[i]}, ${eth_status_list[i]}" 
	done
    #	IP Address: 192.168.1.100
    echo "    IP Addresses for UP Interfaces: "
	for i in "${!eth_status_list[@]}"; do
		if [ "${eth_status_list[i]}" == "UP" ]; then
			ip_address=$(ip a show ${eth_list[i]} | grep -w "inet" | cut -d\  -f6)
			echo "        IP for ${eth_list[i]}: $ip_address"
		fi
	done
    #	DNS: 192.168.1.1
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


	echo "[ HEALTH ]"
    #	CPU:       Normal
    # # if cpu is or was above 90% it is critial, otherwise normal (unless fault detected)
    cpu_usage=$(top -bn1 | awk '/Cpu\(s\)/ {print 100 - $8}')
    if [ "${cpu_usage%.*}" -gt 90 ]; then
    	echo "	CPU: Critial - Usage is above 90%"
    	echo "		CPU Ussage: ${cpu_usage}"
    	echo "    	Highest CPU-Consuming Processes:"
			ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 | awk '{printf "        	%-8s %-20s %s%%\n", $1, $2, $3}'
	

    else 
    	echo "	CPU: Normal"
    fi
    
    #	Memory:    Normal
    # # if cpu is or was above 90% it is critial, otherwise normal (unless fault detected)
    mem_usage=$(free | awk '/Mem:/ {printf "%.1f%%", $3/$2 * 100}')
    # -gt stands for "greater than" 
    if [ "${mem_usage%.*}" -gt 90 ];then
    	echo "	Memory: Critial"
    	echo "		Usage excesseds 90%"
    	echo "		Memory Usage: ${mem_usage}"
    else
    	echo "	Memory: Normal"
    fi

    #	Swap:      Normal
    # # swap can use 100% and not be a problem, only is a problem if swap and memory are beyond a threashold
    if [ "${mem_usage%.*}" -gt 90 ] && [ "${swap_used}" -gt 90 ]; then
    	echo "	Swap: Critial"
    	echo "		Swap is full with Memory Usage at a critical state"
    else
    	echo "	Swap: Normal"
    fi

    #	Services:  Normal
    # # if failed serivces are greater than 0 status should "Needs Investigating"
    # # # Print failed serice names 
    failed=$(systemctl --failed --type=service --no-legend | wc -l)
    if [ "${failed%.*}" -gt 0 ]; then
    	echo "	Services: Failed"
    	echo "		There are failed Services"
    else
    	echo "	Services: Normal"
    fi
    
    #   Storage:   Normal
    # # if root storage cross 80% status is warning, if 90% critical. if root is 90% critial failure iminiet. 
    # # Secondary storage can be higher without issue so secondary storage at 90% should be ok. Wont track 
 
    # # In awk, NR==2 means “process only the second line.”
	# # # # NR stands for Number of Records (the current line number).
	# # # # ==2 checks whether the current line number is 2.
    root_usage=$(df -h / | awk 'NR==2 {print $5}' | rev | cut -c 2- | rev)
 	if [ "${root_usage%.*}" -gt 90 ]; then
 		echo "	Storage: Critical"
 		echo "		Root Partition: ${root_usage}%"
 		echo "		Clean Up Root IMMEDIATELY"
 	else
 		echo "	Storage: Normal"
 	fi


	echo "$divider"
}

health_monitor