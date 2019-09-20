#!/bin/bash

result=`ps aux | grep -i "startup.php" | grep -v "grep" | wc -l`

if [ $result -ge 1 ]
   then
        echo "script is running"
   else
        echo "script is not running"

        #try to start the smdr server
        exec php /srv/SMDR-Server/app/startup.php > /dev/null &

        sleep 2

        retry=`ps aux | grep -i "startup.php" | grep -v "grep" | wc -l`

        if [ $retry -ge 1 ]
           then
                echo "Server was started"

                {
                        echo To: development@global4.co.uk
                        echo From: systems@global4.co.uk
                        echo Subject: SMDR ALERT - RESTARTED
                        echo
                        echo The SMDR Service seems to have stopped - but i restarted it like a good server elf


                } | /usr/sbin/ssmtp steve.temple@global4.co.uk

           else
                {
                        echo To: development@global4.co.uk
                        echo From: systems@global4.co.uk
                        echo Subject: SMDR ALERT - DOWN
                        echo
                        echo The SMDR Service seems to have stopped - oh bugger, someone needs spanking!!


                } | /usr/sbin/ssmtp steve.temple@global4.co.uk
        fi
fi
