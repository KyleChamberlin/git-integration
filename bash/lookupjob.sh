#!/bin/bash
WORKING_DIR=/e
cd $WORKING_DIR/gitolite-admin/
echo "----------------" >> $WORKING_DIR/scripts/scripts.log
echo "#### $1 ####" >> $WORKING_DIR/scripts/scripts.log
git pull origin master  -q >> $WORKING_DIR/scripts/scripts.log
REPO_EXISTS=$(grep -x "repo $1" $WORKING_DIR/gitolite-admin/conf/gitolite.conf)

if [ "$REPO_EXISTS" ] 
then
	echo "$1 is held in the git repo"	
else
	echo "$1 not found in the git repo"
fi
