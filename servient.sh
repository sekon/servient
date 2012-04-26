#!/bin/sh 
#################################################################################################
#Purpose: <To be done>										#
#Primary Author: Harish Badrinath < harish [at] fossee.in>					#
#Taken Over date/Creation date: Sun, 06 Nov 2011 21:38:58 +0530					#
#Taken Over by:											#
#Taken Over date:										#
#Date of last commit:Mon, 26 Dec 2011 18:10:41 +0530						#
#License: GPL V3 +										#
#Internal Version Number: See $SERVIENT_VERSION_NUMBER 						#
#################################################################################################

SERVIENT_INSTALL_DIR="$PWD" ## TODO :: Make the install script change this to install location.

source "$SERVIENT_INSTALL_DIR"/servient_util.sh

####################################### CONFIG DATA #############################################
SERVIENT_EXIT_ERROR_SCRIPT_CONFIG=200
SERVIENT_EXIT_ERROR_INIT_USER_NOT_ROOT=25
SERVIENT_EXIT_ERROR_FATAL_GENERIC=26
SERVIENT_EXIT_ERROR_FUNC_PLGFNDR=27
SERVIENT_VERSION_NUMBER="0.4a"
SERVIENT_NON_POSITIONAL_ARGS=""
SERVINET_NO_NPARGS=0
SERVIENT_OPTION_STRING=":-:d:Df:hm:r:R:s:u:" # TODO: Add time delay 
SERVIENT_verbose_is_set=0
SERVIENT_delay_is_set=0
SERVIENT_debug_is_set=0
SERVIENT_uinfo_file_is_set=0
SERVIENT_uinfo_string_is_set=0
SERVIENT_meta_dir_is_set=0
SERVIENT_ref_dir_is_set=0
SERVIENT_result_file_is_set=0
SERVIENT_sol_dir_is_set=0
SERVIENT_DEFAULT_VERBOSITY=2
SERVIENT_DEFAULT_DELAY=2
SERVIENT_VAL_VERBOSITY=""
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

####################################### CONFIG DATA ENDS ########################################

##TODO: Get a list of all variables in a bash script.
# VARIABLES=$(echo "compgen -A variable" >> "$PLUGIN_FILE" ;source "$PLUGIN_FILE";sed -i '$d' "$PLUGIN_FILE")
# echo "$VARIABLES" | grep <PAttern>
# even if $PLUGIN_FILE redefines/rewrites variables .. it wont be seen here even when the script is being sourced.


get_user_id () 
{
	## TODO Clean this up .. really needs to be done more elegantly
	if [ -f "$SERVIENT_VAL_UINFO_FILE" ]
	then
		MY_UID=`cat "$DIR/$SERVIENT_VAL_UINFO_FILE" | grep -w "$SERVIENT_VAL_UINFO_STRING" | cut -d ":" -f 2 |sed 's/^[ \t]*//;s/[ \t]*$//'`
		# TODO: remove grep -w
		IS_UNIQ=`cat "$DIR/SERVIENT_VAL_UINFO_FILE" | grep -w "$SERVIENT_VAL_UINFO_STRING" | cut -d ":" -f 2 |sed 's/^[ \t]*//;s/[ \t]*$//'|wc -l`
		# TODOL remove grep -w
		if [ "$IS_UNIQ" -ne "1" ]
		then
			if (( $VERBOSE_OUTPUT ))
			then
				print_screen "$DIR/$SERVIENT_VAL_UINFO_FILE does not look valid or $SERVIENT_VAL_UINFO_STRING is not unique"
			fi
			exit 205 ## TODO use exit, with more consistency with the rest of document.
		else
			echo "$MY_UID"	
		fi
	else
		echo -n ""
	fi
} 
########################## Function: is_path_absolute ###########################################################
#Purpose: Returns numerical 1, if the first argument passed to the function is 	an absolute path 0 otherwise.	#
#Arguments: 1, The path string to be tested to see if it is an absolute path.					#
#Notes: None													#
#################################################################################################################
is_path_absolute()
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
TEMP=-1
TEMP=`id | cut -d " " -f 1 | sed 's/\(^.*\)\((.*)\)/\1/' | sed 's/uid=//'`
IS_ROOT=0
if [ $TEMP -eq 0 ]
then
	IS_ROOT=1
fi

show_help_screen ()
{
	MY_OPTIONAL_STRING=`echo $SERVIENT_OPTION_STRING | sed 's/^:-://' |sed 's/\([a-zA-Z]\)/\ \1/g' |sed 's/\([a-zA-Z]\)/-\1/g' |sed 's/:/\ OPTION\ /g'`
	print_screen "$0 - $SERVIENT_VERSION_NUMBER"
	print_screen "Available options for $0 are $MY_OPTIONAL_STRING" "--verbose[=VALUE] --help"
}


#Special thanks to http://wiki.bash-hackers.org/howto/getopts_tutorial, for the awesome tutorial.
# and http://stackoverflow.com/questions/402377/using-getopts-in-bash-shell-script-to-get-long-and-short-command-line-options/7680682#7680682

