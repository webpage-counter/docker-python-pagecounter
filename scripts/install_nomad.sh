#!/usr/bin/env bash

#search nomad

which unzip curl socat jq route dig vim sshpass || {
apt-get update -y
apt-get install unzip socat jq dnsutils net-tools vim curl sshpass -y 
}

# Install docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo systemctl enable docker
sudo systemctl start docker

# Install nomad\
NOMAD_VER=${NOMAD_VER}
which nomad || {
echo "Determining Nomad version to install ..."

CHECKPOINT_URL="https://checkpoint-api.hashicorp.com/v1/check"
if [ -z "$CURRENT_VER" ]; then
    CURRENT_VER=$(curl -s "${CHECKPOINT_URL}"/nomad | jq .current_version | tr -d '"')
fi


if  ! [ "$NOMAD_VER" == "$CURRENT_VER" ]; then
    echo "THERE IS NEWER VERSION OF NOMAD: ${CURRENT_VER}"
    echo "Install is going to proceed with the older version: ${NOMAD_VER}"
fi

if [ -f "/vagrant/pkg/nomad_${NOMAD_VER}_linux_amd64.zip" ]; then
		echo "Found Nomad in /vagrant/pkg"
else
    echo "Fetching Nomad version ${NOMAD_VER} ..."
    mkdir -p /vagrant/pkg/
    curl -s https://releases.hashicorp.com/nomad/${NOMAD_VER}/nomad_${NOMAD_VER}_linux_amd64.zip -o /vagrant/pkg/nomad_${NOMAD_VER}_linux_amd64.zip
    if [ $? -ne 0 ]; then
        echo "Download failed! Exiting."
        exit 1
    fi
fi

echo "Installing Nomad version ${NOMAD_VER} ..."
pushd /tmp
unzip /vagrant/pkg/nomad_${NOMAD_VER}_linux_amd64.zip 
sudo chmod +x nomad
sudo mv nomad /usr/local/bin/nomad

}
