#!/bin/sh
SERVIENT_INVOKED_NAME=$0

###################################### INITIALIZATION #############################################
SERVIENT_EXIT_ERROR_SCRIPT_CONFIG=200
SERVIENT_EXIT_UTIL_NOT_SOURCED=230
SERVIENT_EXIT_ERROR_INIT_USER_NOT_ROOT=25
SERVIENT_EXIT_ERROR_FATAL_GENERIC=26
SERVIENT_EXIT_ERROR_FUNC_PLGFNDR=27
SERVIENT_SHOWED_HELP_SCRN=0
SERVIENT_SUCCESS=0
SERVIENT_VERSION_NUMBER="0.4a"
SERVIENT_NON_POSITIONAL_ARGS=""
SERVIENT_OPTION_STRING=":-:d:Df:hm:r:R:s:u:" # TODO: Add time delay 
SERVIENT_LONG_OPTION_STRING="verbose dryrun help"
SERVIENT_verbose_is_set=0
SERVIENT_dryrun_is_set=0
SERVIENT_delay_is_set=0
SERVIENT_debug_is_set=0
SERVIENT_uinfo_file_is_set=0
SERVIENT_uinfo_string_is_set=0
SERVIENT_meta_dir_is_set=0
SERVIENT_ref_path_is_set=0
SERVIENT_result_file_is_set=0
SERVIENT_sol_path_is_set=0
SERVIENT_DEFAULT_VERBOSITY=2
SERVIENT_DEFAULT_DELAY=2
SERVIENT_VAL_VERBOSITY=""
SERVIENT_VAL_DRYRUN=""
SERVIENT_NON_POSITIONAL_ARGS=""
SERVIENT_VAL_DELAY=""
SERVIENT_VAL_DEBUG=""
SERVIENT_VAL_UINFO_FILE=""
SERVIENT_VAL_META_DIR=""
SERVIENT_VAL_REF=""
SERVIENT_VAL_RES_FILE=""
SERVIENT_VAL_SOL=""
SERVIENT_VAL_UINFO_STRING=""
SERVIENT_VAL_TOP_DIR=""
#space seperated list of all options for plugin mode slection
SERVIENT_PLGN_MDSLCT_ALLOPTIONS="PLGN_MDSLCT_ALL PLGN_MDSLCT_UINFO PLGN_MDSLCT_UINFO_FLNM PLGN_MDSLCT_MATCH PLGN_MDSLCT_PRETEST PLGN_MDSLCT_POSTTEST"
SERVIENT_PLGN_UINFO_EXE="unfo"
SERVIENT_PLGN_UINFO_FLNM_EXE="uinfo_gtflnm"
SERVIENT_PLGN_MATCH_EXE="mtch"
SERVIENT_PLGN_PRETEST_EXE="pretst"
SERVIENT_PLGN_POSTTEST_EXE="psttst"
SERVIENT_VAL_UINFOS_FOR_QID=""
SERVIENT_VAL_MATCHS_FOR_QID=""
SERVIENT_VAL_PRETESTS_FOR_QID=""
SERVIENT_VAL_POSTTESTS_FOR_QID=""
####################################### INITIALIZATION ENDS ########################################
SERVIENT_INVOKED_NAME=`echo "$SERVIENT_INVOKED_NAME" |awk -F "/" '{print $NF;}'`
if [ "$SERVIENT_INVOKED_NAME" = "servient_util.sh" ]
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
	# TODO use servient_is_valid_pstv_ntrl_num here
	echo "$1"
}

########################## Function: print_err ##########################################
# Purpose: Prints to the stderr, mainly added because of issues of foregetting toappend	#
#	>2 at end of echo statements.							#
# Argument1: The message to be printed: Mandatory and non-null				#
# Note: This function is used to print to stderr, without consideration to verbsoity 	#
#	level constraint.								#
#########################################################################################
print_err()
{
	echo "$1" >&2
}