process_arguments()
{
        OPTIND=1
	while getopts "$SERVIENT_OPTION_STRING" opt; do
		case $opt in
			-)
				case "${OPTARG}" in
					verbose)
						if (( ! $SERVIENT_verbose_is_set ))
						then
							#Called only when --verbose is called ..
							SERVIENT_verbose_is_set=1
							SERVIENT_VAL_VERBOSITY=$SERVIENT_DEFAULT_VERBOSITY
						else
							print_err "More than one instance of ${OPTARG} given during invocation"
							exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
						fi
						;;
					verbose=*)
						if (( ! $SERVIENT_verbose_is_set ))
						then
							val=${OPTARG#*=}
							opt=${OPTARG%=$val}
							print_err "Parsing option: '--${opt}', value: '${val}'"
							SERVIENT_verbose_is_set=1
							if ( [ $val -gr 1 ] && [ $val -le 5 ] )
							then
								SERVIENT_VAL_VERBOSITY=$val
							else
								print_err "verbose level should be a positive number, which is greater than 0 but lesser than 5 !!"
								exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
							fi
						else
							print_err "More than one instance of ${OPTARG} given during invocation"
							exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
						fi
						;;
					help)
						if [ $# -eq 1 ]
						then
							show_help_screen
						else
							print_err "Option ${OPTARG} needs to be the only argument" 
							exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
						fi
						;;
					*)
						TEMP=`echo "$SERVIENT_OPTION_STRING" | cut -c 1`
						if [ "$OPTERR" = 1 ] && [ "$TEMP" != ":" ]
						then
							print_err "Unknown option --${OPTARG}"
						fi
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
						;;
					esac
				;;
			d)
				if (( ! $SERVIENT_delay_is_set ))
				then
					OPTARG=`echo $OPTARG|sed 's/^[ \t]*//;s/[ \t]*$//'`
					SERVIENT_delay_is_set=1
					if [ $SERVIENT_VAL_DELAY -gr 0 ]
					then
						SERVIENT_VAL_DELAY=$OPTARG
					else
						print_err "delay should be a postive number, which is greater than zero"
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
					fi
				else
					print_err "More than one instance of $opt given during invocation"
					exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
				fi
				;;
			D)
				if (( ! $SERVIENT_debug_is_set ))
				then
					print_err "-D was trigerred, you have enabled bash debugging"
					SERVIENT_debug_is_set=1
					$SERVIENT_VAL_DEBUG=1
				else
					print_err "More than one instance of $opt given during invocation"
					exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
				fi
				;;
			f)
				if (( ! $SERVIENT_uinfo_file_is_set ))
				then
					OPTARG=`echo $OPTARG|sed 's/^[ \t]*//;s/[ \t]*$//'`
					SERVIENT_uinfo_file_is_set=1
					if [ ! -z "$OPTARG" ]
					then
						No_Slashes=`echo "$OPTARG" | awk -F "/" '{print NF;}'`
						if [ "$No_Slashes" -ne 1 ]
						then
							No_Slashes=0
						fi
						if [ $No_Slashes -eq 1 ]
						then
							$SERVIENT_VAL_UINFO_FILE=$OPTARG ## This should only be file names 
						else
							print_err "[ $opt ] was given [ $OPTARG] as argument"
							print_err "It must not contains \"/\", as i refers to a file in each directory of interest"
							exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
						fi
					else
						print_err "delay should be a postive number, which is greater than zero"
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
					fi
				else
					print_err "More than one instance of $opt given during invocation"
					exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
				fi
				;;
			h)
				if [ $# -eq 1 ]
				then
					show_help_screen
				else
					print_err "Option ${OPTARG} needs to be the only argument"
					exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
				fi
				;;
			m)
				if (( ! $SERVIENT_meta_dir_is_set ))
				then
					OPTARG=`echo $OPTARG|sed 's/^[ \t]*//;s/[ \t]*$//'`
					SERVIENT_meta_dir_is_set=1
					is_path_absolute "$OPTARG" 
					TEMP=$?
					if [ $TEMP -eq 0 ]
					then
						print_err "[ $OPTARG ], an arg for $opt should be a directory and an absolute path" 
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG ## ## *Dont* use brackets around exit
					fi
					if [ $TEMP -eq 1 -a ! -d "$OPTARG" ]
					then
						print_err "[ $OPTARG ], an arg for $opt should be a directory and an absolute path " 
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG ## ## *Dont* use brackets around exit
					fi
					SERVIENT_VAL_META_DIR="$OPTARG"	
				else
					print_err "More than one instance of $opt given during invocation"
					exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
				fi
				;;
			r)
				if (( ! $SERVIENT_ref_dir_is_set ))
				then
					OPTARG=`echo $OPTARG|sed 's/^[ \t]*//;s/[ \t]*$//'`
					SERVIENT_ref_dir_is_set=1
					is_path_absolute "$OPTARG" 
					TEMP=$?
					if [ $TEMP -eq 0 ]
					then
						print_err "[ $OPTARG ], an arg for $opt should be a directory and an absolute path " 
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG ## ## *Dont* use brackets around exit
					fi
					if [ $TEMP -eq 1 -a ! -d "$OPTARG" ] 
					then
						print_err "[ $OPTARG ], an arg for $opt should be a directory and an absolute path " 
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG ## ## *Dont* use brackets around exit
					fi
					SERVIENT_VAL_REF="$OPTARG"	
				else
					print_err "More than one instance of $opt given during invocation"
					exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
				fi
				;;
			R)
				if (( ! $SERVIENT_result_file_is_set ))
				then
					OPTARG=`echo $OPTARG|sed 's/^[ \t]*//;s/[ \t]*$//'`
					SERVIENT_result_file_is_set=1
					is_path_absolute "$OPTARG" 
					TEMP=$?
					if [ $TEMP -eq 0 ]
					then
						print_err "[ $OPTARG ], an arg for $opt should be a directory and an absolute path " 
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG ## ## *Dont* use brackets around exit
					fi
					if [ $TEMP -eq 1 -a ! -f "$OPTARG" ] 
					then
						print_err "[ $OPTARG ], an arg for $opt should be a file and an absolute path " 
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG ## ## *Dont* use brackets around exit
					fi
					ERROR_STRING=`touch "$OPTARG" 2>&1`
					TEMP=$?
					if [ $TEMP -ne 0 ]
					then
						print_err " Problem creating/acessing [ $OPTARG ]"
						print_err "$ERROR_STRING"
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
					fi
					SERVIENT_VAL_RES_FILE="$OPTARG"
				else
					print_err "More than one instance of $opt given during invocation"
					exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
				fi
				;;
			s)
				if (( ! $SERVIENT_sol_dir_is_set ))
				then
					OPTARG=`echo $OPTARG|sed 's/^[ \t]*//;s/[ \t]*$//'`
					SERVIENT_sol_dir_is_set=1
					is_path_absolute "$OPTARG" 
					TEMP=$?
					if [ $TEMP -eq 0 ]
					then
						print_err "[ $OPTARG ], an arg for $opt should be a directory and an absolute path " 
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG  ## ## *Dont* use brackets around exit
					fi
					if [ $TEMP -eq 1 -a ! -d "$OPTARG" ] 
					then
						print_err "[ $OPTARG ], an arg for $opt should be a directory and an absolute path " 
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG ## ## *Dont* use brackets around exit
					fi
					SERVIENT_VAL_SOL="$OPTARG"
				else
					print_err "More than one instance of $opt given during invocation"
					exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
				fi
				;;
			u)
				if (( ! $SERVIENT_uinfo_string_is_set ))
				then
					OPTARG=`echo $OPTARG|sed 's/^[ \t]*//;s/[ \t]*$//'`
					SERVIENT_uinfo_string_is_set=1
					if [ -z "$OPTARG" ]
					then
						print_err "Userinfo extraction string [ $OPTARG ], cant be empty"
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
					fi
					OPTARG=`echo $OPTARG|sed 's/^[ \t]*//;s/[ \t]*$//'` 
					ERROR_STRING=`eval "$OPTARG" 2>&1` 
					SERVIENT_VAL_UINFO_STRING="$OPTARG"
					TEMP=$?
					if [ $TEMP -ne 0 ]
					then
						print_err "Userinfo extraction string [ $OPTARG ], does not look like a valid shell snippet"
						print_err "Note:Please escape \" with \\\" in your shell snippet"
						print_err "Note: Your snippet should also return 0 in a non-solution directory (sorry this is a necessary constraint"
						print_screen "$ERROR_STRING"
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
					fi
				else
					print_err "More than one instance of $opt given during invocation"
					exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
				fi
				;;
			\?)
				print_err "Invalid option: -$OPTARG"
				exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
				;;
			:)
				print_err "Option -$OPTARG requires an argument."
				exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
				;;
			esac
	done
	shift `expr $OPTIND - 1`
	echo "$@"
}
######################Function:servient_plugin_finder############################################################
#Purpose:Loads scripts at runtime to dynamically modify the behaviour of servient at runtime.			#
#Argument1: QID: Mandatory and constrained to be non null, no checks are done to validate QID 			#
#Argument2: Reference path: Mandatory and constrained to be non null and an absolute path that points to either	#
#	     to a file or directory.										#
#Argument3: Meta Directory path: Mandatory and constrained to be non null and an absolute path that points to 	#
#	    a directory.											#
#Argument4: Prospective solution Directory path: Mandatory and constrained to be non null and an absolute path 	#
#	    that points to a file or directory									#
#Argument5: Type of behaviour to overload: Mandatory and case sensetive. Constained to be a valid choice from	#
#	    the list given below: 										#
#	     TODO: PUT LIST											#
#Returns: The value depends mainly on argument 5								#
#	  TODO: TBD												#
#Notes: No un-unnecessary checks are done in this function to verify that the Argument set (Argument1, Argument2#
#		Argument3,Argument4) actually points to a valid question tuple.					#
#	Any script selected by this function can force default behaviour for the behaviour it was supposed to	#
#		modify  by returning -1										#
#														#
#################################################################################################################
servient_plugin_finder()
{
	if [ -z "$1" ]
	then
		servient_print_err_fatal "Mandatory argument QID not given" $SERVIENT_EXIT_ERROR_FUNC_PLGFNDR
	fi
#	if 
}
SERVIENT_ARGS="$@"
while [ ! -z "$SERVIENT_ARGS" ]
do
	SERVIENT_ARGS=$(process_arguments $SERVIENT_ARGS)
	TEMP=`echo "$SERVIENT_ARGS" | awk -F " " '{print $1}'`
	IS_POS=`echo $OPTION_STRING | sed 's/^:-://' |sed 's/\([a-zA-Z]\)/\ \1/g' |sed 's/\([a-zA-Z]\)/-\1/g' |sed 's/://g' | awk -v OPTION=$TEMP '{for(i=1;i<=NF;i++){if( (match($i,OPTION)== 1) && (length($i) == length(OPTION)) ){print $i}}}' | wc -l`
	## The awk magic is quivalent to grep -w "-OPTIONCHAR" (Please note the trailing '-' character behind OPTIONCHAR)
	## IS_POS tells if the first element in a spave sperated string of args is a postional argument or not.
	[ $IS_POS -eq 0 ] &&  SERVIENT_NON_POSITIONAL_ARGS="$SERVIENT_NON_POSITIONAL_ARGS $TEMP"
	T_SARRAY=""
	for ARG in $SERVIENT_ARGS
	do
		[ $IS_POS -eq 0 ] && [ "$TEMP" == "$SERVIENT_ARG" ] && continue
		T_SARRAY="$T_SARRAY $SERVIENT_ARG"
	done
	SERVIENT_ARGS="$T_SARRAY"
