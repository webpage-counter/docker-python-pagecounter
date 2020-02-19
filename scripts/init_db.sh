#!/usr/bin/env bash

sudo apt-get update -y 
sudo apt-get install vim -y 

sudo sed -i -e 's|bind 127.0.0.1|bind 0.0.0.0|g' /etc/redis/redis.conf
sudo sed -i -e 's|# requirepass foobared|requirepass redispass|g' /etc/redis/redis.conf
sudo systemctl restart redis