########################## Function: print_err_fatal ############################################
# Purpose: Prints to the stderr, mainly added because of issues of foregetting toappend		#
#	>2 at end of echo statements and exits with Argument2, if given				#
# Argument1: The message to be printed: Mandatory and non-null					#
# Argument2: The exit status, needs to be numeric						#
# Note: This function is used to print to stderr, without consideration to verbsoity 		#
#	level constraint.									#
#################################################################################################
servient_print_err_fatal()
{
	FUNC_NAME="servient_print_err_fatal"
	if [ -z "$1" ]
	then
		print_err "[FATAL] $FUNC_NAME did not recieve mandatory argument"
	else
		print_err " [FATAL] $1"
	fi
	if [ -z "$2" ]
	then
		exit $SERVIENT_EXIT_ERROR_FATAL_GENERIC
	else
		# use servient_is_valid_pstv_ntrl_num here
		case "$2" in
		*[!0-9]*) print_err "[FATAL] $FUNC_NAME\'s second argument is not a natural number";exit $SERVIENT_EXIT_ERROR_FATAL_GENERIC;;
    		*) echo -n "" ;;
		esac
		exit $2
	fi
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
	#TODO use servient_is_valid_pstv_ntrl_num here 
	echo "$1" >&2
}

############################Function: servient_show_help_screen #########################
# Purpose: Prints the help information on screen					#
# Arguments: None				 					#
# Notes: None										#
#########################################################################################
servient_show_help_screen()
{
	MY_OPTIONAL_STRING=`echo $SERVIENT_OPTION_STRING | sed 's/^:-://' |sed 's/\([a-zA-Z]\)/\ \1/g' |sed 's/\([a-zA-Z]\)/-\1/g' |sed 's/:/\ OPTION\ /g'`
	MY_LONG_OPTION_STRING=`echo "$SERVIENT_LONG_OPTION_STRING" | awk '{for(i=1;i<=NF;i++){printf "--"$i" "}}'`
	print_err "$0 - $SERVIENT_VERSION_NUMBER"
	print_err "Available options for $0 are $MY_OPTIONAL_STRING $MY_LONG_OPTION_STRING"
}

show_help_screen ()
{
	print_err "[TODO] Replace call to show_help_screen with call to servient_show_help_screen"
	servient_show_help_screen
}

