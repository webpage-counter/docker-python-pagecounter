#!/usr/bin/env bash
set -x
# export CONSUL_HTTP_TOKEN=`cat /vagrant/keys/master.txt | grep "SecretID:" | cut -c19-`


# consul intention check webapp redis || consul intention create -allow webapp redis
curl -L -o /tmp/cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v0.8.1/cni-plugins-linux-amd64-v0.8.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf /tmp/cni-plugins.tgz

nomad run /vagrant/nomad-job/fabio.nomad
nomad run /vagrant/nomad-job/web_app.nomad

set +x
