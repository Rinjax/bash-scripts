#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

#DIR=`dirname $0`

# Environment array which maps to the folders
declare -A environment

environment[global4]=/var/www/_global

environment[access]=/var/www/portal_access
environment[admin]=/var/www/portal_admin
environment[affinity]=/var/www/portal_affinity
environment[affinitystatstics]=/var/www/portal_affinity_statistics
environment[billing]=/var/www/portal_billing
environment[cdr]=/var/www/portal_cdr
environment[elevate]=/var/www/portal_elevate
environment[marketing]=/var/www/portal_marketing
environment[payment]=/var/www/portal_payment
environment[portal]=/var/www/portal_portal
environment[recon]=/var/www/portal_recon
environment[statistics]=/var/www/portal_statistics
#environment[g4cms]=/var/www/portal_webcms_g4
environment[wbwebsite]=/var/www/website_weekly_broadband


# Environment array which maps to the folders
declare -A workerqueues

workerqueues[global4]=global

workerqueues[access]=queue_portal_access
workerqueues[admin]=queue_portal_admin
workerqueues[affinity]=queue_portal_affinity
workerqueues[affinitystatstics]=queue_portal_affinity_statistics
workerqueues[billing]=queue_portal_billing
workerqueues[cdr]=queue_portal_cdr
workerqueues[elevate]=queue_portal_elevate
workerqueues[marketing]=queue_portal_marketing
workerqueues[payment]=queue_portal_payment
workerqueues[portal]=queue_portal_portal
workerqueues[recon]=queue_portal_recon
workerqueues[statistics]=queue_portal_statistics
#environment[g4cms]=/var/www/portal_webcms_g4
workerqueues[wbwebsite]=queue_website_weekly_broadband


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
        queuename=${workerqueue[$arg]}
    fi

    if [ "$arg" == "-q" ]
    then
        queue=1

        while getopts ":q:" opt; do
            queuename="$queuename_$OPTARG"
        done
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
    for d in "${environment[@]}" ; do
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
            printf "${GREEN}Complete ${NC}\n"
        } || {
            printf "${RED}Failed to Deploy $d ${NC}\n"
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
        supervisorctl restart "$queuename"
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







