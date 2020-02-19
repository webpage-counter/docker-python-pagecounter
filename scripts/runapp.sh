#!/bin/sh

export PATH=/home/vagrant/.local/bin:$PATH
sudo apt-get update
sudo apt-get install vim -y
sudo apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update
sudo apt-get install -y python3.7 -y
sudo pip3 install pipenv
sudo pip3 install -U Flask
sudo pip3 install redis
sudo pip3 install requests

cd /vagrant/
pipenv install
pipenv install --dev python-dotenv
pipenv install psycopg2-binary Flask-SQLAlchemy Flask-Migrate
pipenv install mistune
pipenv install redis
pipenv install requests
pipenv run flask run --host=0.0.0.0 --port=${NOMAD_PORT_http}