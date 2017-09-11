#!/bin/bash

set -o nounset -o pipefail

# dotFile config
dotfilesGit="https://github.com/TheFynx/dotFiles.git"

tempInstallDir="/tmp/salt"

mkdir -p $tempInstallDir

cd $tempInstallDir

function prompt_continue () {
  echo "!!!!!!!!!!!!!!!!!!!!!!!"
  echo "dotFiles encountered an error in the previous step."
  read -p "Ignore the error and contine with installation? [yN] " </dev/tty
  case "$REPLY" in
    [yY]*) return
      ;;
    *) echo "Not cleaning up $tempInstallDir; exiting."
      exit 2
      ;;
  esac
}

if [ -f '/etc/*-release' ]; then
    platform=$(cat /etc/*-release | awk 'NR==1{print $1}')
elif [ -n $(command -v lsb_release) ]; then
    platform=$(lsb_release -a)
else
    platform=''
fi

if [[ "$platform" =~ ".*Ubuntu" ]]
    apt-get install -y python git
elif [[ "$platform" =~ ".*Debian" ]]
    apt-get install -y python git
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
    elif [ -n $(command) -v python ]
        python -c 'import urllib; print urllib.urlopen("https://bootstrap.saltstack.com").read()' > bootstrap-salt.sh
        sudo sh bootstrap-salt.sh
    else
        echo "!!!!!!!!!!!!!!"
        echo "Need to install Curl, WGET, or Python to continue!"
    fi
fi

echo ">>> Running salt to configure machine"
salt-call --local state.apply || prompt_continue

# cleanup
cd - || prompt_continue
sudo rm -rf "$tempInstallDir"

# End message
cat <<EOF
>>> Client Setup Complete!
EOF