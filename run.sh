#!/bin/bash

SETT_DAEMON_MODE=1
SETT_DAEMON_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Get real directory if symlink used
if [ -L "${BASH_SOURCE[0]}" ]; then
	realfile=`readlink -f "${BASH_SOURCE[0]}"`
	SETT_DAEMON_PATH="$(dirname $realfile)"
fi

SETT_DAEMON_FOLDER_LOGS="$SETT_DAEMON_PATH/logs"
SETT_DAEMON_LOGS_WORK_FILE="$SETT_DAEMON_FOLDER_LOGS/all.log"
SETT_DAEMON_PID_FILE="$SETT_DAEMON_PATH/pid"

# Additional funcs
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
	resp=`ps aux | grep "start" | grep $1`
	if [ "$resp" != "" ]; then
		eval "$2='1'"
	else
		eval "$2='0'"
	fi
	return
}

# Check utils
check_util "mkdir"
check_util "chmod"
check_util "touch"
check_util "cat"
check_util "kill"
check_util "rm"

# Get real path of each util
get_util "mkdir" UTIL_MKDIR
get_util "chmod" UTIL_CHMOD
get_util "touch" UTIL_TOUCH
get_util "cat" UTIL_CAT
get_util "kill" UTIL_KILL
get_util "rm" UTIL_RM

check() {
	if [ ! -d "$SETT_DAEMON_FOLDER_LOGS" ]; then
		$UTIL_MKDIR "$SETT_DAEMON_FOLDER_LOGS"
		$UTIL_CHMOD 0755 "$SETT_DAEMON_FOLDER_LOGS"
	fi
}

log_str() {
	process=$1
	shift
	log_date=$(date '+%F %T');
	log_string="[$log_date] [$$]: $*"
	echo "$log_string" >> "$SETT_DAEMON_LOGS_WORK_FILE"
}

loop() {
	# Include user scripts
	if [ -d "$SETT_DAEMON_PATH/scripts" ]; then
		for user_script in $SETT_DAEMON_PATH/scripts/*.sh
		do
			. $user_script
		done
	fi
}

start() {
	check
	if [ -f "$SETT_DAEMON_PID_FILE" ]; then
		_pid=`$UTIL_CAT $SETT_DAEMON_PID_FILE`
		is_pid_runned "$_pid" rbool
		if [ "$rbool" = "1" ]; then
			log_str "0" "Daemon already running with pid = $_pid"
			echo "Daemon already running with pid = $_pid"
			exit 0
		fi
	fi
	cd /
	if [ "$SETT_DAEMON_MODE" = 1 ]; then
		exec >> $SETT_DAEMON_LOGS_WORK_FILE
		exec 2>> $SETT_DAEMON_LOGS_WORK_FILE
		exec < /dev/null
		(
			while [ 1 ]
			do
				loop
				sleep 1
			done
			exit 0
		)&
		echo $! > $SETT_DAEMON_PID_FILE
	else
		while [ 1 ]
		do
			loop
			sleep 1
		done
		exit 0
	fi
}

stop() {
	if [ -f "$SETT_DAEMON_PID_FILE" ]; then
		_pid=`$UTIL_CAT $SETT_DAEMON_PID_FILE`
		`$UTIL_KILL $_pid`
		rt="$?"
		if [ "$rt" = "0" ]; then
			log_str "0" "Daemon stoped"
			echo "Daemon stoped"
			`$UTIL_RM $SETT_DAEMON_PID_FILE`
		else
			log_str "0" "Error stop daemon"
			echo "Error stop daemon"
		fi
	else
		log_str "0" "Daemon is not runned"
		echo "Daemon is not runned"
	fi
}

status() {
	if [ -f "$SETT_DAEMON_PID_FILE" ]; then
		_pid=`$UTIL_CAT $SETT_DAEMON_PID_FILE`
		is_pid_runned "$_pid" rbool
		if [ "$rbool" = "1" ]; then
			echo "Daemon is runned with pid = $_pid"
		else
			echo "Daemon is not runned"
		fi
	else
		echo "Daemon is not runned"
	fi
}

update() {
	echo "Update..."
}

usage() {
	echo "$0 (once|start|stop|status)"
}

case $1 in
	"once")
		SETT_DAEMON_MODE=0
		start
		;;
	"start")
		start
		;;
	"stop")
		stop
		;;
	"status")
		status
		;;
	"update")
		update
		;;
	*)
		usage
		;;
esac
exit
