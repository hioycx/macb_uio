#!/bin/bash

driver_supported=("macb_uio" "pdev_uio" "macb")

print_err() {
	printf "Error: argument error\n"
	printf "Usage: ${0##*/} [-h|--help] [-q INTERFACE] [--query INTERFACE] [-b DRIVER DEVICE] [--bind DRIVER DEVICE] [-u DEVICE] [--unbind DEVICE]\n"
}

print_usage() {
	printf "Usage: ${0##*/} [-h|--help] [-q INTERFACE] [--query INTERFACE] [-b DRIVER DEVICE] [--bind DRIVER DEVICE] [-u DEVICE] [--unbind DEVICE]\n"
	printf "\nUtility to bind and unbind platform devices from Linux kernel\n"
	printf "\npositional arguments:\n"
	printf "\tDEVICE\t\t\tPlatform device can be queried through the interface\n"
	printf "\noptional arguments:\n"
	printf "\t-h, --help\t\tshow this help message and exit\n"
	printf "\t-q, --query\t\tquery the platform device corresponding to the interface\n"
	printf "\t-b, --bind\t\tselect the driver to use by device\n"
	printf "\t-u, --unbind\t\tunbind a device\n"
	printf "\nExamples:\n----------\n"
	printf "\nTo query which platform device is used by the interface eth0:\n\t${0##*/} --query eth0\n"
	printf "\nTo bind platform device (eg: 3200c000.ethernet) from the current driver to macb_uio\n\t${0##*/} --bind macb_uio 3200c000.ethernet\n"
	printf "\nTo unbind 3200c000.ethernet from using any driver:\n\t${0##*/} --unbind 3200c000.ethernet\n"
	exit
}

query() {
	if [ ! -d "/sys/class/net/$1/" ];then
		echo "There is no interface named $1"
		exit
	fi
	device=$(readlink /sys/class/net/$1/device | awk -F"/" '{print $NF}')
	if [ ! -d /sys/bus/platform/devices/$device ];then
		echo "The interface $1 is not a platform device"
		exit
	fi
	printf "%-12s %-8s\n" INTERFACE DEVICE
	printf "%-12s %-8s\n" $1 $device
	exit
}

pdev_bind() {
	if [[ ! $(echo "${driver_supported[@]}" | grep -w $1) ]];then
		echo "The driver $1 is not supported"
		exit
	fi
	if [ ! -d /sys/bus/platform/drivers/$1 ];then
		echo "The driver $1 is not loaded"
		exit
	fi
	if [ ! -d /sys/bus/platform/devices/$2 ];then
		echo "There is no platform device named $2"
		exit
	fi
	if [ -d /sys/bus/platform/devices/$2/driver ];then
		echo $2 > /sys/bus/platform/devices/$2/driver/unbind
	fi
	echo $1 > /sys/bus/platform/devices/$2/driver_override
	echo $2 > /sys/bus/platform/drivers/$1/bind
	echo "Successfully bind platform device $2 to driver $1"
	exit
}

pdev_unbind() {
	if [ ! -d /sys/bus/platform/devices/$1 ];then
		echo "There is no platform device named $1"
		exit
	fi
	if [ -d /sys/bus/platform/devices/$1/driver ];then
		echo $1 > /sys/bus/platform/devices/$1/driver/unbind
	fi
	echo "" > /sys/bus/platform/devices/$1/driver_override
	echo "Successfully unbind platform device $1"
	exit
}

if [[ "$1" == "-h" || "$1" == "--help" ]];then
	print_usage
fi

if [[ "$#" -eq 2 && ("$1" == "-q" || "$1" == "--query") ]];then
	query $2
fi

if [[ "$#" -eq 3 && ("$1" == "-b" || "$1" == "--bind") ]];then
	pdev_bind $2 $3
fi

if [[ "$#" -eq 2 && ("$1" == "-u" || "$1" == "--unbind") ]];then
	pdev_unbind $2
fi

print_err
exit
