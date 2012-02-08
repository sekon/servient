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

SERVIENT_INSTALL_DIR=$PWD
source "$SERVIENT_INSTALL_DIR"/servient_util.sh

####################################### CONFIG DATA #############################################
SERVIENT_EXIT_ERROR_SCRIPT_CONFIG=200
SERVIENT_EXIT_ERROR_INIT_USER_NOT_ROOT=25
SCRIPT_DELAY=2
REFERENCE_SCRIPTS_DIR_NAME="REF"
META_DIR_NAME="META"
USER_INFO_FILE_NAME="user_info.txt"
USER_INFO_UID_STRING="User ID"
REPORT_FILE="report.txt"
VERBOSE_OUTPUT=0
SERVIENT_VERSION_NUMBER="0.4a"
####################################### CONFIG DATA ENDS ########################################

##TODO: Get a list of all variables in a bash script.
# VARIABLES=$(echo "compgen -A variable" >> "$PLUGIN_FILE" ;source "$PLUGIN_FILE";sed -i '$d' "$PLUGIN_FILE")
# echo "$VARIABLES" | grep <PAttern>
# even if $PLUGIN_FILE redefines/rewrites variables .. it wont be seen here even when the script is being sourced.


get_user_id () 
{
	## TODO Clean this up .. really needs to be done more elegantly
	if [ -f "$USER_INFO_FILE_NAME" ]
	then
		MY_UID=`cat "$DIR/$USER_INFO_FILE_NAME" | grep -w "$USER_INFO_UID_STRING" | cut -d ":" -f 2 |sed 's/^[ \t]*//;s/[ \t]*$//'`
		IS_UNIQ=`cat "$DIR/USER_INFO_FILE_NAME" | grep -w "$USER_INFO_UID_STRING" | cut -d ":" -f 2 |sed 's/^[ \t]*//;s/[ \t]*$//'|wc -l`
		if [ "$IS_UNIQ" -ne "1" ]
		then
			if (( $VERBOSE_OUTPUT ))
			then
				print_screen "$DIR/$USER_INFO_FILE_NAME does not look valid or USER_INFO_UID_STRING is not unique"
			fi
			exit 205 ## TODO use exit, with more consistency with the rest of document.
		else
			echo "$MY_UID"	
		fi
	else
		echo -n ""
	fi
} 

