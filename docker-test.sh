#!/usr/bin/env bash
docker-compose run --rm -e RAILS_ENV=test admin bundle exec rake
