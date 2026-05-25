#!/bin/bash

#Capture CLI arguments
cmd=$1
db_username=$2
db_password=$3

# Start docker if not running
sudo systemctl status docker > /dev/null 2>&1 || sudo systemctl start docker

# Check container status
docker container inspect jrvs-psql > /dev/null 2>&1
container_status=$?

# User switch case to handle create|stop|start operations
case $cmd in
  create)
    #Check if the container is already created
    if [ $container_status -eq 0 ]; then
      echo 'Container already exists'
      exit 1
    fi

    #Check the number of arguments passed
    if [ $# -ne 3 ]; then
      echo 'Create requires username and password'
      exit 1
    fi

    #Create Container
    docker volume create pgdata
    docker run --name jrvs-psql \
      -e POSTGRES_USER=$db_username \
      -e POSTGRES_PASSWORD=$db_password \
      -d \
      -v pgdata:/var/lib/postgresql/data \
      -p 5432:5432 \
      postgres:9.6-alpine
    exit $?
    ;;
  start|stop)
    if [ $container_status -ne 0 ]; then
      echo 'Container doesn'\''t exist'
      exit 1
    fi
    docker container $cmd jrvs-psql
    exit $?
    ;;
  *)
    echo 'Illegal command'
    echo 'Commands: start|stop|create'
    exit 1
    ;;
esac

exit 0