done

if [ "$#" -eq 0 ]
then
	print_err "$0: Need to atleast provide a working directory"
	show_help_screen 
	exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
fi

TEMP=0
for SERVINET_NPARG in $SERVIENT_NON_POSITIONAL_ARGS
do
	TEMP=`expr $TEMP + 1`
done
#TEMP now contains the number of arguments in the space delimited SERVIENT_NON_POSITIONAL_ARGS list
SERVINET_NO_NPARGS=$TEMP
if [ "$SERVINET_NO_NPARGS" -gt 2 ]
then
	print_err "$0: Can have atmost two mandatory arguments"
	show_help_screen 
	exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
fi
if [ "$SERVINET_NO_NPARGS" -eq 1 ]
then
	SERVIENT_NON_POSITIONAL_ARGS=`echo "$SERVIENT_NON_POSITIONAL_ARGS"|sed 's/^[ \t]*//;s/[ \t]*$//'`
	is_path_absolute "$SERVIENT_NON_POSITIONAL_ARGS" 
	TEMP1=$?
	if [ $TEMP1 -eq 0 ]
	then
		print_err "[ $SERVIENT_NON_POSITIONAL_ARGS ] should be a directory and an absolute path" 
		exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG  ## ## *Dont* use brackets around exit
	fi
	if [ $TEMP1 -eq 1 -a ! -d "$SERVIENT_NON_POSITIONAL_ARGS" ] 
	then
			print_err "[ $SERVIENT_NON_POSITIONAL_ARGS ] should be a directory and an absolute path" 
			exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG ## ## *Dont* use brackets around exit
	fi
	servient_is_set_pros_sol_dir
	TEMP1=$?
	if [ $TEMP1 -eq 1 ]
	then
		print_err "$0: Can't provide reference directory and/or prospective solution directory as both positional and non positional arguments"
		show_help_screen
		exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
	fi
	SERVIENT_VAL_TOP_DIR="$SERVIENT_NON_POSITIONAL_ARGS"