is_path_absolute()
{
	local absolute
	if [ ! -z "$1" ]
	then
		#Function returns 1 if path is absolute else 0
		case "$1" in
			/*) absolute=1 ;;
			*) absolute=0 ;;
		esac
	else
		absolute=0
	fi
	return $absolute

}


IS_ROOT=`id | grep -w root  | wc -l`

show_help_screen ()
{
	MY_OPTIONAL_STRING=`echo $SERVIENT_OPTION_STRING | sed 's/^:-://' |sed 's/\([a-zA-Z]\)/\ \1/g' |sed 's/\([a-zA-Z]\)/-\1/g' |sed 's/:/\ OPTION\ /g'`
	print_screen "$0 - $SERVIENT_VERSION_NUMBER"
	print_screen "Available options for $0 are $MY_OPTIONAL_STRING" "--verbose[=VALUE] --help"
}


#Special thanks to http://wiki.bash-hackers.org/howto/getopts_tutorial, for the awesome tutorial.
# and http://stackoverflow.com/questions/402377/using-getopts-in-bash-shell-script-to-get-long-and-short-command-line-options/7680682#7680682
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
SERVIENT_VAL_VERBOSITY=$SERVIENT_DEFAULT_VERBOSITY
SERVIENT_VAL_DELAY=""
SERVIENT_VAL_DEBUG=""
SERVIENT_VAL_UINFO_FILE=""
SERVIENT_VAL_META_DIR=""
SERVIENT_VAL_REF_DIR=""
SERVIENT_VAL_RES_FILE=""
SERVIENT_VAL_SOL_DIR=""
SERVIENT_VAL_UINFO_STRING=""
## TODO check for multiple arguments and valid arguments
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
						echo "Parsing option: '--${opt}', value: '${val}'" >&2
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
					if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
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
				( is_path_absolute "$OPTARG"  ||  [ ! -d "$OPTARG" ] ) &&  echo "[ $OPTARG ], an arg for $opt should be a directory and an absolute path " && exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG ## ## *Dont* use brackets around exit
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
				( is_path_absolute "$OPTARG"  ||  [ ! -d "$OPTARG" ] ) &&  echo "[ $OPTARG ], an arg for $opt should be a directory and an absolute path " && exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG ## ## *Dont* use brackets around exit
				SERVIENT_VAL_REF_DIR="$OPTARG"	
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
				is_path_absolute "$OPTARG" || ( [ -e "$OPTARG" ] && [ ! -f "$OPTARG" ] ) && echo "[ $OPTARG ], an arg for $opt should be a file and an absolute path " && exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG ## ## *Dont* use brackets around exit
				ERROR_STRING=`touch "$OPTARG" 2>&1`
				TEMP=$?
				if [ $TEMP -ne 0 ]
				then
					print_err " Problem creating/acessing [ $OPTARG ]"
					print_err "$ERROR_STRING"
					exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
				fi
				SERVIENT_VAL_RES_FILE=$OPTARG
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
				( is_path_absolute "$OPTARG"  ||  [ ! -d "$OPTARG" ] ) &&  echo "[ $OPTARG ], an arg for $opt should be a directory and an absolute path " && exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG ## ## *Dont* use brackets around exit
				SERVIENT_VAL_SOL_DIR="$OPTARG"	
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
				OPTARG=`echo $OPTARG|sed 's/^[ \t]*//;s/[ \t]*$//'` ## TODO: Esacape alrady present quotation marks
				ERROR_STRING=`bash -n -c "$OPTARG" 2>&1`
				SERVIENT_VAL_UINFO_STRING="$OPTARG"
				TEMP=$?
				if [ $TEMP -ne 0 ]
				then
					print_err "Userinfo extraction string [ $OPTARG ], does not look like a valid bash snippet"
					echo "$ERROR_STRING"
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

#if [ $IS_ROOT -eq 0 ] ## TODO Think this over
#then
#	echo "Initially this script needs root previlages."
#	echo "It will later drop previlages to specifed user/nobody"
#	exit $SERVIENT_EXIT_ERROR_INIT_USER_NOT_ROOT
#fi		
if [ -z "$REFERENCE_SCRIPTS_DIR_NAME" ]
then
	print_err "[CONFIG-ERROR] Variable REFERENCE_SCRIPTS_DIR_NAME cant be null"
	exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG 
fi
if [ -z "$META_DIR_NAME" ]
then
	print_err "[CONFIG-ERROR] Variable META_DIR_NAME cant be null"
	exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
fi
if [ -z "$REPORT_FILE" ]
then
	print_err "[CONFIG-ERROR] Variable REPORT_FILE cant be null"
	exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
fi
if [ -z "$VERBOSE_OUTPUT" ]
then
	print_err "[CONFIG-WARN] Variable VERBOSE_OUTPUT is null"
	print_err "Defaulting to zero"
	VERBOSE_OUTPUT=0
fi
if [ -z "$SCRIPT_DELAY" ]
then
	print_err "[CONFIG-WARN] Variable SCRIPT_DELAY is null"
	print_err "Defaulting to delay of 2 seconds"
	SCRIPT_DELAY=2
fi
if [ -z "$USER_INFO_FILE_NAME" ]
then
	print_err "[CONFIG-WARN] Variable USER_INFO_FILE_NAME is null"
	print_err "[CONFIG-WARN] All Directories under $PWD will be checked !!"
	if [ ! -z "$USER_INFO_UID_STRING" ]
	then
		print_err "[CONFIG-ERROR] Variable USER_INFO_UID_STRING is not null"
		print_err "[CONFIG-ERROR] While USER_INFO_FILE_NAME is null !!"
		exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
	fi
fi
if [ -z "$USER_INFO_UID_STRING" ]
then
	print_err "[CONFIG-WARN] Variable USER_INFO_UID_STRING is null"
	if [ ! -z "$USER_INFO_FILE_NAME" ]
	then
		print_err "[CONFIG-ERROR] Variable USER_INFO_FILE_NAME is not null"
		print_err "[CONFIG-ERROR] While USER_INFO_UID_STRING is null !!"
		exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
	fi
fi


call_valid_ps_with_args

DIR_LIST=`find . -maxdepth 1 -name "*" -type d`
rm -f "$REPORT_FILE"
for DIR in $DIR_LIST
do
	DIR=`echo $DIR| sed 's/^\.\///'`;	
	if ( [ "$DIR" != "$REFERENCE_SCRIPTS_DIR_NAME" ] && [ "$DIR" != "$META_DIR_NAME" ] && [ "$DIR" != "." ] && [ "$DIR" != ".." ] ) 
	then
		# XXX $META_DIR_NAME check needs to be there. It is not always guarenteed to be inside reference script directory.
		MAGIC_STRING="" ## TODO: see TODO
		SCORE=0
		USER_ID=$(get_user_id)
		## TODO use  type  -t def_foo_bar | grep function | wc -l and do more sane error checking 
		if ( [ ! -z "$USER_ID"  ] || ( [ -z "$USER_INFO_FILE_NAME" ] && [ -z "$USER_INFO_UID_STRING" ] ) )
		then
			FILES=`find "$DIR" -name "*" -type f`
			for FILE in $FILES
			do
				FILE_NAME=`echo "$FILE" |awk -F "/" '{print $NF;}'`
				FILE_PART=`echo "$FILE_NAME" | awk -F "." '{ for (i = 1; i < NF; i++)print $i }'` 
				if [ -e "$REFERENCE_SCRIPTS_DIR_NAME/$FILE_NAME" ]
				then
					REF_OP=""
					OUR_OP=""
					if [ -e "$REFERENCE_SCRIPTS_DIR_NAME/$FILE_PART.args" ]
					then
						VALID_ANSWER=0
						exec<"$REFERENCE_SCRIPTS_DIR_NAME/$FILE_PART.args"
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
							"$REFERENCE_SCRIPTS_DIR_NAME/$FILE_NAME" $line > op_ref &
							REF_PID=$!
							"$DIR/$FILE_NAME" $line > op_our 
							OUR_PID=$!
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
									print_screen "Problem running script $REFERENCE_SCRIPTS_DIR_NAME/$FILE_NAME"
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
							IS_OUR_RUNNING=`$SERVIENT_PS_COMMAND_ARGS | awk -v PROCESS=$OUR_PID" '{for(i=1;i<=NF;i++){if( (match($i,PROCESS)== 1) && (length($i) == length(PROCESS)) ){print $i}}}' | wc -l` 
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
						"$REFERENCE_SCRIPTS_DIR_NAME/$FILE_NAME" > op_ref &
						REF_PID=$!
						"$DIR/$FILE_NAME" > op_our &
						OUR_PID=$!
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
								print_screen "Problem running script $REFERENCE_SCRIPTS_DIR_NAME/$FILE_NAME"
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
						IS_REF_RUNNING=`$SERVIENT_PS_COMMAND_ARGS | grep -w "$REF_PID" | grep -v grep | wc -l`
						IS_OUR_RUNNING=`$SERVIENT_PS_COMMAND_ARGS | grep -w "$OUR_PID" | grep -v grep | wc -l`
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
			echo "$DIR#$MAGIC_STRING,$SCORE" >> "$REPORT_FILE"
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
 
