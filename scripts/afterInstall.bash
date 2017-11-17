#!/usr/bin/env bash

# I have left a few things in here and will explain this further (see below)
rsync --delete-before --verbose --archive --exclude "tmp/cache/assets/sprockets/v3.0" --exclude "log/" --exclude "public/pictures/" --exclude ".env" /home/ec2-user/flights_release/ /home/ec2-user/flights/ > /var/log/deploy.log