elif [ "$SERVINET_NO_NPARGS" -eq 2 ]
then
	## At this point in time, all positional arguments have already been processed and has been validated. 
	## If user has already given prospective solutionn and ref solution directories as positional arguments, it takes higher priority.
	( ! servient_is_set_opt_ref_dir ) && ( ! servient_is_set_pros_sol_dir ) && print_err "$0: Can't provide reference directory and/or prospective solution directory as both positional and non positional arguments" && show_help_screen && exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
	TEMP=0
	for SERVINET_NPARG in $SERVIENT_NON_POSITIONAL_ARGS
	do
		
		SERVINET_NPARG=`echo "$SERVINET_NPARG"|sed 's/^[ \t]*//;s/[ \t]*$//'`
		is_path_absolute "SERVINET_NPARG" 
		TEMP1=$?
		if [ $TEMP1 -eq 0 ]
		then
			print_err "[ $SERVINET_NPARG ] should be a directory or a file and an absolute path" 
			exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG  ## ## *Dont* use brackets around exit
		fi
		if [ $TEMP1 -eq 1 -a ! -d "$SERVINET_NPARG" ]
		then
			if [ ! -f "$SERVINET_NPARG" -a ! -d "$SERVINET_NPARG" ]
			then
				
				print_err "[ $SERVINET_NPARG ] should be a directory or a file and an absolute path" 
				exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG ## ## *Dont* use brackets around exit
			fi
		fi
		servient_is_set_pros_sol_dir
		TEMP1=$?
		if [ $TEMP1 -eq 1 ]
		then
			print_err "$0: Can't provide reference directory and/or prospective solution directory as both positional and non positional arguments"
			show_help_screen
			exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
		fi
		servient_is_set_opt_ref_dir
		TEMP1=$?
		if [ $TEMP1 -eq 1 ]
		then
			print_err "$0: Can't provide reference directory and/or prospective solution directory as both positional and non positional arguments"
			show_help_screen
			exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
		fi
		if [ $TEMP -eq 0 ]
		then
			SERVIENT_VAL_SOL="$SERVINET_NPARG"	
		elif [ $TEMP -eq 1 ]
		then
			SERVIENT_VAL_REF="$SERVINET_NPARG"
		fi	
		TEMP=`expr $TEMP + 1`
	done
	if [ -d "$SERVIENT_VAL_SOL" ]
	then
		SERVIENT_VAL_TOP_DIR=$SERVIENT_VAL_SOL
	fi
