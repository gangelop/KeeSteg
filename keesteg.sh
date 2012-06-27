#!/bin/sh

set -o nounset			#exits if there is an unbound variable (such as $1)
set -o errexit			#exits if there is an error

unset PASSWORD TMP CHKSUM1 CHKSUM2  #unsets the variables we will use.. just in case.

echo -n "Enter steghide password: "	#reads password for steghide
stty -echo			#and stores it in a variable so that it can be reused
read PASSWORD			#to re-embed the keepassx db
stty echo
echo ""				#force a carriage return to be output (change line)


TMP=$(mktemp)
steghide --extract -f -sf $1 -xf $TMP -p $PASSWORD
if [ 0 == $(du $TMP | cut -f1) ]	    #check if TMP file is empty
then					    #if it is empty, exits
    echo "File didn't extract. Exiting."
    rm $TMP
    unset PASSWORD TMP
    exit 1
fi


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
unset PASSWORD TMP CHKSUM1 CHKSUM2	    #unsets the variables.
echo "Done!"
