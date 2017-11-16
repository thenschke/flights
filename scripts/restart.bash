#!/usr/bin/env bash

# I want to make sure that the directory is clean and has nothing left over from
# previous deployments. The servers auto scale so the directory may or may not
# exist.
#sudo kill $(cat /opt/nginx/logs/nginx.pid)

sudo rm -rf /home/ubuntu/flights/tmp
sudo mkdir /home/ubuntu/flights/tmp
sudo chmod 777 /home/ubuntu/flights/tmp
sudo chmod 777 /home/ubuntu/flights/log
sudo chmod 777 /home/ubuntu/flights/Gemfile.lock

#RAILS_ENV=production bundle exec dotenv shoryuken -R -C /home/ubuntu/flights/config/shoryuken.yml -d -L /home/ubuntu/flights/log/worker.log

#sudo /opt/nginx/sbin/nginx
