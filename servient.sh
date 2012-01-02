#!/bin/bash
#################################################################################################
#Purpose: <To be done>										#
#Primary Author: Harish Badrinath < harish [at] fossee.in>					#
#Taken Over date/Creation date: Sun, 06 Nov 2011 21:38:58 +0530					#
#Taken Over by:											#
#Taken Over date:										#
#Date of last commit:Mon, 26 Dec 2011 18:10:41 +0530						#
#License: GPL V3 +										#
#Internal Version Number: See $SERVIENT_VERSION_NUMBER 									#
#################################################################################################

####################################### CONFIG DATA #############################################
SERVIENT_EXIT_ERROR_SCRIPT_CONFIG=200
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


function get_user_id ()
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
				echo "$DIR/$USER_INFO_FILE_NAME does not look valid or USER_INFO_UID_STRING is not unique"
			fi
			exit 205
		else
			echo "$MY_UID"	
		fi
	else
		echo -n ""
	fi
} 


IS_ROOT=`id | grep -w root  | wc -l`

function show_help_screen ()
{
	MY_OPTIONAL_STRING=`echo $SERVIENT_OPTION_STRING | sed 's/^:-://' |sed 's/\([a-zA-Z]\)/\ \1/g' |sed 's/\([a-zA-Z]\)/-\1/g' |sed 's/:/\ OPTION\ /g'`
	echo "$0 - $SERVIENT_VERSION_NUMBER"
	echo "Available options for $0 are $MY_OPTIONAL_STRING" "--verbose[=VALUE] --help"
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
## TODO check for multiple arguments and valid arguments
while getopts "$SERVIENT_OPTION_STRING" opt; do
	case $opt in
		-)
			case "${OPTARG}" in
				verbose)
					if (( ! $SERVIENT_verbose_is_set ))
					then
						#Called only when --verbose is called ..
						val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
						echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2;
						echo "Naked Verbosity" >&2;
						SERVIENT_verbose_is_set=1
					else
						echo "More than one instance of ${OPTARG} given during invocation" >&2
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
					else
						echo "More than one instance of ${OPTARG} given during invocation" >&2
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
					fi
					;;
				help)
					if [ $# -eq 1 ]
					then
						show_help_screen
					else
						echo "Option ${OPTARG} needs to be the only argument" >&2
						exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
					fi
					;;
				*)
					if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
						echo "Unknown option --${OPTARG}" >&2
					fi
					exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
					;;
				esac
			;;
		d)
			if (( ! $SERVIENT_delay_is_set ))
			then
				echo "-d was triggered, Delay will be  $OPTARG" >&2
				SERVIENT_delay_is_set=1
			else
				echo "More than one instance of $opt given during invocation" >&2
				exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
			fi
			;;
		D)
			if (( ! $SERVIENT_debug_is_set ))
			then
				echo "-D was trigerred, you have enabled bash debugging" >&2
				SERVIENT_debug_is_set=1
			else
				echo "More than one instance of $opt given during invocation" >&2
				exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
			fi
			;;
		f)
			if (( ! $SERVIENT_uinfo_file_is_set ))
			then
				echo "-f was triggered, $OPTARG file in each directory will be queried for user info" >&2
				SERVIENT_uinfo_file_is_set=1
			else
				echo "More than one instance of $opt given during invocation" >&2
				exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
			fi
			;;
		h)
			if [ $# -eq 1 ]
			then
				show_help_screen
			else
				echo "Option ${OPTARG} needs to be the only argument" >&2
				exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
			fi
			;;
		m)
			if (( ! $SERVIENT_meta_dir_is_set ))
			then
				echo "-m was triggered, Parameter: $OPTARG is the meta directory" >&2
				SERVIENT_meta_dir_is_set=1
			else
				echo "More than one instance of $opt given during invocation" >&2
				exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
			fi
			;;
		r)
			if (( ! $SERVIENT_ref_dir_is_set ))
			then
				echo "-r was triggered, Parameter: $OPTARG is the reference directory/file" >&2
				SERVIENT_ref_dir_is_set=1
			else
				echo "More than one instance of $opt given during invocation" >&2
				exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
			fi
			;;
		R)
			if (( ! $SERVIENT_result_file_is_set ))
			then
				echo "-R was triggered, Report will be returned to  $OPTARG" >&2
				SERVIENT_result_file_is_set=1
			else
				echo "More than one instance of $opt given during invocation" >&2
				exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
			fi
			;;
		s)
			if (( ! $SERVIENT_sol_dir_is_set ))
			then
				echo "-s was triggered, Parameter: $OPTARG is the solution directory/file" >&2
				SERVIENT_sol_dir_is_set=1
			else
				echo "More than one instance of $opt given during invocation" >&2
				exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
			fi
			;;
		u)
			if (( ! $SERVIENT_uinfo_string_is_set ))
			then
				echo "-u was triggered, $OPTARG string will be executed on the contents of file given in -f argument" >&2
				SERVIENT_uinfo_string_is_set=1
			else
				echo "More than one instance of $opt given during invocation" >&2
				exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
			fi
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit $SERVIENT_EXIT_ERROR_SCRIPT_CONFIG
			;;
	esac
