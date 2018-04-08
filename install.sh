#!/bin/bash

set -o nounset -o pipefail

USER='levi'
GROUP='levi'
PACKER_VERSION='1.2.2'
TERRAFORM_VERSION='0.11.6'
RUBY_VERSION='2.5.0'
ATOM_USER='thefynx'

while getopts u:g:p:t:r:a: option
do
 case "${option}"
 in
 u) USER=${OPTARG};;
 g) GROUP=${OPTARG};;
 p) PACKER_VERSION=${OPTARG};;
 t) TERRAFORM_VERSION=${OPTARG};;
 r) RUBY_VERSION=${OPTARG};;
 a) ATOM_USER=${OPTARG};;
 esac
done

echo ">>> Client Install: Initiating"

# dotFile config
client_git="https://github.com/TheFynx/client-formula.git"

mkdir -p ~/formulas

cd ~/

USER_HOME=$(pwd)

cd ~/formulas

echo ">>> Client Install: Installing Base Packages"

if [[ -n "$(command -v apt-get)" ]]; then
    sudo add-apt-repository -y ppa:cpick/hub
    sudo apt-get update
    sudo apt-get install -y python git curl wget hub
    if [[ -z "$(command -v salt-call)" ]]; then
        wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
        echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" | sudo tee /etc/apt/sources.list.d/saltstack.list
        sudo apt update && sudo apt install salt-minion
    fi
elif [[ -n "$(command -v yum)" ]]; then
    echo ">>> Client Error: Yum not supported yet"
elif [[ -n "$(command -v pacman)" ]]; then
    echo ">>> Client Error: Pacman not supported yet"
else
    echo ">>> Client Error: No supported platform found"
    exit 1
fi

echo ">>> Client Install: Base Packages Installed"

if [ ! -f ${USER_HOME}/.ssh/git.key ]; then
  echo ">>> Client Install: Generating Git SSH Keys"
  ssh-keygen -t rsa -N "" -f git.key
fi

if [ -d "${USER_HOME}/formulas/client-formula" ]; then
    cd ${USER_HOME}/formulas/client-formula
    git pull
    echo ">>> Client Install: Formula Updated"
else
    git clone ${client_git}
    echo ">>> Client Install: Formula Cloned"
fi

echo ">>> Client Install: Setting Proper Access for Salt Files"

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

echo ">>> Client Install: Creating Salt Configs"

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
    - client
EOF

cat > '/srv/salt/base/client/defaults.yaml' << EOF
user: $USER
group: $GROUP
packer_version: $PACKER_VERSION
terraform_version: $TERRAFORM_VERSION
ruby_version: $RUBY_VERSION
atom_user: $ATOM_USER
EOF

sudo chmod 755 /etc/salt
sudo chmod 644 /etc/salt/minion
sudo chmod 644 /etc/salt/minion_id
sudo chmod 755 /srv/salt/base/top.sls

if [ -d '/srv/salt' ]; then
    echo ">>> Client Install: Running salt to configure machine"
    sudo salt-call state.apply
    # End message
    echo ">>> Client Install: Complete!"
else
    echo ">>> Client Error: /srv/salt does not exists, Something went wrong"
    exit 1
fi
