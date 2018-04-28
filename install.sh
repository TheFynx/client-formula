#!/bin/bash

set -o nounset -o pipefail

USER='levi'
GROUP='levi'
PACKER_VERSION='1.2.2'
TERRAFORM_VERSION='0.11.6'
RUBY_VERSION='2.5.1'
PYTHON_VERSION='3.6.5'
GOLANG_VERSION='1.10.1'
ATOM_USER='thefynx'
QUICK='n'

print_help() {
  echo ">>> Usage:"
  echo "-u | Pass Customer User - install.sh -u USER - Default: ${USER}"
  echo "-g | Pass Customer Group - install.sh -g GROUP - Default: ${GROUP}"
  echo "-p | Pass Packer Version to Install - install.sh -p 1.2.2 - Default: ${PACKER_VERSION}"
  echo "-t | Pass Terraform Version to Install - install.sh -t 0.11.6 - Default: ${TERRAFORM_VERSION}"
  echo "-r | Pass Ruby Version to Set for RBENV - install.sh -r 2.5.0 - Default: ${RUBY_VERSION}"
  echo "-py | Pass Python Version to Set for PYENV - install.sh -r 3.5.0 - Default: ${PYTHON_VERSION}"
  echo "-go | Pass Golang Version to Set for GOENV - install.sh -r 1.10.1 - Default: ${GOLANG_VERSION}"
  echo "-a | Pass Atom User to installed starred items from - install.sh -a USERNAME - Default: ${ATOM_USER}"
  echo "-q | Set quick run mode, does not include longer running states - install.sh -q y - Default: ${QUICK}"
  echo "-? | List this help menu"
}

while getopts u:g:p:t:r:py:go:a:q:? option
do
 case "${option}"
 in
 u) USER=${OPTARG};;
 g) GROUP=${OPTARG};;
 p) PACKER_VERSION=${OPTARG};;
 t) TERRAFORM_VERSION=${OPTARG};;
 r) RUBY_VERSION=${OPTARG};;
 py) PYTHON_VERSION=${OPTARG};;
 go) GOLANG_VERSION=${OPTARG};;
 a) ATOM_USER=${OPTARG};;
 q) QUICK=${OPTARG};;
 ?) print_help; exit 2;;
 esac
done

echo ">>> Client Install: Initiating"

# dotFile config
client_git="https://github.com/TheFynx/client-formula.git"

mkdir -p ~/formulas

cd ~/

USER_HOME=$(pwd)
HOSTNAME=$(hostname)

cd ~/formulas

echo ">>> Client Install: Installing Base Packages"

if [[ -n "$(command -v apt-get)" ]]; then
    sudo apt-get install -y python git curl wget
    if [ -z "$(command -v salt-call)" ]; then
        wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
        echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" | sudo tee /etc/apt/sources.list.d/saltstack.list
        sudo apt update && sudo apt install salt-minion
    fi
elif [ -n "$(command -v yum)" ]; then
    echo ">>> Client Error: Yum not supported yet"
elif [ -n "$(command -v pacman)" ]; then
    echo ">>> Client Error: Pacman not supported yet"
else
    echo ">>> Client Error: No supported platform found"
    exit 1
fi

echo ">>> Client Install: Base Packages Installed"

# READ and Ask for GIT keys
# curl -H "Authorization: token OAUTH-TOKEN" --data '{"title":"test-key","key":"'"$(cat ~/.ssh/id_rsa.pub)"'"}' https://api.github.com/user/keys
read -p ">>> Client Install: Do you have a secrets file? y/n (default n) " secretAnswer

if [ "${secretAnswer}" == 'y' ]; then
  read -p ">>> Client Install: Please enter path to secret file to source (i.e. /path/to/creds.sh) " secretPath
  . ${secretPath}

  if [ ! -f "${USER_HOME}/.ssh/git" ]; then
    echo ">>> Client Install: Generating Git SSH Keys"
    ssh-keygen -t rsa -N "" -f ${USER_HOME}/.ssh/git
  fi

  echo ">>> Client Install: Uploading Git SSH Keys"
  if [ -z "$(curl -s -H "Authorization: token ${GH_TOKEN}" https://api.github.com/user/keys | grep "${HOSTNAME}")" ]; then
    curl -H "Authorization: token ${GH_TOKEN}" --data '{"title":"'"${HOSTNAME}"'","key":"'"$(cat ~/.ssh/git.pub)"'"}' https://api.github.com/user/keys
  else
    echo ">>> Client Install: Git Key Already Exists"
  fi

  echo ">>> Client Install: Adding SSH Config for Git SSH Key"
  touch ${USER_HOME}/.ssh/config
  if [ -z "$(grep 'github' ~/.ssh/config)" ]; then
    cat > "${USER_HOME}/.ssh/config" << EOF
Host github.com
  User git
  Hostname github.com
  PreferredAuthentications publickey
  IdentityFile /home/${USER}/.ssh/git
EOF
  fi
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
id: ${HOSTNAME}
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
python_version: $PYTHON_VERSION
golang_version: $GOLANG_VERSION
atom_user: $ATOM_USER
ruby_versions:
  - 2.5.0
  - 2.5.1
python_versions:
  - 2.7.14
  - 3.6.5
golang_versions:
  - 1.10.1
  - 1.9.5
EOF

sudo chmod 755 /etc/salt
sudo chmod 644 /etc/salt/minion
sudo chmod 644 /etc/salt/minion_id
sudo chmod 755 /srv/salt/base/top.sls

if [ -d '/srv/salt' ]; then
    echo ">>> Client Install: Running salt to configure machine"
    if [ "$QUICK" == 'y' ]; then
      sudo salt-call grains.set force=True quick yes
    else
      sudo salt-call grains.set force=True quick no
    fi
    sudo salt-call state.apply
    # End message
    echo ">>> Client Install: Complete!"
else
    echo ">>> Client Error: /srv/salt does not exists, Something went wrong"
    exit 1
fi
