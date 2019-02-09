#!/bin/bash

# Update bundler, the gem bundle and create/migrate the db
gem install bundler -N
bundle install

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
