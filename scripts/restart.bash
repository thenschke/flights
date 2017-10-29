#!/usr/bin/env bash

# I want to make sure that the directory is clean and has nothing left over from
# previous deployments. The servers auto scale so the directory may or may not
# exist.
sudo kill $(cat /opt/nginx/logs/nginx.pid)

sudo rm -rf /home/ec2-user/flights/tmp
sudo mkdir /home/ec2-user/flights/tmp
sudo chmod 777 /home/ec2-user/flights/tmp
sudo chmod 777 /home/ec2-user/flights/log
sudo chmod 777 /home/ec2-user/flights/Gemfile.lock

RAILS_ENV=production bundle exec dotenv shoryuken -R -C /home/ec2-user/flights/config/shoryuken.yml -L /home/ec2-user/flights/log/worker.log

sudo /opt/nginx/sbin/nginx
