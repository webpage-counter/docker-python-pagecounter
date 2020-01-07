#!/usr/bin/env bash




export PATH=/home/ubuntu/.local/bin:$PATH
apt-get update
apt-get install vim -y
apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget curl
apt-get install software-properties-common -y
add-apt-repository ppa:deadsnakes/ppa -y
apt-get update
apt-get install -y python3.7
apt install python3-pip -y
pip3 install pipenv
pip3 install -U Flask
pip3 install redis
pip3 install requests
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
cd /tmp/app
pipenv install
pipenv install --dev python-dotenv
pipenv install psycopg2-binary Flask-SQLAlchemy Flask-Migrate
pipenv install mistune
pipenv install redis
pipenv install requests



curl -L -o /tmp/cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v0.8.1/cni-plugins-linux-amd64-v0.8.1.tgz
mkdir -p /opt/cni/bin
tar -C /opt/cni/bin -xzf /tmp/cni-plugins.tgz