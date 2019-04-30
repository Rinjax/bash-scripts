#!/bin/bash

#DIR=`dirname $0`

#. $DIR/deploy_functions.sh

# Environment array which maps to the folders
declare -A environment

environment[admin]=/var/www/portal_admin
environment[affinity]=/var/www/portal_affinity
environment[global4]=/var/www/_global
environment[recon]=/var/www/portal_recon

# Path which the script will run against. Default is the current working directory, change to the environment array values
# if the parameter has been used
path=$PWD

# Should the script run the artisan migrate process
migrate=

# Should the script restart the queue worker process
queue=

# Name of the queue to restart - should be the same as the alias/environment key
queuename=

# Should the script run the composer install
composer=

# Should the script clear caches
cache=

# Should the script deploy to all Laravel instances
all=


# Cycle through the arguments and resolve them, and set as needed
for arg in "$@"

do
    if [ -v environment["$arg"] ]
    then
        path=${environment[$arg]}
        queuename="$arg"
    fi

    if [ "$arg" == "-q" ] || [ "$arg" == "--queue-worker" ]
    then
        queue=1
    fi

    if [ "$arg" == "-c" ] || [ "$arg" == "--composer-install" ]
    then
        composer=1
    fi

    if [ "$arg" == "-cc" ] || [ "$arg" == "--cache-clear" ]
    then
        cache=1
    fi

    if [ "$arg" == "-a" ] || [ "$arg" == "--all" ]
    then
        all=1
    fi

done

if [ "$all" == 1 ]
then
    for d in /var/www/*/ ; do
        {
            printf "Deploying to $d\n"
            cd $d
            printf " Git Pulling\n"
            git pull
            printf "Installing packages\n"
            composer install
            printf "Updating database\n"
            php artisan migrate --force
            printf "Clearing Cache\n"
            php artisan cache:clear
            printf "${GREEN}Complete\n"
        } || {
            printf "${RED}Failed to Deploy $d\n"
        }
    done
else

    # Start the process
    echo "Deploying to $path"

    # switch to the correct directory
    cd $path

    # Git Pull the repo
    git pull

    # Run the artisan migration process (always run)
    php $path/artisan migrate --force

    # Restart the queue worker if told to
    if [ -n "$queuename" ] && [ "$queue" == 1 ]
    then
        supervisorctl restart queue_"$queuename"
    fi

    if [ ! -n "$queuename" ] && [ "$queue" == 1 ]
    then
        echo "Flag detected to restart the queue worker, but environment alias was not found"
    fi

    # Run the composer install if told to
    if [ "$composer" == 1 ]
    then
        composer install
    fi

    # Clear the laravel cache if told to
    if [ "$cache" == 1 ]
    then
        php $path/artisan cache:clear
    fi

    echo "finished - have a nice day :)"
fi







