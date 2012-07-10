#!/bin/bash

#exits if there is an unbound vriable or an error
set -o nounset
set -o errexit

function clean_up 
{
    #tidy exit function
    #todo
    echo "Bye Bye!"
    exit
}

#Reads the password for steghide so that we can use it twice if we need
#to re-embed the keepassx db later.
echo -n "Enter steghide password: "
stty -echo
read PASSWORD
stty echo
echo ""


TMP=$(mktemp)
steghide --extract -f -sf $1 -xf $TMP -p $PASSWORD


CHKSUM1=$(cat $TMP | md5sum | cut -f1 -d" ")
keepassx $TMP
CHKSUM2=$(cat $TMP | md5sum | cut -f1 -d" ")
if [ $CHKSUM1 == $CHKSUM2 ]
then
    echo "No changes made. Closing."
else
    echo "Re-embeding. Please wait..." 
    steghide --embed -N -f -ef $TMP -cf $1 -p $PASSWORD
fi


echo "Cleaning up..."
rm $TMP
echo "Done!"
exit
