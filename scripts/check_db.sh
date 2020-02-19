#!/usr/bin/env bash

export HN=$(hostname)
var2=$(hostname)
# export CONSUL_HTTP_TOKEN=`cat /vagrant/keys/master.txt | grep "SecretID:" | cut -c19-`
# Create script check

cat << EOF > /usr/local/bin/check_db.sh
#!/usr/bin/env bash

redis-cli -a 'redispass' ping | grep "PONG"
EOF

cat << EOF > /usr/local/bin/check_service.sh
#!/usr/bin/env bash

systemctl status redis-server | grep "active (running)"
EOF

chmod +x /usr/local/bin/check_db.sh
chmod +x /usr/local/bin/check_service.sh

# Register db in consul
cat << EOF > /etc/consul.d/db.json
{
    "service": {
        "name": "redis",
        "tags": ["${var2}"],
        "port": 6379,
        "connect": { "sidecar_service": {} }
    },
    "checks": [
        {
            "id": "db_script_check",
            "name": "Ping Pong check",
            "args": ["/usr/local/bin/check_db.sh", "-limit", "256MB"],
            "interval": "10s",
            "timeout": "1s"
        },
        {
            "id": "db_service_check",
            "name": "Service check",
            "args": ["/usr/local/bin/check_service.sh", "-limit", "256MB"],
            "interval": "10s",
            "timeout": "1s"
        }
    ]
}
EOF

sleep 5
consul reload
sleep 30
consul reload


cat << EOF > /etc/systemd/system/connect-db.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul connect proxy -sidecar-for redis
ExecReload=/usr/local/bin/consul connect proxy -sidecar-for redis
KillMode=process
Restart=on-failure
LimitNOFILE=65536


[Install]
WantedBy=multi-user.target

EOF

sudo systemctl daemon-reload
sudo systemctl enable connect-db
sudo systemctl start connect-db