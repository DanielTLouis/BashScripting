# Ubunto System Info
# By Daniel Louis
# Created: 08/14/2026
# This Bash Script will output system information for systems running Ubuntu

## !! Run this in Sublime Editor with 'CTRL + B'

#output current user 
#echo -e "Current User: $USER"

# Give some space
#echo 

#Prints the ubuntu version 
echo "Ubuntu Release:"
lsb_release -a 

# Give some space
#echo 


# Prints total amount of usable memory for the system 
#echo "Memory:"
#free -h | awk '/^Mem:/ {print "Total Available memory:", $2}'

# Prints the search path to indicate where applications are located 
#echo $PATH


system_info()
{
	echo "==============================================="
	echo "=           UBUNTU SYSTEM INFORMATION         ="
	echo "==============================================="

	echo 
	echo "[ SYSTEM ]"
	echo 
	#Distribution name 
	distribution=$(lsb_release -a 2>/dev/null | grep "Distributor" | cut -f2)
		# 2>/dev/null will send the error stream to null instead of stdout, to avoid the line "No LSB modules are available." from being printed
	echo "Distribution Name: $distribution"
	#Ubuntu version
	version=$(lsb_release -a 2>/dev/null | grep "Description" | cut -f2)
	echo "Version: $version"
	#Release/codename
	release=$(lsb_release -a 2>/dev/null | grep "Release" | cut -f2)
	echo "Release: $release"
	#Kernel version
	kernel=$(uname -r)
	echo "Kernel Version: $kernel"
	#System architecture
	sys_arc=$(uname -m)
	echo "System Architecture: $sys_arc"
	#Hostname
	hostname=$(hostname)
	echo "Hostname: $hostname"
	#System uptime
	uptime=$(uptime | cut -d, -f1)
	echo "System Uptime: $uptime"

	echo 
	echo "[ HARDWARE ]"
	echo 

	echo 
	echo "[ MEMORY ]"
	echo 

	echo
	echo "[ STORAGE ]"
	echo 
}

system_info 