############################Function: servient_check_all_longOpts #######################
# Purpose: Return numerical 1 if all substrings are valid long command line switches, 0	#
#	otherwise.									#
# Arguments: Variable, depends on what is being tested					#
# Notes: None										#
#########################################################################################
servient_check_all_longOpts()
{
	FUNC_NAME="servient_check_all_longOpts"
	if [ ! -z "$1" ]
	then
		OPTIND=1
		while getopts "$SERVIENT_OPTION_STRING" opt; do
			case $opt in
				-)
					case "${OPTARG}" in
						*)
							val=${OPTARG#*=}
							long_opt=${OPTARG%=$val}
							servient_is_tkn_valid_long_opt "$long_opt"
							TEMP=$?
							;;
					esac
			esac
			[ $TEMP -ne 1 ] && break
		done
		if [ ! -z "$long_opt" ]
		then
			servient_is_tkn_valid_long_opt "$long_opt"
			IS_LNG_POS=$?
			if [ $IS_LNG_POS -ne 1 ]
			then
				print_err_verblvl "Unknown long command line switch $long_opt" 
				servient_show_help_screen
				SERVIENT_INVALID_ARGS=1
				exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
		        fi
		fi
		shift `expr $OPTIND - 1`
		echo "$@"
		exit $ERVIENT_SUCCESS 
	fi
	exit $ERVIENT_SUCCESS
}
############################Function: servient_is_tkn_valid_long_opt ####################
# Purpose: Returns numerical 1 if the first argument passed to the function is a valid	#
#	switch for the long command line option.					#
# Arguments: 1: Contains the token that is being checked for validity as a long command	#
#	line option.									#
# Notes: None										#
#########################################################################################
servient_is_tkn_valid_long_opt()
{
	FUNC_NAME="servient_is_tkn_valid_long_opt"
	if [ ! -z "$1" ]
	then
		SERVIENT_VAL=$1
		SERVIENT_VAL=`echo "$SERVIENT_VAL" | sed 's/^[ \t]*//;s/[ \t]*$//'`
		TEMP=`echo "$SERVIENT_LONG_OPTION_STRING" | awk -v OPTION="$SERVIENT_VAL" '{for(i=1;i<=NF;i++){if( (match($i,OPTION)== 1) && (length($i) == length(OPTION)) ){print $i}}}' | wc -l`
		return $TEMP
	fi
	return 0

}
######################### Function:servient_is_set_opt_ref_path #################################################
#Purpose: Returns numerical 1 if reference solution variable is already set.					#
#Arguments: None												#
#################################################################################################################
servient_is_set_opt_ref_path()
{
	if [ -z "$SERVIENT_VAL_REF" ]
	then
		return 0
	else
		return 1
	fi
}
########################## Function:servient_is_set_pros_sol_path ###############################################
#Purpose: Returns numerical 1 if prospective solution variable is already set.					#
#Arguments: None												#
#################################################################################################################
servient_is_set_pros_sol_path()
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
#Notes: 1: Returns non null string only if Argument1 is an absolute path that points to a file. 		#
#	2: Returns null string, if the Argument1 is not an absolute path that points to a file.			#
#################################################################################################################
servient_get_dirname_from_absolute_path()
{
	FUNC_NAME="servient_get_dirname_from_absolute_path"
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
#Purpose: Returns the QID from an absolute path, if the path points to a file. Else an empty string is		#
#	returned. QID does not contain the "basename" of the file (i.e contains no "/" characters)		#
#Arguments: 1: The absolute path of a file.									#
#Notes: 1: Returns non null string only if Argument1 is an absolute path that points to a file. 		#
#	2: Returns null string, if the Argument1 is not an absolute path that points to a file.			#
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
########################## Function:servient_get_qid_from_absolute_path #########################################
#Purpose: Returns the qid from an absolute path, if the path points to a file. Else an empty string is		#
#	returned.									 			#
#Argument1 The absolute path to a file:Mandatory and constrained to be non-null	and an absolute path to a file.	#
#Notes: 1: Returns non null string only if Argument1 is an absolute path that points to a file.			#
#	2: Returns null string, if the Argument1 is not an absolute path that points to a file.			#
#################################################################################################################
servient_get_qid_from_absolute_path()
{
	FUNC_NAME="servient_get_qid_from_absolute_path"
	if [ ! -z "$1" -a -f "$1" ]
	then
		servient_is_path_absolute "$1"
		TEMP=$?
		if [ $TEMP -eq 0 ]
		then   
				print_err_verblvl "[$FUNC_NAME:$1], is not an abosolute path" 5
		fi
		TEMP=$(servient_get_fname_from_absolute_path $1)
		if [ ! -z "$TEMP" ]
		then
			SERVIENT_FILE_PART=`echo "$TEMP" | awk -F "." '{ for (i = 1; i < NF; i++)print $i }'`
			echo "$SERVIENT_FILE_PART"
		fi
		echo ""
	fi
	echo ""
}
########################## Function: servient_is_valid_pstv_ntrl_num  ###########################################
#Purpose: Returns numerical 1, if Argument1 is a valid postive natural number, 0 otherwise.			#
#Argument1: A value: If it is non-null and a postive Natural number returns 1, 0 otherwise.			#
#Notes: Returns 0 if Argument1 is null.										#
#	Function only validates Argument1, and does not actually store Argument1				#
#################################################################################################################
servient_is_valid_pstv_ntrl_num()
{
	if [ ! -z "$1" ]
	then
		SERVIENT_VAL=`echo "$1"|sed 's/^[ \t]*//;s/[ \t]*$//'`
		case "$SERVIENT_VAL" in
		*[!0-9]*) retun 0;;
		esac
		if [ "$SERVIENT_VAL" -gr 0 ]
		then
			return 1
		else
			return 0
		fi
	else
		return 0
	fi
}

