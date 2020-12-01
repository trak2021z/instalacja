#!/bin/bash

set -e 
 
working_dir=$1
lock_file_or_dir="./.scale.lock"
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

docker service scale app_glowna_backend=$1
#docker service scale app_glowna_frontend=$1
docker service scale app_glowna_celery=$1
#docker service scale app_glowna_celery-beat=$1
#docker service scale app_glowna_db=$1
#docker service scale app_glowna_rabbitmq=$1
#docker service scale app_test_backend-test=$2
#docker service scale app_test_frontend-test=$2
#docker service scale app_test_db-test=$2
#docker service scale app_test_rabbitmq=$2
#docker service scale app_test_celery=$2

###############################################################
remove_lock "${cmd_unlocking}"