done

if [ $IS_ROOT -ne 0 ]
then
	echo "Cant run script as root !!"
	exit 25
fi		
if [ -z "$REFERENCE_SCRIPTS_DIR_NAME" ]
then
	echo "[CONFIG-ERROR] Variable REFERENCE_SCRIPTS_DIR_NAME cant be null"
	exit 200
fi
if [ -z "$META_DIR_NAME" ]
then
	echo "[CONFIG-ERROR] Variable META_DIR_NAME cant be null"
	exit 200
fi
if [ -z "$REPORT_FILE" ]
then
	echo "[CONFIG-ERROR] Variable REPORT_FILE cant be null"
	exit 200
fi
if [ -z "$VERBOSE_OUTPUT" ]
then
	echo "[CONFIG-WARN] Variable VERBOSE_OUTPUT is null"
	echo "Defaulting to zero"
	VERBOSE_OUTPUT=0
fi
if [ -z "$SCRIPT_DELAY" ]
then
	echo "[CONFIG-WARN] Variable SCRIPT_DELAY is null"
	echo "Defaulting to delay of 2 seconds"
	SCRIPT_DELAY=2
fi
if [ -z "$USER_INFO_FILE_NAME" ]
then
	echo "[CONFIG-WARN] Variable USER_INFO_FILE_NAME is null"
	echo "[CONFIG-WARN] All Directories under $PWD will be checked !!"
	if [ ! -z "$USER_INFO_UID_STRING" ]
	then
		echo "[CONFIG-ERROR] Variable USER_INFO_UID_STRING is not null"
		echo "[CONFIG-ERROR] While USER_INFO_FILE_NAME is null !!"
		exit 200
	fi
fi
if [ -z "$USER_INFO_UID_STRING" ]
then
	echo "[CONFIG-WARN] Variable USER_INFO_UID_STRING is null"
	if [ ! -z "$USER_INFO_FILE_NAME" ]
	then
		echo "[CONFIG-ERROR] Variable USER_INFO_FILE_NAME is not null"
		echo "[CONFIG-ERROR] While USER_INFO_UID_STRING is null !!"
		exit 200
	fi
fi

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
				FILE_NAME=`echo $FILE|awk -F "/" '{print $NF;}'`
				FILE_PART=`echo $FILE_NAME | cut -d "." -f 1` ## TODO .. use awk here to exclude the last dot
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
									echo "Problem running script $REFERENCE_SCRIPTS_DIR_NAME/$FILE_NAME"
								fi
								exit 255
							fi
							if [ -z $OUR_PID ]
							then
								if (( $VERBOSE_OUTPUT ))
								then
									echo "Problem running script $DIR/$FILE_NAME"
								fi
								exit 255
							fi
							IS_REF_RUNNING=`ps aux | grep -w "$REF_PID" | grep -v grep | wc -l`
							IS_OUR_RUNNING=`ps aux | grep -w "$OUR_PID" | grep -v grep | wc -l`
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
										echo "$USER_ID:$FILE_NAME-Wrong"
										echo "broke for input $line"
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
								echo "$USER_ID:$FILE_NAME-Correct"
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
								echo "Problem running script $REFERENCE_SCRIPTS_DIR_NAME/$FILE_NAME"
							fi
							exit 255
						fi
						if [ -z $OUR_PID ]
						then
							if (( $VERBOSE_OUTPUT ))
							then
								echo " Problem running script $DIR/$FILE_NAME"
							fi
							exit 255
						fi
						IS_REF_RUNNING=`ps aux | grep -w "$REF_PID" | grep -v grep | wc -l`
						IS_OUR_RUNNING=`ps aux | grep -w "$OUR_PID" | grep -v grep | wc -l`
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
									echo "$USER_ID:$FILE_NAME-Correct"
								fi
								MAGIC_STRING="$MAGIC_STRING 1"
								SCORE=$(( $SCORE + 1 ))
							else
								if (( $VERBOSE_OUTPUT ))
								then
								 	echo "$USER_ID:$FILE_NAME-Wrong"
								fi
								MAGIC_STRING="$MAGIC_STRING 0"
							fi
						fi
					fi
				fi
			done
			MAGIC_STRING=`echo $MAGIC_STRING|sed 's/^[ \t]*//;s/[ \t]*$//'`
			echo "$DIR#$MAGIC_STRING,$SCORE" | cat >> "$REPORT_FILE"
		else
			if (( $VERBOSE_OUTPUT ))
			then
				echo "Cant find valid user information"
				echo "Skipping $DIR"
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
 
