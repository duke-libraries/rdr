#!/usr/bin/env bash
export COMPOSE_PROJECT_NAME=rdr-dev
export RAILS_ENV=development
docker-compose -f docker-compose.yml -f docker-compose.dev.yml "$@"
