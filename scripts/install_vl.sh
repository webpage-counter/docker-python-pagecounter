#!/usr/bin/env bash

VAULT=${VAULT}

rm -fr /tmp/vault/data
which unzip curl jq /sbin/route vim sshpass || {
apt-get update -y
apt-get install unzip jq net-tools vim curl sshpass -y 
}

mkdir -p /vagrant/pkg/


# Install vault
which vault || {
  pushd /vagrant/pkg
  [ -f vault_${VAULT}_linux_amd64.zip ] || {
    sudo wget https://releases.hashicorp.com/vault/${VAULT}/vault_${VAULT}_linux_amd64.zip
  }

  popd
  pushd /tmp

  sudo unzip /vagrant/pkg/vault_${VAULT}_linux_amd64.zip
  sudo chmod +x vault
  sudo mv vault /usr/local/bin/vault
  popd
}
