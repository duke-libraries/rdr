#!/usr/bin/env bash

# Update bundler, the gem bundle and create/migrate the db
gem install bundler -N
bundle install

if [ "${RAILS_ENV}" == "test" ]; then
    # Reset the test database
    bundle exec rails db:reset
else
    # Create and/or migrate the production database
    bundle exec rails db:create 2>/dev/null
    bundle exec rails db:migrate
fi

echo "IRB.conf[:SAVE_HISTORY] = 1000" > /root/.irbrc

exec "$@"
