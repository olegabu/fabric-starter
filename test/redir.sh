#!/bin/bash

exec 3>&1 4>&2 #set up extra file descriptors

error=$( { ./useless.sh | sed 's/Output/Useless/' 2>&4 1>&3; } 2>&1 )

echo "The message is \"${error}.\""

exec 3>&- 4>&- # release the extra file descriptors