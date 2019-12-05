#!/bin/bash
wait-for-it db:5432 -t 30
bundle exec rake db:setup 2>/dev/null
bundle exec rake db:migrate
exec "$@"
