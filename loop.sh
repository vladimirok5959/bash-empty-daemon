#!/bin/bash

if [ -d "$SETT_DAEMON_PATH/scripts" ]; then
	for user_script in $SETT_DAEMON_PATH/scripts/*.sh
	do
		. $user_script
	done
fi
