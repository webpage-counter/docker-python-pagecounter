#!/usr/bin/env bash

export HN=$(hostname)
var2=$(hostname)
# export CONSUL_HTTP_TOKEN=`cat /vagrant/keys/master.txt | grep "SecretID:" | cut -c19-`
# Create script check


cat << EOF > /usr/local/bin/check_service.sh
#!/usr/bin/env bash

systemctl status vault | grep "active (running)"
EOF

chmod +x /usr/local/bin/check_service.sh

# Register vault in consul
cat << EOF > /etc/consul.d/vault.json
{
    "service": {
        "name": "vault",
        "tags": ["${var2}"],
        "port": 8200
    },
    "checks": [
        {
            "id": "vl_service_check",
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