else
	show_help_screen 
	exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
	
fi
## When both SERVIENT_VAL_REF and SERVIENT_VAL_SOL are both
## Directories, it is taken care of below as it is the most
## eloberate.
if [ -f "$SERVIENT_VAL_REF" -a -f "$SERVIENT_VAL_SOL" ]
then
	print_screen "Two files"	
	#TODO
fi
if [ -d "$SERVIENT_VAL_REF" -a -f "$SERVIENT_VAL_SOL" ]
then
	print_screen "First Directory second file"	
	#TODO
fi
if [ -f "$SERVIENT_VAL_REF" -a -d "$SERVIENT_VAL_SOL" ]
then
	print_screen "(This is invalid)First file second directory"	
	#TODO
fi
#if [ $IS_ROOT -eq 0 ] ## TODO Think this over
#then
#	echo "Initially this script needs root previlages."
#	echo "It will later drop previlages to specifed user/nobody"
#	exit $SERVIENT_EXIT_ERROR_INIT_USER_NOT_ROOT
#fi		

if [ -z "$SERVIENT_VAL_TOP_DIR" ]
then
	#TODO: This can be null if SERVIENT_VAL_SOL is not a directory.
	print_err "[CONFIG-ERROR] Variable SERVIENT_VAL_TOP_DIR cant be null"
	exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG 
fi

if [ -z "$SERVIENT_VAL_REF" ]
then
	print_err "[CONFIG-WARN] Using $SERVIENT_VAL_TOP_DIR/REF as reference solution directory"
	SERVIENT_VAL_REF="$SERVIENT_VAL_TOP_DIR/REF"
fi
if [ -z "$SERVIENT_VAL_META_DIR" ]
then
	print_err "[CONFIG-WARN] Using $SERVIENT_VAL_TOP_DIR/META as meta directory"
	SERVIENT_VAL_META_DIR="$SERVIENT_VAL_TOP_DIR/META"
fi
if [ -z "$SERVIENT_VAL_RES_FILE" ]
then
	print_err "[CONFIG-WARN] Using  $SERVIENT_VAL_TOP_DIR/result.txt as result file"
	SERVIENT_VAL_RES_FILE="$SERVIENT_VAL_TOP_DIR/result.txt"
fi
if [ -z "$SERVIENT_VAL_VERBOSITY" ]
then
	print_err "[CONFIG-WARN] Using default value $SERVIENT_DEFAULT_VERBOSITY for verbosity"
	SERVIENT_VAL_VERBOSITY=$SERVIENT_DEFAULT_VERBOSITY
fi
if [ -z "$SERVIENT_VAL_DELAY" ]
then
	print_err "[CONFIG-WARN] Using default value $SERVIENT_DEFAULT_DELAY for delay"
	SERVIENT_VAL_DELAY=$SERVIENT_DEFAULT_DELAY
fi
if [ -z "$SERVIENT_VAL_UINFO_FILE" ]
then
	print_err "[CONFIG-WARN] All Directories under $SERVIENT_VAL_TOP_DIR will be checked !!"
	if [ ! -z "$SERVIENT_VAL_UINFO_STRING" ]
	then
		print_err "[CONFIG-ERROR] Userinfo string is not null"
		print_err "[CONFIG-ERROR] while user info file name is null !!"
		exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
	fi
fi
if [ -z "$SERVIENT_VAL_UINFO_STRING" ]
then
	print_err "[CONFIG-WARN] Variable SERVIENT_VAL_UINFO_STRING is null"
	if [ ! -z "$SERVIENT_VAL_UINFO_FILE" ]
	then
		print_err "[CONFIG-ERROR] Userinfo string is null"
		print_err "[CONFIG-ERROR] While user info file name is not null !!"
		exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
	fi
