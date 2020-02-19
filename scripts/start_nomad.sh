#!/usr/bin/env bash
set -x
sudo systemctl stop nomad
sleep 5
sudo systemctl status nomad
DOMAIN=${DOMAIN}
SERVER_COUNT=${SERVER_COUNT}
DCNAME=${DCS}
DC=${DC}
SOFIA_SERVERS="[\"10.10.58.11\"]"
JOIN_SERVER="[\"10.${DC}0.58.11\"]"
export TOKEN=`cat /vagrant/keys/agent.txt | grep "SecretID:" | cut -c19-`
var2=$(hostname)
mkdir -p /vagrant/logs
mkdir -p /vagrant/keys
mkdir -p /etc/nomad.d




# Function used for initialize Nomad. Requires 2 arguments: Log level and the hostname assigned by the respective variables.
# If no log level is specified in the Vagrantfile, then default "info" is used.
init_nomad () {
    killall nomad

    LOG_LEVEL=$1
    if [ -z "$1" ]; then
        LOG_LEVEL="info"
    fi

    if [ -d /vagrant ]; then
    mkdir /vagrant/logs
    LOG="/vagrant/logs/$2-nomad.log"
    else
    LOG="nomad.log"
    fi

    IP=$(hostname -I | cut -f2 -d' ')

    sudo useradd --system --home /etc/nomad.d --shell /bin/false nomad
    sudo chown --recursive nomad:nomad /etc/nomad.d
    sudo chmod -R 755 /etc/nomad.d/
    sudo mkdir --parents /tmp/nomad
    sudo chown --recursive nomad:nomad /tmp/nomad
    mkdir -p /tmp/nomad_logs/
    sudo chown --recursive nomad:nomad /tmp/nomad_logs/

    cat << EOF > /etc/systemd/system/nomad.service
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

# If you are running Consul, please uncomment following Wants/After configs.
# Assuming your Consul service unit name is "consul"
Wants=consul.service
After=consul.service

[Service]
User=root
KillMode=process
KillSignal=SIGINT
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad.d/
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=2
StartLimitBurst=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

EOF
}

# Function that creates the conf file for the nomad servers. It requires 8 arguments. All of them are defined in the beginning of the script.
# Arguments 5 and 6 are the SOFIA_SERVERS and BTG_SERVERS and they are twisted depending in which DC you are creating the conf file.
create_server_conf () {
    cat << EOF > /etc/nomad.d/config_${1}.hcl
    
    data_dir  = "/tmp/nomad"

    log_level = "${6}"

    name    = "${2}"

    datacenter = "${1}"

    bind_addr = "0.0.0.0" # the default

    advertise {
        # Defaults to the first private IP address.
        http = "{{ GetInterfaceIP \"enp0s8\" }}"
        rpc  = "{{ GetInterfaceIP \"enp0s8\" }}"
        serf = "{{ GetInterfaceIP \"enp0s8\" }}"
    }

    server {
        enabled          = true
        bootstrap_expect = ${4}
        server_join {
            retry_join = ${5}
            retry_max = 3
            retry_interval = "15s"
        }
    }

    consul {
        address             = "127.0.0.1:8500"
        server_service_name = "nomad"
        client_service_name = "nomad-client"
        auto_advertise      = true
        
    }


    ports {
        http = 4646
        rpc  = 4647
        serf = 4648
    }

EOF
}

# Function that creates the conf file for nomad clients. It requires 6 arguments and they are defined in the beginning of the script.
# 3rd argument shall be the JOIN_SERVER as it points the client to which server contact for cluster join.
create_client_conf () {
    cat << EOF > /etc/nomad.d/nomad_client.hcl

        data_dir  = "/tmp/nomad"

        log_level = "${6}"

        name    = "${2}"

        datacenter = "${1}"

        bind_addr = "0.0.0.0" # the default

        advertise {
            # Defaults to the first private IP address.
            http = "{{ GetInterfaceIP \"enp0s8\" }}"
            rpc  = "{{ GetInterfaceIP \"enp0s8\" }}"
            serf = "{{ GetInterfaceIP \"enp0s8\" }}"
        }

        client {
            enabled = true
            network_interface = "enp0s8"
            server_join {
                retry_join = ${5}
                retry_max = 3
                retry_interval = "15s"
            }
            options = {
                "driver.raw_exec" = "1"
                "driver.raw_exec.enable" = "1"
                "driver.raw_exec.no_cgroups" = "1"
            }
        }

        consul {
            address             = "127.0.0.1:8500"
            server_service_name = "nomad"
            client_service_name = "nomad-client"
            auto_advertise      = true
        
        }

        ports {
            http = 4646
            rpc  = 4647
            serf = 4648
        }

EOF
}


# Starting nomad

init_nomad ${LOG_LEVEL} ${var2} 


if [[ "${var2}" =~ "client-nomad-server" ]]; then
    killall nomad
    create_server_conf ${DCNAME} ${var2} ${IP} ${SERVER_COUNT} ${SOFIA_SERVERS} ${LOG_LEVEL} ${TOKEN}


    sleep 1
    sudo systemctl enable nomad
    sudo systemctl start nomad
    journalctl -f -u nomad.service > /vagrant/logs/${var2}-nomad.log &
    sleep 5
    sudo systemctl status nomad



else
    if [[ "${var2}" =~ "client-nomad-client" ]]; then
        killall nomad
        create_client_conf ${DCNAME} ${var2} ${IP} ${SERVER_COUNT} ${SOFIA_SERVERS} ${LOG_LEVEL} ${TOKEN}
    fi

    sleep 1
    
    sudo systemctl enable nomad
    sudo systemctl start nomad
    journalctl -f -u nomad.service > /vagrant/logs/${var2}-nomad.log &
    sleep 5
    sudo systemctl status nomad
    
fi

sleep 5

nomad server members
sudo usermod -aG docker nomad

set +x