#!/bin/bash
GIT_LOG_FILE="/e/scripts/scipts.log"
WORKING_DIR="/e"

echo "----------------" >> $GIT_LOG_FILE
echo "#### $1 ####" >> $GIT_LOG_FILE
if [ "$2" == "" ]; then
	cd $WORKING_DIR/$1
	git add --all >> $GIT_LOG_FILE
	git commit -a -m "commit"  -q >> $GIT_LOG_FILE
	git push origin master  -q >> $GIT_LOG_FILE
	cd $WORKING_DIR
else
	cd $WORKING_DIR/$1
	git add --all >> $GIT_LOG_FILE
	git commit -a -m "$2" -q >> $GIT_LOG_FILE
	git push origin master -q >> $GIT_LOG_FILE
	cd $WORKING_DIR
fi
