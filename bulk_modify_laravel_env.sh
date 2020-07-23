#!/bin/bash

#Loops through all the directories in the /var/www folder looking for .env files, and then replaces strings from the
#provided args

for fileENV in /var/www/*/.env; do
        [ -e "$fileENV" ] || contine
        echo $fileENV

        sed -i "s/$1/$2/" $fileENV
done

