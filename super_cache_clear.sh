#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

for d in /var/www/*/ ; do
    {
        printf "Clearing Cache in $d\n"
        php $d/artisan cache:clear &&
        printf "${GREEN}Cleared\n"
    } || {
        printf "${RED}Failed to Clear $d\n"
    }

done