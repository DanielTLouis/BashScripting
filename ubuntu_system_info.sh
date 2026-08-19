# Ubunto System Info
# By Daniel Louis
# Created: 08/14/2026
# This Bash Script will output system information for systems running Ubuntu

#output current user 
echo -e "Current User: $USER"

# Give some space
echo 

#Prints the ubuntu version 
echo "Ubuntu Release:"
lsb_release -a 

# Give some space
echo 


# Prints toatl amount of usable memory for the system 
echo "Memory:"
free -h | awk '/^Mem:/ {print "Total Available memory:", $2}'
