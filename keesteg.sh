#!/bin/bash

set -o nounset			#exits if there is an unbound variable (such as $1)
set -o errexit			#exits if there is an error

function clean_up {
    # tidy exit function
    echo "Bye Bye!"
    exit			#todo
}


echo -n "Enter steghide password: "	#reads password for steghide
stty -echo			#and stores it in a variable so that it can be reused
read PASSWORD			#to re-embed the keepassx db
stty echo
echo ""				#force a carriage return to be output (change line)


TMP=$(mktemp)
steghide --extract -f -sf $1 -xf $TMP -p $PASSWORD


CHKSUM1=$(cat $TMP | md5sum | cut -f1 -d" ") #gets md5sum before running keepassx
keepassx $TMP
CHKSUM2=$(cat $TMP | md5sum | cut -f1 -d" ") #gets md5sum after running keepassx
if [ $CHKSUM1 == $CHKSUM2 ]		    #checks before and after md5s to determine if the file was modified
then
    echo "No changes made. Closing."
else					    #if it was modified, it re-embeds it in the stegofile
    echo "Re-embeding. Please wait..." 
    steghide --embed -N -f -ef $TMP -cf $1 -p $PASSWORD
fi


echo "Cleaning up..."
rm $TMP					    #removes the temporarily extracted keepassx database.
echo "Done!"
exit
