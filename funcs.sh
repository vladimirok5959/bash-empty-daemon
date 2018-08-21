#!/bin/sh

check_util() {
	util_name="$1"
	check=`whereis $util_name`
	if [ "$check" = "" ]; then
		echo "Error: '$util_name' is not found... Fix error and try again!"
		exit
	fi
}

get_util() {
	util_name="$1"
	IS_MAC_OS=`uname -a | grep Darwin`
	if [ "$IS_MAC_OS" != "" ]; then
		# Mac OS X
		resp=`whereis $util_name | awk {'print $1'}`
		eval "$2='$resp'"
		return
	else
		# Linux
		resp=`whereis $util_name | awk {'print $2'}`
		eval "$2='$resp'"
		return
	fi
	eval "$2=''"
	return
}

is_pid_runned() {
	resp=`ps aux | grep ".sh start" | grep $1`
	if [ "$resp" != "" ]; then
		eval "$2='1'"
	else
		eval "$2='0'"
	fi
	return
}
