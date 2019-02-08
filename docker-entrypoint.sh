#!/usr/bin/env bash

# Remove a potentially pre-existing server.pid for Rails.
rm -f tmp/pids/server.pid

# Update bundler, the gem bundle and create/migrate the db
gem install bundler -N
bundle install
bundle exec rails db:create 2>/dev/null
bundle exec rails db:migrate

echo "IRB.conf[:SAVE_HISTORY] = 1000" > /root/.irbrc

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
