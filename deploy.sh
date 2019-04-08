#!/bin/bash

./deploy_functions.sh

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

# Should the script run the composer install
composer=

# Should the script clear caches
cache=


# Cycle through the arguments and resolve them, and set as needed
for arg in "$@"

do
    if [ -v environment["$arg"] ]
    then
        path=${environment[$arg]}
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

done

# Start the process
echo "Deploying to $path"

# switch to the correct directory
cd $path

# Git Pull the repo
git pull

# Run the artisan migration process (always run)
php art migrate --force

# Restart the queue worker if told to
if [ $queue == 1 ]
then
    restart_queue_worker
fi

# Run the composer install if told to
if [ $composer == 1 ]
then
    composer_install
fi

echo "finished - have a nice day :)"







