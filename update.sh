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

echo "################################################"
if [[ $1 == true ]]; then
    echo "Aktualizacja glownej aplikacji"
    cd aplikacja-glowna
    docker service update --image misieq/weii_ai_aplikacja_glowna_backend app_glowna_backend
    docker service update --image misieq/weii_ai_aplikacja_glowna_backend app_glowna_celery
    docker service update --image misieq/weii_ai_aplikacja_glowna_frontend app_glowna_frontend
    cd ..
    sleep 10
fi
if [[ $2 == true ]]; then
    echo "Aktualizacja aplikacji testowej"
    cd aplikacja-testujaca
    docker service update --image misieq/weii_ai_aplikacja_testujaca_backend app_test_backend-test
    docker service update --image misieq/weii_ai_aplikacja_testujaca_backend app_test_celery
    docker service update --image misieq/weii_ai_aplikacja_testujaca_frontend app_test_frontend-test
    cd ..
    sleep 10
fi
echo "################################################"

###############################################################
remove_lock "${cmd_unlocking}"