fi

if [ -z "$SERVIENT_VAL_RES_FILE" ]
then
	print_err "[CONFIG-WARN] Storing result in file $SERVIENT_VAL_TOP_DIR/result.txt"
	SERVIENT_VAL_RES_FILE="$SERVIENT_VAL_TOP_DIR/result.txt"
fi

call_valid_ps_with_args
if [ $SERVINET_NO_NPARGS -eq 1 ]
then
	## TODO branch here. $SERVIENT_VAL_TOP_DIR is null if SERVIENT_VAL_SOL is not a directory.
	## Means we are mostly testing files.
	DIR_LIST=`find "$SERVIENT_VAL_TOP_DIR" -maxdepth 1 -name "*" -type d`
	rm -f "$SERVIENT_VAL_RES_FILE"
	for DIR in $DIR_LIST
	do
		DIR=`echo $DIR| sed 's/^\.\///'`;	
		if ( [ "$DIR" != "$SERVIENT_VAL_TOP_DIR" ] && [ "$DIR" != "$SERVIENT_VAL_REF" ] && [ "$DIR" != "$SERVIENT_VAL_META_DIR" ] && [ "$DIR" != "." ] && [ "$DIR" != ".." ] ) 
		then
			# XXX $SERVIENT_VAL_META_DIR check needs to be there. It is not always guarenteed to be inside reference script directory.
			MAGIC_STRING="" ## TODO: see TODO
			SCORE=0
			USER_ID=$(get_user_id)
			## TODO use  type  -t def_foo_bar | grep function | wc -l and do more sane error checking 
			if ( [ ! -z "$USER_ID"  ] || ( [ -z "$SERVIENT_VAL_UINFO_FILE" ] && [ -z "$SERVIENT_VAL_UINFO_STRING" ] ) )
			then
				FILES=`find "$DIR" -name "*" -type f`
				for FILE in $FILES
				do
					FILE_NAME=`echo "$FILE" |awk -F "/" '{print $NF;}'`
					FILE_PART=`echo "$FILE_NAME" | awk -F "." '{ for (i = 1; i < NF; i++)print $i }'` 
					if [ -e "$SERVIENT_VAL_REF/$FILE_NAME" ]
					then
						REF_OP=""
						OUR_OP=""
						if [ -e "$SERVIENT_VAL_REF/$FILE_PART.args" ]
						then
							VALID_ANSWER=0
							exec<"$SERVIENT_VAL_REF/$FILE_PART.args"
							while read line
							do
								if [ -f op_ref ]
								then
									echo "" > op_ref
								fi
								if [ -f op_our ]
								then
									echo "" > op_our
								fi
								"$SERVIENT_VAL_REF/$FILE_NAME" $line > op_ref &
								REF_PID=$!
								"$DIR/$FILE_NAME" $line > op_our 
								OUR_PID=$!
								if [ -z "$SERVIENT_VAL_DELAY" ]	
								then
									sleep 2	
								else
									sleep $SERVIENT_VAL_DELAY	
								fi
								if [ -z $REF_PID ]
								then
									if (( $VERBOSE_OUTPUT ))
									then
										print_screen "Problem running script $SERVIENT_VAL_REF/$FILE_NAME"
									fi
									exit 255 ## TODO See http://tldp.org/LDP/abs/html/exitcodes.html
								fi
								if [ -z $OUR_PID ]
								then
									if (( $VERBOSE_OUTPUT ))
									then
										print_screen "Problem running script $DIR/$FILE_NAME"
									fi
									exit 255 ## TODO See http://tldp.org/LDP/abs/html/exitcodes.html
								fi
								IS_REF_RUNNING=`$SERVIENT_PS_COMMAND_ARGS | awk -v PROCESS=$REF_PID '{for(i=1;i<=NF;i++){if( (match($i,PROCESS)== 1) && (length($i) == length(PROCESS)) ){print $i}}}' | wc -l`
								IS_OUR_RUNNING=`$SERVIENT_PS_COMMAND_ARGS | awk -v PROCESS="$OUR_PID" '{for(i=1;i<=NF;i++){if( (match($i,PROCESS)== 1) && (length($i) == length(PROCESS)) ){print $i}}}' | wc -l`
								if (( $IS_REF_RUNNING ))
								then
									kill -s SIGKILL $REF_PID
								fi
								if (( $IS_OUR_RUNNING ))
								then
									kill -s SIGKILL $OUR_PID
								fi
								REF_OP=`cat op_ref`
								OUR_OP=`cat op_our`
								if [ -z "$USER_ID" ]
								then
									USER_ID="$DIR"
								fi
								if ( [ ! -z "$REF_OP"  ]  && [ ! -z "$OUR_OP"  ] )
								then
									if [ "$REF_OP" = "$OUR_OP" ]
									then
										VALID_ANSWER=1	
									else
										if (( $VERBOSE_OUTPUT ))
										then
											print_screen "$USER_ID:$FILE_NAME-Wrong"
											print_screen "broke for input $line"
										fi
										MAGIC_STRING="$MAGIC_STRING 0"
										VALID_ANSWER=0
										break
									fi
								fi
							done
							if (( $VALID_ANSWER ))
							then
								if (( $VERBOSE_OUTPUT ))
								then
									print_screen "$USER_ID:$FILE_NAME-Correct"
								fi
								MAGIC_STRING="$MAGIC_STRING 1"
								SCORE=$(( $SCORE + 1 ))
							fi
						else
							if [ -f op_ref ]
							then
								echo "" > op_ref
							fi
							if [ -f op_our ]
							then
								echo "" > op_our
							fi
							"$SERVIENT_VAL_REF/$FILE_NAME" > op_ref &
							REF_PID=$!
							"$DIR/$FILE_NAME" > op_our &
							OUR_PID=$!
							if [ -z "$SERVIENT_VAL_DELAY" ]	
							then
								sleep 2	
							else
								sleep $SERVIENT_VAL_DELAY	
							fi
							if [ -z $REF_PID ]
							then
								if (( $VERBOSE_OUTPUT ))
								then
									print_screen "Problem running script $SERVIENT_VAL_REF/$FILE_NAME"
								fi
								exit 255 ## TODO See http://tldp.org/LDP/abs/html/exitcodes.html
							fi
							if [ -z $OUR_PID ]
							then
								if (( $VERBOSE_OUTPUT ))
								then
									print_screen " Problem running script $DIR/$FILE_NAME"
								fi
								exit 255 ## TODO See http://tldp.org/LDP/abs/html/exitcodes.html
							fi
							IS_REF_RUNNING=`$SERVIENT_PS_COMMAND_ARGS | awk -v PID=$REF_PID '{for(i=1;i<=NF;i++){if( (match($i,PID	)== 1) && (length($i) == length(PID)) && !/awk / ){print $i}}}' | wc -l`
							IS_OUR_RUNNING=`$SERVIENT_PS_COMMAND_ARGS | awk -v PID=$OUR_PID '{for(i=1;i<=NF;i++){if( (match($i,PID)== 1) && (length($i) == length(PID)) && !/awk / ){print $i}}}' | wc -l`
							if (( $IS_REF_RUNNING ))
							then
								kill -s SIGKILL $REF_PID
							fi
							if (( $IS_OUR_RUNNING ))
							then
								kill -s SIGKILL $OUR_PID
							fi
							REF_OP=`cat op_ref`
							OUR_OP=`cat op_our`
							if [ -z "$USER_ID" ]
							then
								USER_ID="$DIR"
							fi
							if ( [ ! -z "$REF_OP"  ]  && [ ! -z "$OUR_OP"  ] )
							then
								if [ "$REF_OP" = "$OUR_OP" ]
								then
									if (( $VERBOSE_OUTPUT ))
									then
										print_screen "$USER_ID:$FILE_NAME-Correct"
									fi
									MAGIC_STRING="$MAGIC_STRING 1"
									SCORE=$(( $SCORE + 1 ))
								else
									if (( $VERBOSE_OUTPUT ))
									then
									 	print_screen "$USER_ID:$FILE_NAME-Wrong"
									fi
									MAGIC_STRING="$MAGIC_STRING 0"
								fi
							fi
						fi
					fi
				done
				MAGIC_STRING=`echo $MAGIC_STRING|sed 's/^[ \t]*//;s/[ \t]*$//'`
				echo "$DIR#$MAGIC_STRING,$SCORE" >> "$SERVIENT_VAL_RES_FILE"
			else
				if (( $VERBOSE_OUTPUT ))
				then
					print_screen "Cant find valid user information"
					print_screen "Skipping $DIR"
				fi
				cd $PARENT_DIR
			fi
		fi
	done	
	if [ -f op_ref ]
	then
		rm -f op_ref
	fi
	if [ -f op_our ]
	then
		rm -f op_our
	fi
