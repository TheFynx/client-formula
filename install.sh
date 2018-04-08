#!/bin/bash

set -o nounset -o pipefail

USER='levi'
GROUP='levi'
PACKER_VERSION='1.2.2'

while getopts u:g:p: option
do
 case "${option}"
 in
 u) USER=${OPTARG};;
 g) GROUP=${OPTARG};;
 p) PACKER_VERSION=${OPTARG};;
 esac
done

# dotFile config
client_git="https://github.com/TheFynx/client-formula.git"

mkdir -p ~/formulas

cd ~/

USER_HOME=$(pwd)

cd ~/formulas


if [[ -n "$(command -v apt-get)" ]]; then
    sudo apt-get install -y python git curl wget
    if [[ -z "$(command -v salt-call)" ]]; then
        wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
        echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" | sudo tee /etc/apt/sources.list.d/saltstack.list
        sudo apt update && sudo apt install salt-minion
    fi
elif [[ -n "$(command -v yum)" ]]; then
    echo "YUM!"
else
    echo "No supported platform found"
    exit 1
fi

if [ -d "${USER_HOME}/formulas/client-formula" ]; then
    cd ${USER_HOME}/formulas/client-formula
    git pull
else
    git clone ${client_git}
fi

if [ ! -d "/srv/salt/base" ]; then
    sudo mkdir -p /srv/salt/base
    sudo chmod 777 /srv/salt/base
    sudo ln -s ${USER_HOME}/formulas/client-formula/client /srv/salt/base/client
fi

sudo touch /etc/salt/minion_id
sudo touch /etc/salt/minion

sudo chmod 777 /etc/salt
sudo chmod 777 /etc/salt/minion
sudo chmod 777 /etc/salt/minion_id
sudo chmod 777 /srv/salt/base/top.sls

cat > '/etc/salt/minion' << EOF
file_roots:
  base:
    - /srv/salt/base
file_client: local
EOF

cat > '/etc/salt/minion_id' << EOF
id: client
EOF

cat > '/srv/salt/base/top.sls' << EOF
base:
  '*':
    - client.packages
    - client.dotfiles
    - client.config
EOF

cat > '/srv/salt/base/client/defaults.yaml' << EOF
user: $USER
group: $GROUP
packer_version: $PACKER_VERSION
EOF

sudo chmod 755 /etc/salt
sudo chmod 644 /etc/salt/minion
sudo chmod 644 /etc/salt/minion_id
sudo chmod 755 /srv/salt/base/top.sls

if [ -d '/srv/salt' ]; then
    echo ">>> Running salt to configure machine"
    sudo salt-call state.apply
    # End message
    echo ">>> Client Setup Complete!"
else
    echo "/srv/salt does not exists, Something went wrong"
    exit 1
fi
