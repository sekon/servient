#!/bin/sh
SERVIENT_INVOKED_NAME=$0
SERVIENT_EXIT_UTIL_NOT_SOURCED=230
SERVIENT_INVOKED_NAME=`echo "$SERVIENT_INVOKED_NAME" |awk -F "/" '{print $NF;}'`
if [ "$SERVIENT_INVOKED_NAME" == "servient_util.sh" ]
then
	echo "You can only source this shell script" >&2
	exit $SERVIENT_EXIT_UTIL_NOT_SOURCED
fi

call_valid_ps_with_args()
{
	SERVIENT_PS_COMMAND_ARGS="ps aux"
	$SERVIENT_PS_COMMAND_ARGS 2>/dev/null 1>/dev/null 
	PS_STATUS=$?
	if [ $PS_STATUS -eq 1 ]
	then
		SERVIENT_PS_COMMAND_ARGS="ps"
	fi
}

########################## Function: print_screen #######################################
# Purpose: Prints to the stdout, after talking into account verbosity,log level,etc.	#
# Arguments: TBD									#
# Note: None										#
#########################################################################################
print_screen()
{
	echo "$*"
}

########################## Function: print_err ##########################################
# Purpose: Prints to the stderr, mainly added because of issues with appending >2 at 	#
# end. Please Note that there are no logging levels, verbosity for stderr stream.	#
# Arguments: TBD									#
# Note: None										#
#########################################################################################
print_err()
{
	echo "$*" >&2
}
