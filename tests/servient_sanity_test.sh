#!/bin/sh
## First check if you have all the required shell commands
COMMANDS="awk cut dirname expr find grep id ls ps rm sed wc"
## Dont check for shell builtins
for COMMAND in $COMMANDS
	do
		echo "Checking for [$COMMAND]"
		which $COMMAND 2>&1 1>/dev/null
		if [ $? -ne 0 ]
			echo "Cant seem to find $COMMAND in $PATH"
		fi
	done
sh -x ../src/servient.sh
if [ $? -ne 0 ]
then
	echo "Problem running servient.sh in sh, please take some time out to file a bug report"
fi
