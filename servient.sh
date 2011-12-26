#!/bin/bash
#################################################################################################
#Purpose: Automaitcally Test and validate shell script(s) submitted by fosse participants	#
#Primary Author: Harish Badrinath < harish [at] fossee.in>					#
#Taken Over date/Creation date: Sun, 06 Nov 2011 21:38:58 +0530					#
#Taken Over by:											#
#Taken Over date:										#
#Date of last commit:Fri, 11 Nov 2011 17:26:31 +0530						#
#License: GPL V3 +										#
#Internal Version Number: 0.3									#
#################################################################################################

####################################### CONFIG DATA #############################################
SCRIPT_DELAY=2
REFERENCE_SCRIPTS_DIR_NAME="REF"
META_DIR_NAME="META"
USER_INFO_FILE_NAME="user_info.txt"
USER_INFO_UID_STRING="User ID"
REPORT_FILE="report.txt"
VERBOSE_OUTPUT=0
####################################### CONFIG DATA ENDS ########################################

function get_user_id ()
{
	if [ -f "$USER_INFO_FILE_NAME" ]
	then
		MY_UID=`cat "$USER_INFO_FILE_NAME" | grep -w "$USER_INFO_UID_STRING" | cut -d ":" -f 2 |sed 's/^[ \t]*//;s/[ \t]*$//'`
		IS_UNIQ=`cat "$USER_INFO_FILE_NAME" | grep -w "$USER_INFO_UID_STRING" | cut -d ":" -f 2 |sed 's/^[ \t]*//;s/[ \t]*$//'|wc -l`
		if [ "$IS_UNIQ" -ne "1" ]
		then
			if (( $VERBOSE_OUTPUT ))
			then
				echo "$PWD/$USER_INFO_FILE_NAME does not look valid or USER_INFO_UID_STRING is not unique"
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
	echo "[CONFIG-ERROR] Please initialize this variable, even if you are using custom view"
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
PARENT_DIR=$PWD
rm -f "$REPORT_FILE"
for DIR in $DIR_LIST
do
	DIR=`echo $DIR| sed 's/^\.\///'`;	
	if ( [ "$DIR" != "$REFERENCE_SCRIPTS_DIR_NAME" ] && [ "$DIR" != "." ] && [ "$DIR" != "$META_DIR_NAME" ] ) 
	then
		cd $DIR
		MAGIC_STRING=""
		SCORE=0
		USER_ID=$(get_user_id)
		if ( [ ! -z "$USER_ID"  ] )
		then
			FILES=`find . -name "*" -type f`
			for FILE in $FILES
			do
				FILE_NAME=`echo $FILE|awk -F "/" '{print $NF;}'`
				FILE_PART=`echo $FILE_NAME | cut -d "." -f 1`
				if [ -e "$PARENT_DIR/REF/$FILE_NAME" ]
				then
					REF_OP=""
					OUR_OP=""
					if [ -e "$PARENT_DIR/$REFERENCE_SCRIPTS_DIR_NAME/$FILE_PART.args" ]
					then
						VALID_ANSWER=0
						exec<"$PARENT_DIR/$REFERENCE_SCRIPTS_DIR_NAME/$FILE_PART.args"
						while read line
						do
							"$PARENT_DIR/$REFERENCE_SCRIPTS_DIR_NAME/$FILE_NAME" $line > op_ref &
							REF_PID=$!
							"./$FILE_NAME" $line > op_our &
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
									echo " Problem running script $PARENT_DIR/REF/$FILE_NAME"
								fi
								exit 255
							fi
							if [ -z $OUR_PID ]
							then
								if (( $VERBOSE_OUTPUT ))
								then
									echo " Problem running script $PWD/$FILE_NAME"
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
						"$PARENT_DIR/$REFERENCE_SCRIPTS_DIR_NAME/$FILE_NAME" > op_ref &
						REF_PID=$!
						"./$FILE_NAME" > op_our &
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
								echo "Problem running script $PARENT_DIR/REF/$FILE_NAME"
							fi
							exit 255
						fi
						if [ -z $OUR_PID ]
						then
							if (( $VERBOSE_OUTPUT ))
							then
								echo " Problem running script $PWD/$FILE_NAME"
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
			echo "$DIR#$MAGIC_STRING,$SCORE" | cat >> "$PARENT_DIR/$REPORT_FILE"
			cd $PARENT_DIR
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
