#!/bin/bash


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
