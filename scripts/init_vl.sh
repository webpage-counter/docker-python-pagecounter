#!/usr/bin/env bash
set -x
hostname=$(hostname)

sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
sudo mkdir -p /etc/vault.d 
sudo useradd --system --home /etc/vault.d --shell /bin/false vault
sudo chown -R vault:vault /etc/vault.d/


#lets kill past instance
sudo killall vault &>/dev/null

cat << EOF > /etc/systemd/system/vault.service
[Unit]
Description="HashiCorp Vault"
Documentation=https://www.vaultproject.io
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/usr/local/bin/vault server  -dev -dev-listen-address=0.0.0.0:8200
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
Restart=on-failure
LimitNOFILE=65536


[Install]
WantedBy=multi-user.target

EOF




#start vault
sudo systemctl enable vault
sudo systemctl start vault
journalctl -f -u vault.service > /vagrant/logs/${hostname}-vl.log &
sudo systemctl status vault
echo vault started
sleep 3 

grep VAULT_ADDR /home/vagrant/.bash_profile || {
  echo export VAULT_ADDR=http://127.0.0.1:8200 | sudo tee -a /home/vagrant/.bash_profile
}

echo "vault token:"
cat /etc/vault.d/.vault-token
echo -e "\nvault token is on /etc/vault.d/.vault-token"

# setup .bash_profile
grep VAULT_TOKEN ~/.bash_profile || {
  echo export VAULT_TOKEN=$(cat /etc/vault.d/.vault-token) | sudo tee -a /home/vagrant/.bash_profile
}

#cat /etc/vault.d/.vault-token > /vagrant/keys/vault.txt

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=$(cat /etc/vault.d/.vault-token)

vault secrets enable -version=1 kv
vault kv put kv/redis pass=redispass
vault auth enable approle
vault policy write redis /vagrant/policy/redis-pol.hcl
vault policy write user_token /vagrant/policy/vault-user-token.hcl 
vault token create -policy=user_token > /vagrant/keys/vault.txt -field "token"
vault write auth/approle/role/redis policies="redis"
consul kv put vault/token $(cat /vagrant/keys/vault.txt)
