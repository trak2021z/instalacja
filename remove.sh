#!/bin/bash

# poza serwerem produkcyjym nie zadziala

set -e 
 
working_dir=$1
lock_file_or_dir="./.remove.lock"
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

echo "################################################"
echo "Usuwanie aplikacji glownej"
docker stack rm app_glowna | true
echo "Usuwanie aplikacji testujacej"
docker stack rm app_test | true
echo "Usuwanie sieci"
docker network rm over | true 

###############################################################
remove_lock "${cmd_unlocking}"
