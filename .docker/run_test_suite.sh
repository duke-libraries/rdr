#!/usr/bin/env bash
./test.sh run --rm app bundle exec rake spec
./test.sh down
