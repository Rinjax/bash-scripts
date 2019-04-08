#!/usr/bin/env bash


function restart_queue_worker () {
    PIDID=$(ps -A -o pid,cmd|grep queue:work|head -n 1| awk '{print $1}')

    if [ -n $PIDID ]
    then
        echo "PIDID FOUND: " $PIDID
        kill -9 $PIDID
        echo "Killed PID: " $PIDID
    fi

    nohup art queue:work --daemon > /dev/null 2>&1 &

}

function composer_install () {
    composer install
}