#!/usr/bin/env bash
export COMPOSE_PROJECT_NAME=rdr-test
export RAILS_ENV=test
docker-compose -f docker-compose.yml -f docker-compose.test.yml "$@"