elif [ $SERVINET_NO_NPARGS -eq 2 ]
then
	## TODO branch here. $SERVIENT_VAL_TOP_DIR is null if SERVIENT_VAL_SOL is not a directory.
	## Means we are mostly testing files.
	rm -f "$SOLUTION_SCRIPTS_DIR_NAME"/"$REPORT_FILE" 
	find "$SOLUTION_SCRIPTS_DIR_NAME" -name "OP" -exec rm -f {} \;
	if ( [ "$SOLUTION_SCRIPTS_DIR_NAME" != "$REFERENCE_SCRIPTS_DIR_NAME" ] )  
	then
		DIR=`echo "$SOLUTION_SCRIPTS_DIR_NAME"|awk -F "/" '{ print $NF; }'` # DIR contains the last part of the SOL script name, used to user_info.txt thing
		MAGIC_STRING=""
		SCORE=0
		USER_ID=$(get_user_id)
		if [ -z "$USER_ID"  ] 
		then
			USER_ID=$DIR #TODO: TAKE LAST PART OF SOL_DIR PATH
		fi
		if ( [ ! -z "$USER_ID"  ] )
		then
			FILES=`find "$SOLUTION_SCRIPTS_DIR_NAME" -maxdepth 1 -name "*" -type f`
			for FILE in $FILES
			do
				FILE_NAME=`echo $FILE|awk -F "/" '{print $NF;}'`
				FILE_PART=`echo "$FILE_NAME" | awk -F "." '{ for (i = 1; i < NF; i++)print $i }'`
				## TODO : See mee and find a clean way to do what is being done here.
				if [ "$FILE_NAME" == "${DIR}_$USER_INFO_FILE_NAME" ]
				then
					continue
				fi
				if [ -e "$REFERENCE_SCRIPTS_DIR_NAME/$FILE_PART.sce" ]
				then
					VALID_ANSWER=0
					TEMP=`grep -n "^exec" "$REFERENCE_SCRIPTS_DIR_NAME/$FILE_PART.sce" | wc -l`
					while (( $TEMP ))
					do
						sed -i '/exec\(.*\)\;/d' "$REFERENCE_SCRIPTS_DIR_NAME/$FILE_PART.sce"
						let TEMP-=1
					done
					sed -i '/^\(errcatch.-1,.stop..\)/d' "$REFERENCE_SCRIPTS_DIR_NAME/$FILE_PART.sce" 
					export STUDENT_FILE="$SOLUTION_SCRIPTS_DIR_NAME/$FILE_NAME"
					perl -pi -e 'print "exec $ENV{\"STUDENT_FILE\"};\n" if $. == 1' "$REFERENCE_SCRIPTS_DIR_NAME/$FILE_PART.sce"
					perl -pi -e "print \"errcatch(-1,\'stop\');\n\" if $. == 1" "$REFERENCE_SCRIPTS_DIR_NAME/$FILE_PART.sce"
					sed -i 's/\(disp(.*)\)/\/\/\1/' "$FILE" ## XXX: Was FILE_NAME
					scilab -nb -nwni -f "$REFERENCE_SCRIPTS_DIR_NAME/$FILE_PART.sce"  > "$SOLUTION_SCRIPTS_DIR_NAME/OP" &
					REF_PID=$!
					if [ -z "$SCRIPT_DELAY" ]	
					then
						sleep 2	
					else
						sleep $SCRIPT_DELAY	
					fi
					if [ -z $REF_PID ]
					then
						if (( $VERBOSE_OUTPUT ))
						then
							echo "Problem running script $REFERENCE_SCRIPTS_DIR_NAME/$FILE_PART.sce"
						fi
						exit 255
					fi
					IS_REF_RUNNING=`ps aux | grep -w "$REF_PID" | grep -v grep | wc -l`
					if (( $IS_REF_RUNNING ))
					then
						kill -s SIGKILL $REF_PID
					fi
					### 
					sed -i -e 's/[\t ]//g;/^$/d' "$SOLUTION_SCRIPTS_DIR_NAME/OP"
					TEMP=0
					##Temp=0, for the first iteration of the loop only
					while read line
					do 
						if ( [ "$line" == "T" ] && ( (( $VALID_ANSWER )) || (( ! $TEMP )) ) )
						then
							VALID_ANSWER=1
						else
							VALID_ANSWER=0
						fi
						let TEMP+=1
					done < "$SOLUTION_SCRIPTS_DIR_NAME/OP" 
					####
					if (( $VALID_ANSWER ))
					then
						if (( $VERBOSE_OUTPUT ))
						then
							echo "$USER_ID:$FILE_NAME-Correct"
						fi
						MAGIC_STRING="$MAGIC_STRING {$FILE_PART=1}"
						SCORE=$(( $SCORE + 1 ))
					else
						if (( $VERBOSE_OUTPUT ))
						then
							echo "$USER_ID:$FILE_NAME-Wrong"
						fi
						MAGIC_STRING="$MAGIC_STRING {$FILE_PART=0}"
					fi
				else
					if (( $VERBOSE_OUTPUT ))
					then
						echo "Directory[$REFERENCE_SCRIPTS_DIR_NAME] does not contain $FILE_PART.sce"
					fi
				fi
			done
			MAGIC_STRING=`echo $MAGIC_STRING|sed 's/^[ \t]*//;s/[ \t]*$//'`
			echo "$USER_ID#$MAGIC_STRING,$SCORE" | cat >> "$SOLUTION_SCRIPTS_DIR_NAME/$REPORT_FILE"
		else
			if (( $VERBOSE_OUTPUT ))
			then
				echo "Cant find valid user information"
				echo "Skipping $DIR"
			fi
		fi
	fi
	find "$	SOLUTION_SCRIPTS_DIR_NAME" -name "OP" -exec rm -f {} \;
else
	print_err "Unkown condition encountered" 
	print_err " If you believe this is an error, please consider filing a bug report"
	show_help_screen
	exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
fi

