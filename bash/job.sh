#!/bin/bash
WORKING_DIR_temp="/e"
JOB_NUMBER=$1
GIT_LOG_FILE="$WORKING_DIR_temp/scripts/scipts.log"
GITOLITE_ADMIN_CONF="$WORKING_DIR_temp/gitolite-admin/conf/gitolite.conf"

function psl_init() {
	echo "program = \"$JOB_NUMBER.psl\"" >> $JOB_NUMBER.pjb
	echo "merge = \"$JOB_NUMBER.csn\"" >> $JOB_NUMBER.pjb
	echo "path = \"resources;data;libraries\"" >> $JOB_NUMBER.pjb
	echo "V 3.3" >> $JOB_NUMBER.ppr
	echo "P \"$JOB_NUMBER.psl\"" >> $JOB_NUMBER.ppr
	echo "J \"$JOB_NUMBER.pjb\"" >> $JOB_NUMBER.ppr
	echo "WP $JOB_NUMBER.psl" >> $JOB_NUMBER.ppr
	echo "WL $JOB_NUMBER Pages.plb" >> $JOB_NUMBER.ppr
	echo "w 1 1" >> $JOB_NUMBER.ppr
	touch "$JOB_NUMBER.psl"
	cd libraries
	touch "$JOB_NUMBER Pages.plb"
	cd ..
}

function make_directories() {
	mkdir data
	mkdir resources
	mkdir layouts
	mkdir libraries >> /dev/null
}

function clone() {
	git clone git@git-server:$JOB_NUMBER -q >> $GIT_LOG_FILE
}

function add_job_to_gitolite() {
	echo "repo $JOB_NUMBER" >> $GITOLITE_ADMIN_CONF
	echo "     RW+   =   @all" >> $GITOLITE_ADMIN_CONF
	cd "$WORKING_DIR_temp/gitolite-admin/"
	git commit -a -q -m "added repo $JOB_NUMBER" >> $GIT_LOG_FILE
	git push origin master -q >> $GIT_LOG_FILE
}

echo "----------------" >> $GIT_LOG_FILE
echo "#### $JOB_NUMBER ####" >> $GIT_LOG_FILE
cd $WORKING_DIR_temp/gitolite-admin/
git pull origin master -q >> $GIT_LOG_FILE
cd $WORKING_DIR_temp
REPO_EXISTS=$(grep -x "repo $JOB_NUMBER" $GITOLITE_ADMIN_CONF)

if [ ! -d "$WORKING_DIR_temp/$JOB_NUMBER" ]
then
	if [ "$REPO_EXISTS" ] 
	then
		echo "pulling down the repo for $JOB_NUMBER from the server....."
		clone
		echo "Done."
	else
		echo "creating new job repo for $JOB_NUMBER...."
		add_job_to_gitolite
		cd $WORKING_DIR_temp
		mkdir "$JOB_NUMBER"
		cd "$WORKING_DIR_temp/$JOB_NUMBER"
		echo "initializing for PSL...."
		make_directories
		psl_init
		git init -q >> $GIT_LOG_FILE
		git add --all >> $GIT_LOG_FILE
		git commit -a -m "$JOB_NUMBER created" -q >> $GIT_LOG_FILE
		git remote add origin git@git-server:$JOB_NUMBER >> $GIT_LOG_FILE
		git remote set-url origin git@git-server:$JOB_NUMBER >> $GIT_LOG_FILE
		git push origin master -q >> $GIT_LOG_FILE
		cd $WORKING_DIR_temp
		rm -Rf $JOB_NUMBER
		clone
		cd $WORKING_DIR_temp/$JOB_NUMBER
		make_directories >> $GIT_LOG_FILE
		echo "Done."
	fi
else
	echo "$JOB_NUMBER already resident in $WORKING_DIR_temp"
	echo "Updating repo...."
	cd "$WORKING_DIR_temp/$JOB_NUMBER"
	git add --all >> $GIT_LOG_FILE
	git commit -a -m "$JOB_NUMBER Caching Commit" -q >> $GIT_LOG_FILE
	echo "#### $JOB_NUMBER #### - PULL BEIGN" >> $GIT_LOG_FILE
	git pull -q >> $GIT_LOG_FILE
	echo "#### $JOB_NUMBER #### - PULL END" >> $GIT_LOG_FILE
	echo "Done."
fi


