#!/usr/bin/env bash


function restart_queue_worker () {
    supervisorctl restart queue_"$1"

}

function composer_install () {
    composer install
}