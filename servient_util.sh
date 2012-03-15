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
# Purpose: Prints to the stdout, after talking into account verbosity/log level.	#
# Arguments: 1: The message string to be printed on stdout.				#
# 	2: The optional non default message verbosity level required to be required	#
#	to print the message								#
# Note: If Argument 2 is not passed, the default verbosity level is assumed to have been#
#	passed during invocation.							#
#########################################################################################
print_screen()
{
	#TODO
	echo "$1"
}

########################## Function: print_err ##########################################
# Purpose: Prints to the stderr, mainly added because of issues of foregetting toappend	#
#	>2 at end of echo statements.							#
# Arguments: 1: The message to be printed						#
# Note: This function is used to print to stderr, without consideration to verbsoity 	#
#	level constraint.								#
#########################################################################################
print_err()
{
	echo "$1" >&2
}

########################## Function: print_err_verblvl ##################################
# Purpose: Prints to the stderr, after talking into account verbosity/log level. Mainly	#
#	added because of issues of foregetting toappend	>2 at end of echo statements. 	#
# Arguments: 1: The message string to be printed on stderr.				#
# 	2: The optional non default message verbosity level required to be required	#
#	to print the message								#
# Note: If Argument 2 is not passed, the default verbosity level is assumed to have been#
#	passed during invocation.							#
#########################################################################################
print_err_verblvl()
{
	#TODO
	echo "$1" >&2
}
######################### Function:servient_is_set_opt_ref_dir ##################################################
#Purpose: Returns numerical 1 if reference solution variable is already set.					#
#Arguments: None												#
#################################################################################################################
servient_is_set_opt_ref_dir()
{
	if [ -z "$SERVIENT_VAL_REF" ]
	then
		return 0
	else
		return 1
	fi
}
########################## Function:servient_is_set_pros_sol_dir ################################################
#Purpose: Returns numerical 1 if prospective solution variable is already set.					#
#Arguments: None												#
#################################################################################################################
servient_is_set_pros_sol_dir()
{
	if [ -z "$SERVIENT_VAL_SOL" ]
	then
		return 0
	else
		return 1
	fi
}
########################## Function: servient_is_path_absolute ##################################################
#Purpose: Returns numerical 1, if the first argument passed to the function is  an absolute path 0 otherwise.	#
#Arguments: 1, The path string to be tested to see if it is an absolute path.					#
#Notes: None													#
#################################################################################################################
servient_is_path_absolute()
{
	absolute=0
	if [ ! -z "$1" ]
	then   
		#Function returns 1 if path is absolute else 0
		if echo $1 | grep '^/' > /dev/null
		then   
			absolute=1
		fi
	fi
	return $absolute
}

########################## Function:servient_get_file_absolute_basename #########################################
#Purpose: Returns the absolute path of the directory a file resides in, only if its an absolute path. Else an 	#
#	empty string is returned.									 	#
#Arguments: 1: The absolute path of a file.									#
#Notes: 1: Returns non null string only if the resolved directory is only of the type directory.		#
#	2: Returns null string, if the argument 1 is not of the type file.					#
#################################################################################################################
servient_get_file_absolute_dirname()
{
	FUNC_NAME="servient_get_file_absolute_dirname"
	if [ ! -z "$1" -a -f "$1" ]
	then
		servient_is_path_absolute "$1"
		TEMP=$?
		if [ $TEMP -eq 0 ]
		then   
				print_err_verblvl "[$FUNC_NAME:$1], is not an abosolute path" 5
		fi
		TEMP=`echo "$1" |awk -F "/"  '{ for (i = 1; i < NF; i++) {printf $i"/"} print ""; }'`
		if [ -d "$TEMP" ] 
		then
			echo "$TEMP"
		fi
	fi
	echo ""
}
########################## Function:servient_get_fname_from_absolute_path #######################################
#Purpose: Returns the file name from an absolute path, if the path points to a file. Else an empty string is  	#
#	returned.									 			#
#Arguments: 1: The absolute path of a file.									#
#Notes: 1: Returns non null string only if the file name path of an absolute path.				#
#	2: Returns null string, if the argument 1 is not of the type file.					#
#################################################################################################################
servient_get_fname_from_absolute_path()
{
	FUNC_NAME="servient_get_fname_from_absolute_path"
	if [ ! -z "$1" -a -f "$1" ]
	then
		servient_is_path_absolute "$1"
		TEMP=$?
		if [ $TEMP -eq 0 ]
		then   
				print_err_verblvl "[$FUNC_NAME:$1], is not an abosolute path" 5
		fi
		TEMP=`echo "$1" |awk -F "/" '{print $NF;}'`
		echo "$TEMP"
	fi
	echo ""
}
