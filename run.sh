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
SETT_OS_TYPE="linux"

# Additional funcs
get_os() {
	OS_TYPE=`uname -a | grep Darwin`
	if [ "$OS_TYPE" != "" ]; then
		eval "$1='mac'"
	else
		eval "$1='linux'"
	fi
}

check_util() {
	util_name="$1"
	
	# Skip for mac
	if [ "$util_name" = "wget" ] && [ "$SETT_OS_TYPE" = "mac" ]; then
		return
	fi

	check=`whereis $util_name`
	if [ "$check" = "" ]; then
		echo "Error: '$util_name' is not found... Fix error and try again!"
		exit
	fi
}

get_util() {
	util_name="$1"
	if [ "$util_name" = "wget" ] && [ "$SETT_OS_TYPE" = "mac" ]; then
		eval "$2='wget'"
		return
	fi
	if [ "$SETT_OS_TYPE" = "mac" ]; then
		resp=`whereis $util_name | awk {'print $1'}`
		eval "$2='$resp'"
		return
	else
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

# Get OS type
get_os SETT_OS_TYPE

# Check utils
check_util "cd"
check_util "cp"
check_util "mkdir"
check_util "chmod"
check_util "touch"
check_util "cat"
check_util "kill"
check_util "rm"
check_util "wget"
check_util "unzip"

# Get real path of each util
get_util "cd" UTIL_CD
get_util "cp" UTIL_CP
get_util "mkdir" UTIL_MKDIR
get_util "chmod" UTIL_CHMOD
get_util "touch" UTIL_TOUCH
get_util "cat" UTIL_CAT
get_util "kill" UTIL_KILL
get_util "rm" UTIL_RM
get_util "wget" UTIL_WGET
get_util "unzip" UTIL_UNZIP

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
	# Get daemon name
	SETT_ITERATOR=1
	SETT_BUFF_NAME=""
	SETT_DAEMON_NAME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
	while IFS='.' read -ra ARRAY; do
		for i in "${ARRAY[@]}"; do
			if [ "$SETT_ITERATOR" -lt "${#ARRAY[@]}" ]; then
				SETT_BUFF_NAME=$SETT_BUFF_NAME$i
			fi
			SETT_ITERATOR=$((SETT_ITERATOR+1))
		done
	done <<< "$SETT_DAEMON_NAME"
	if [ "$SETT_BUFF_NAME" != "" ]; then
		SETT_DAEMON_NAME="$SETT_BUFF_NAME"
	fi

	# Get daemon status
	SETT_DAEMON_STATUS=`$0 status`
	if [ "$SETT_DAEMON_STATUS" != "Daemon is not runned" ]; then
		SETT_DAEMON_STATUS="1"
	else
		SETT_DAEMON_STATUS="0"
	fi

	echo "Downloading..."
	log_str "0" "Downloading..."

	$UTIL_MKDIR "$SETT_DAEMON_PATH/update"
	$UTIL_WGET -q -O "$SETT_DAEMON_PATH/update/daemon.zip" "https://github.com/vladimirok5959/bash-empty-daemon/releases/download/latest/daemon.zip" > /dev/null

	echo "Extracting..."
	log_str "0" "Extracting..."

	$UTIL_UNZIP -o "$SETT_DAEMON_PATH/update/daemon.zip" -d "$SETT_DAEMON_PATH/update" > /dev/null

	echo "Updating..."
	log_str "0" "Updating..."

	if [ "$SETT_DAEMON_STATUS" = "1" ]; then
		$UTIL_CP -f "$0" "$SETT_DAEMON_PATH/xyzcopy.sh"
		$0 stop
	fi

	echo "Updating almost completed"
	log_str "0" "Updating almost completed"

	# Complete
	$SETT_DAEMON_PATH/xyzcopy.sh xyzcopy $SETT_DAEMON_NAME&
}

xyzcopy() {
	if [ ! -d "$SETT_DAEMON_PATH/update" ]; then
		log_str "0" "Something wrong, updating not completed!"
		exit
	fi

	# Delay before replace
	sleep 1

	SETT_DAEMON_NAME="$2"

	log_str "0" "Replacing started... ($SETT_DAEMON_NAME)"
	#$UTIL_CP -f "$0" "$SETT_DAEMON_PATH/update/run.sh"
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
	"xyzcopy")
		xyzcopy
		;;
	*)
		usage
		;;
esac
exit
