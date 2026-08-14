# Ubunto System Info
# By Daniel Louis
# Created: 08/14/2026
# This Bash Script will output system information for systems running Ubuntu

#Prints the ubuntu version 
lsb_release -a 


# Prints toatl amount of usable memory for the system 
free -h | awk '/^Mem:/ {print "Total Available memory:", $2}'
