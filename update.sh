#!/bin/bash

# poza serwerem produkcyjym nie zadziala

set -e 
 
working_dir=$1
lock_file_or_dir="./.update.lock"
cmd_locking="touch ${lock_file_or_dir}"
cmd_check_lock="test -f ${lock_file_or_dir}"
cmd_unlocking="rm -rf ${lock_file_or_dir}"

function is_already_running()
{
  local cmd_check_lock=${1}
  ${cmd_check_lock} |{
    return 1
   }
}

function create_lock()
{   
  local cmd_locking=${1}

  ${cmd_locking} || {
     printf "cannot create lock \n"
     exit 2
   }
}

function remove_lock()
{
  local cmd_unlocking="${1}"
  ${cmd_unlocking} || {
    printf "Cannot unlock\n"
    exit 3
  }
}

trap 'remove_lock "${cmd_unlocking}"' SIGINT SIGTERM

if is_already_running "${cmd_check_lock}"; then
  printf "Cannot acquire lock - another instance is running, exiting \n"
  exit 1
fi

create_lock "${cmd_locking}"
##############################################################

if [[ $1 == "" && $2 == "" ]]; then
    echo "Nie podano zadnego argumentu podaj argumentu, true true - glowna i testowa, true false - glowna, false true - testowa"
    exit 1
fi

cd aplikacja-testujaca
git submodule foreach git pull origin main
cd ..
cd aplikacja-glowna
git submodule foreach git pull origin main
cd ..

echo "################################################"
if [[ $1 == true ]]; then
    echo "Aktualizacja glownej aplikacji"
    cd aplikacja-glowna
    docker stack rm app_glowna
    sleep 15
    docker container prune -f
    docker image prune -f
    sleep 10
    docker image pull  misieq/weii_ai_aplikacja_glowna_backend:latest
    docker image pull  misieq/weii_ai_aplikacja_glowna_frontend:latest
    sleep 15
    docker stack deploy -c docker-compose.yaml app_glowna
    cd ..
    sleep 15
fi
if [[ $2 == true ]]; then
    echo "Aktualizacja aplikacji testowej"
    cd aplikacja-testujaca
    docker stack rm app_test
    sleep 15
    docker container prune -f
    docker image prune -f
    sleep 15
    docker image pull  misieq/weii_ai_aplikacja_testujaca_backend:latest
    docker image pull  misieq/weii_ai_aplikacja_testujaca_frontend:latest
    sleep 10
    docker stack deploy -c docker-compose.yaml app_test
    sleep 10
    cd ..
fi
/bin/sh ./scale.sh 5
docker image prune -f
echo "################################################"

###############################################################
remove_lock "${cmd_unlocking}"
