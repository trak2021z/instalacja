#!/bin/bash


docker service scale app_glowna_backend=5
docker service scale app_glowna_frontend=5
docker service scale app_glowna_celery=5
docker service scale app_glowna_celery-beat=5
docker service scale app_glowna_db=5
docker service scale app_glowna_rabbitmq=5
docker service scale app_test_backend-test=5
docker service scale app_test_frontend-test=5
docker service scale app_test_db-test=5
docker service scale app_test_rabbitmq=5
docker service scale app_test_celery=5
