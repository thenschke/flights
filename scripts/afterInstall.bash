#!/usr/bin/env bash

# I have left a few things in here and will explain this further (see below)
rsync --delete-before --verbose --archive --exclude "tmp/cache/assets/sprockets/v3.0" --exclude "log/" --exclude "public/pictures/" --exclude ".env" /home/ubuntu/flights_release/ /home/ubuntu/flights/ > /var/log/deploy.log
