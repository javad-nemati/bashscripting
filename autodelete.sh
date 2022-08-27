#!/bin/bash
#every files inside the Directory DIR which is older than DAYS variable will be delete
#Don’t use this script in the important directory such as /etc directory
#DAYS variable is measured by day, for example if you set DAYS=1,all the file that older than 1 day will be delete

################### every file inside the directory $DELETE_LOG_PATH which is older than $DAY will be deleted #########################


# Author: javad nemati






DAYS=10
DATE=$(date +%Y-%m-%d)
###this two line  is not required
#DOMAIN_name_EN=`cat /etc/resolv.conf | grep domain | awk '{print $2}' | awk -F .  '{print toupper($1)}'`
#DOMAINHOME_for_del=/home/local/$DOMAIN_name_EN
PATH_FOR_DELETE=/home/
FileList=`find $PATH_FOR_DELETE -maxdepth 15  -type f \( ! -regex '.*/\..*' \) -mtime +$DAYS`
COUNTFILE=`find $PATH_FOR_DELETE -maxdepth 15  \( ! -regex '.*/\..*' \) -type f -mtime  +$DAYS | wc -l`
File_List_deleted=`find $PATH_FOR_DELETE -maxdepth 15 \( ! -regex '.*/\..*' \) -type f -mtime +$DAYS`
DELETE_LOG_PATH=/var/log/homeDirDeleted





######################################################################
if [ -d $DELETE_LOG_PATH ]; then

        echo
else

        mkdir $DELETE_LOG_PATH
fi
#-----------------------------------------------------------


######################################################################
#----------------------------------------------------------------------



wall << eof
hi,this is a message from root user
we must delete all files in your home directory which is older than $DAYS days
today is $DATE
thank you
eof






######################################################################
if [ $COUNTFILE -eq 0 ]; then
                echo "in $DATE inside the directory $DELETE_LOG_PATH no file is delete.there is no file to delete" # mail -s "delete files in home directories" root
                touch $DELETE_LOG_PATH/filelist_deleted_$DATE.log
                echo "$DATE : there is no file to delete" > $DELETE_LOG_PATH/filelist_deleted_$DATE.log

else
                touch $DELETE_LOG_PATH/filelist_deleted_$DATE.log
                ls -l $File_List_deleted > $DELETE_LOG_PATH/filelist_deleted_$DATE.log
                echo "in $DATE all the file above were deleted" >> $DELETE_LOG_PATH/filelist_deleted_$DATE.log
                find $DELETE_LOG_PATH -maxdepth 15 -type f -mtime +$DAYS \( ! -regex '.*/\..*' \)# -exec rm -rf {} \; 2>/dev/null
                echo "in $DATE all the files inside the directory $DELETE_LOG_PATH were deleted " # mail -s "delete files in home directories" root
fi

