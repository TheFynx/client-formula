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
    sudo apt-get install -y python git
elif [[ "$platform" == "Debian" ]]; then
    sudo apt-get install -y python git
else
    echo "No supported platform found"
fi

if [ -z $(command -v salt-call) ]; then
    if [ -n $(command -v curl) ]; then
        curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com
        sudo sh bootstrap-salt.sh
    elif [ -n $(command -v salt-call) ]; then
        wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
        sudo sh bootstrap-salt.sh
    elif [ -n $(command) -v python ]; then
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

if [ ! -d "${USER_HOME}/formulas/client-formula/client" ]; then
  sudo ln -s ${USER_HOME}/formulas/client-formula /srv/salt
fi

sudo chmod 777 /etc/salt/minion

cat > '/etc/salt/minion' << EOF
id: client
base:
  - /srv/salt
file_client: local
EOF

sudo chmod 644 /etc/salt/minion

echo ">>> Running salt to configure machine"
sudo salt-call state.apply

# End message
cat <<EOF
>>> Client Setup Complete!
EOF
