#!/bin/bash

set -o nounset -o pipefail

# dotFile config
client_git="https://github.com/TheFynx/client-formula.git"

mkdir -p ~/formulas

cd ~/

USER_HOME=$(pwd)

cd ~/formulas

if [ -f '/etc/*-release' ]; then
    platform=$(cat /etc/*-release | awk '{print $1}')
elif [ -n $(command -v lsb_release) ]; then
    platform=$(lsb_release -a | awk 'NR==1{print $3}')
else
    platform=''
fi


if [[ "$platform" == "Ubuntu" ]]; then
    sudo apt-get install -y python git curl
elif [[ "$platform" == "Debian" ]]; then
    sudo apt-get install -y python git curl
else
    echo "No supported platform found"
fi

if [ -z "$(command -v salt-call)" ]; then
    if [ -n "$(command -v curl)" ]; then
        curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com
        sudo sh bootstrap-salt.sh
    elif [ -n "$(command -v wget)" ]; then
        wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
        sudo sh bootstrap-salt.sh
    elif [ -n "$(command -v python)" ]; then
        python -c 'import urllib; print urllib.urlopen("https://bootstrap.saltstack.com").read()' > bootstrap-salt.sh
        sudo sh bootstrap-salt.sh
    else
        echo "!!!!!!!!!!!!!!"
        echo "Need to install Curl, WGET, or Python to continue!"
    fi
fi

if [ -d "${USER_HOME}/formulas/client-formula" ]; then
    cd ${USER_HOME}/formulas/client-formula
    git pull
else
    git clone ${client_git}
fi

if [ ! -d "/srv/salt" ]; then
  sudo mkdir -p /srv/salt/base
  sudo ln -s ${USER_HOME}/formulas/client-formula/client /srv/salt/base/client
fi

sudo touch /etc/salt/minion_id
sudo touch /etc/salt/minion
sudo touch /srv/salt/top.sls

sudo chmod 777 /etc/salt
sudo chmod 777 /etc/salt/minion
sudo chmod 777 /etc/salt/minion_id
sudo chmod 777 /srv/salt/top.sls

cat > '/etc/salt/minion' << EOF
file_roots:
  base:
    - /srv/salt/base
file_client: local
EOF

cat > '/etc/salt/minion_id' << EOF
id: client
EOF

cat > '/srv/salt/top.sls' << EOF
base:
  '*':
    - client.packages
    - client.dotfiles
EOF

sudo chmod 755 /etc/salt
sudo chmod 644 /etc/salt/minion
sudo chmod 644 /etc/salt/minion_id
sudo chmod 755 /srv/salt/top.sls

if [ -d '/srv/salt' ]; then
  echo ">>> Running salt to configure machine"
  sudo salt-call state.apply
  # End message
  echo ">>> Client Setup Complete!"
else
  echo "/srv/salt does not exists, Something went wrong"
  exit 1
fi