########################## Function: servient_is_valid_delay_val ################################################
#Purpose: Returns numerical 1, if Argument1 is a valid value for delay, 0 otherwise.				#
#Argument1: Proposed delay value:Mandatory and constrained to be non-null and a postive Natural number.		#
#Notes: Returns 0 if Argument1 is null.										#
#	Function only validates Argument1, and does not actually store Argument1				#
#################################################################################################################
servient_is_valid_delay_val()
{
	servient_is_valid_pstv_ntrl_num "$1"
	SERVIENT_VAL=$?
	return $SERVIENT_VAL
}
########################## Function: servient_is_valid_uinfo_file ###############################################
#Purpose: Returns numerical 1, if Argument1 is a valid value for user info file, 0 otherwise.			#
#Argument1: Proposed user info file:Mandatory and constrained to be non-null and not contain forward slashes	# 
#		(its relative to each solution directory)							#
#Notes: Returns 0 if Argument1 is null.										#
#	Function only validates Argument1, and does not actually store Argument1				#
#################################################################################################################
servient_is_valid_uinfo_file()
{
	if [ ! -z "$1" ]
	then
		SERVIENT_VAL=`echo "$1"|sed 's/^[ \t]*//;s/[ \t]*$//'`
		if [ ! -z "$SERVIENT_VAL" ]
		then
			No_Slashes=`echo "$SERVIENT_VAL" | awk -F "/" '{print NF;}'`
			if [ "$No_Slashes" -ne 1 ]
			then
				return 0
			else
				return 1	
			fi
		fi
	fi
	return 0
}
########################## Function: servient_is_valid_meta_dir #################################################
#Purpose: Returns numerical 1, if Argument1 is a valid value for meta directory, 0 otherwise.			#
#Argument1: Proposed Path to meta directory :Mandatory and constrained to be non-null, an absolute path to a 	# 
#		directory											#
#Notes: Returns 0 if Argument1 is null.										#
#	Function only validates Argument1, and does not actually store Argument1				#
#################################################################################################################
servient_is_valid_meta_dir()
{
	if [ ! -z "$1" ]
	then
		SERVIENT_VAL=`echo "$1"|sed 's/^[ \t]*//;s/[ \t]*$//'`
		servient_is_path_absolute "$SERVIENT_VAL" 
		TEMP1=$?
		if [ $TEMP1 -eq 0 ]
		then
			return 0
		fi
		if [ $TEMP1 -eq 1 -a ! -d "$SERVIENT_VAL" ]
		then
			return 0
		fi
		return 1
	fi
	return 0
}
########################## Function: servient_is_valid_ref_sol_path #############################################
#Purpose: Returns numerical 1, if Argument1 is a valid value for ref path, 0 otherwise.				#
#Argument1: Proposed Path for reference/solution script(s) :Mandatory and constrained to be non-null, an 	#
#		absolute path to a file/directory.								#
#Notes: Returns 0 if Argument1 is null.										#
#	Function only validates Argument1, and does not actually store Argument1				#
#################################################################################################################
servient_is_valid_ref_sol_path()
{
	if [ ! -z "$1" ]
	then
		SERVIENT_VAL=`echo "$1"|sed 's/^[ \t]*//;s/[ \t]*$//'`
		servient_is_path_absolute "$SERVIENT_VAL" 
		TEMP1=$?
		if [ $TEMP1 -eq 0 ]
		then
			return 0
		fi
		if [ $TEMP1 -eq 1 ] 
		then
			if [ -d "$SERVIENT_VAL" -o -f "$SERVIENT_VAL" ]
			then
				return 1
			else
				return 0
			fi
		fi
		return 0
	fi
	return 0

}
########################## Function: servient_is_valid_result_file ##############################################
#Purpose: Returns numerical 1, if Argument1 is a valid value for result file, 0 otherwise.			#
#Argument1: Proposed Path for result file :Mandatory and constrained to be non-null, an absolute path 		#
#		to a file.											#
#Notes: Returns 0 if Argument1 is null.										#
#	Function only validates Argument1, and does not actually store Argument1				#
#################################################################################################################
servient_is_valid_result_file()
{

	if [ ! -z "$1" ]
	then
		SERVIENT_VAL=`echo "$1"|sed 's/^[ \t]*//;s/[ \t]*$//'`
		servient_is_path_absolute "$SERVIENT_VAL" 
		TEMP1=$?
		if [ $TEMP1 -eq 0 ]
		then
			return 0
		fi
		if [ $TEMP1 -eq 1 ] 
		then
			if [  -f "$SERVIENT_VAL" ]
			then
				rm -f "$SERVIENT_VAL" 2>/dev/null
			else
				return 0
			fi
		fi		
		ERROR_STRING=`touch "$SERVIENT_VAL" 2>&1`
		TEMP1=$?
		if [ $TEMP1 -ne 0 ]
		then
			## This is deliberately placed here
			print_err " Problem creating/acessing [ $SERVIENT_VAL ]"
			print_err "$ERROR_STRING"
			exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
		else
			return 1
		fi
		return 0
	fi
	return 0

}
########################## Function: servient_is_valid_uinfo_str ################################################
#Purpose: Returns numerical 1, if Argument1 is a valid value for Userinfo extraction string, 0 otherwise.	#
#Argument1: Userinfo extraction string :Mandatory and constrained to be non-null, needs to be a valid command 	#
#		line snippet.											#
#Notes: Returns 0 if Argument1 is null.										#
#	Function only validates Argument1, and does not actually store Argument1				#
#################################################################################################################
servient_is_valid_uinfo_str()
{
	if [ ! -z "$1" ]
	then
		SERVIENT_VAL=`echo "$1"|sed 's/^[ \t]*//;s/[ \t]*$//'`
		if [ -z "$SERVIENT_VAL" ]
		then
			return 0
		fi
		SERVIENT_VAL=`echo "$SERVIENT_VAL"|sed 's/^[ \t]*//;s/[ \t]*$//'` 
		SERVIENT_VAL_ERROR=`eval "$SERVIENT_VAL" 2>&1` 
		TEMP1=$?
		if [ $TEMP1 -ne 0 ]
		then
			## This is deliberately placed here
			print_err "Userinfo extraction string [ $SERVIENT_VAL ], does not look like a valid shell snippet"
			print_err "Note:Please escape \" with \\\" in your shell snippet"
			print_err "Note: Your snippet should also return 0 even when invoked in a non-solution directory"
			print_screen "Error Was :: [$SERVIENT_VAL_ERROR]"
			exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
		else
			return 1
		fi
		return 0
	fi
	return 0
}
################################Function:servient_is_valid_qid_syntax############################
#Purpose: To check If a QID is syntactically valid.						#
#Argument1: QID Value: Mandatory and constrained to be non null. It has to start with an 	#
#		alphabet and can contain any character except "/"				#
#Returns: Numerical 1, if Argument1 is a syntactically valid QID 0 otherwise			#
#################################################################################################
servient_is_valid_qid_syntax()
{
	FUNC_NAME="servient_is_valid_qid_syntax"
	if [ ! -z "$1" ]
	then
		TEMP1=0
		SERVIENT_VAL=`echo "$1"|sed 's/^[ \t]*//;s/[ \t]*$//'`
		case "$SERVIENT_VAL" in	
		[a-z]*) TEMP1=1 ;;
		[A-Z]*) TEMP1=1 ;;
		esac
		SERVIENT_VAL=`echo "$SERVIENT_VAL"|tr -d [:alnum:]`
		if [ ! -z "$SERVIENT_VAL" ]
		then
			TEMP1=0
		fi	
		return $TEMP1
	fi
	return 0

}
#########################Function:servient_is_valid_plugin_modeSel###############################
#Purpose: To check if the mode select value given in Argument1 is from a set of valid values	#
#Argument1: ModeSlection: The prospective mode that needs to be searched for a plugin		#
#Returns: Numerical 1, if Argument1 is a valid modeselection value for plugin selection 0 other	#
#		wise.										#
#################################################################################################
servient_is_valid_plugin_modeSel()
{
	FUNC_NAME="servient_is_plugin_modeSel_valid"
	if [ ! -z "$1" ]
	then
		SERVIENT_VAL=$1
		SERVIENT_VAL=`echo "$SERVIENT_VAL" | sed 's/^[ \t]*//;s/[ \t]*$//'`
		for VAL in $SERVIENT_PLGN_MDSLCT_ALLOPTIONS
		do
			if [ "$VAL" = "$SERVIENT_VAL" ]
			then
				return 1
			fi
		done
		return 0
	fi
	return 0

}
