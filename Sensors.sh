#!/bin/bash


address="8.8.8.8"
root_partition="/dev/nvme0n1p7" # needed for free space
d_partition="/dev/nvme0n1p4" # needed for free space
disk_device="nvme0n1" # needed for iostat!






argument=$1








#########################memory field!
                                  if [ "$argument" == "memory" ] ; then

memory_all=$(free -m | grep Mem)

total_mem=$(printf "$memory_all"  |  grep Mem |  awk '{print $2}' )

#echo $total_mem

total_mem_used=$(printf "$memory_all"  |  grep Mem |  awk '{print $3}' )

printf " Used Memory: $total_mem_used/$total_mem"

                                 # fi
#####################end of memory field!!!!

#########################################ping section################
                                    elif [ "$argument" == "ping" ] ; then
                                    fping -c1 -t500  $address > IPoutput 2>&1
                if [ $?  -eq "0" ]; then
ping_time=$(ping -c 4 $address | tail -1| awk '{print $4}' | cut -d '/' -f 2 | cut -d '.' -f 1)
echo "Ping: $ping_time ms"
else
echo "No Internet"
                fi

###################end of ping section!##########################################

##############################begin of IP Section##########

elif [ "$argument" == "ip" ] ; then
ip=$(hostname -I | awk -v N=$1 '{print $1}')
echo $ip

################################end of IP section################################








##################begin of free space###########################################

elif [ "$argument" == "free_space" ] ; then
free_space_everything=$(df)

#echo "$free_space_everything"

free_space_home=$(echo "$free_space_everything" | grep  $root_partition | awk -v N=$5 '{print $5}')

#echo $free_space_home

free_space_d=$(echo "$free_space_everything" | grep  $d_partition | awk -v N=$5 '{print $5}')
#echo $free_space_d

echo "Free space: /  $free_space_home D $free_space_d"


#############################end of free space####################################

##############################begin of sensors##############
elif [ "$argument" == "sensors" ] ; then
#echo sensors
#get_sensor_data=$(sensors)
#cpu_temp=$(echo "$get_sensor_data" | grep Package | awk -v N=$4 '{print $4}' |  tr -d '+' )
#echo "$cpu_temp"
cpu_temp=$(echo "scale=1; $(cat /sys/class/hwmon/hwmon5/temp1_input)/1000" | bc)

#echo $cpu_temp
#ssd_temp=$(echo "$get_sensor_data" | grep Composite | awk -v N=$2 '{print $2}' |  tr -d '+' )
ssd_temp=$(echo "scale=1; $(cat /sys/class/hwmon/hwmon3/temp1_input)/1000" | bc)
#echo $ssd_temp
#getting fan speed!
fan_speed=$(cat /sys/class/hwmon/hwmon5/fan1_input)
# this works for me. to find out what works dor you,
# you need to install lm-sensors and strace sensors &> sensors.txt . then look for the path of the fan speed!


#echo $ssd_temp

echo "SSD Temp: $ssd_temp °C""   " "CPU Temp: $cpu_temp °C "  " Fan: $fan_speed RPM"


##############################end of sensors#################

#############################begin of ssd life level!###############
                     elif [ "$argument" == "ssd_life" ] ; then
ssd_wear_level=$(sudo smartctl -a /dev/nvme0 | grep "Percentage Used: " | egrep -o '[0-9.]+' |  tr -d ' ')
#echo "$ssd_wear_level"
Remaining_life=$((100-$ssd_wear_level))
echo "SSD Life: $Remaining_life %"

############################end of ssd wear level####################

##########################begin of battery voltage############

elif [ "$argument" == "battery_voltage" ] ; then
battery_voltage=$(cat  /sys/class/power_supply/BAT0/voltage_now)

decimal=$(echo "scale=3; $battery_voltage / 1000000" | bc)

volts=$(printf "%.3f" $decimal)
echo $volts V


#######################end of battery voltage#################################
elif [ "$argument" == "" ] ; then

echo : Arguments:
echo : memory - prints the available memory/installed memory
echo : ping - prints the ping time, on average
echo : free_space - prints free space on home and on defined partition!
echo : sensors - prints cpu and ssd temp
echo : ssd_life - prints ssd remaining life
echo : battery_voltage - prtints the battery voltage
echo : ip - prints the ip

echo remember to set the ping address, root partion and second partition in order to get good indications!

fi # end of final if!




