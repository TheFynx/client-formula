{% from slspath + "/map.jinja" import defaults with context %}

install_exa:
  cmd.run:
    - name: cargo install --git https://github.com/ogham/exa
    - cwd: /tmp
    - shell: /bin/bash
    - runas: {{ defaults.user }}
    - timeout: 60
    - unless: test -x /home/{{ defaults.user }}/.cargo/bin/exa

install_packer:
  cmd.run:
    - name: |
        curl https://releases.hashicorp.com/packer/{{ defaults.packer_version }}/packer_{{ defaults.packer_version }}_linux_amd64.zip -o packer.zip &&\
        unzip packer.zip -d /usr/local/bin/ &&\
        chmod +x /usr/local/bin/packer
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 60
    - unless: packer --version | grep '{{ defaults.packer_version }}'

install_terraform:
  cmd.run:
    - name: |
        curl https://releases.hashicorp.com/terraform/{{ defaults.terraform_version }}/terraform_{{ defaults.terraform_version }}_linux_amd64.zip -o terraform.zip &&\
        unzip terraform.zip -d /usr/local/bin/ &&\
        chmod +x /usr/local/bin/terraform
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 60
    - unless: terraform --version | grep '{{ defaults.terraform_version }}'

install_fonts:
  cmd.run:
    - name: |
        git clone https://github.com/powerline/fonts.git --depth=1 &&\
        cd fonts &&\
        sh ./install.sh &&\
        cd .. &&\
        rm -rf fonts
    - cwd: /tmp
    - runas: {{ defaults.user }}
    - shell: /bin/bash
    - timeout: 100
    - unless: test -x /home/{{ defaults.user }}/.local/share/fonts

install_bash_it:
  cmd.run:
    - name: |
        git clone --depth=1 https://github.com/Bash-it/bash-it.git /home/{{ defaults.user }}/.bash_it &&\
        /home/{{ defaults.user }}/.bash_it/install.sh -s -n
    - cwd: /tmp
    - shell: /bin/bash
    - runas: {{ defaults.user }}
    - timeout: 60
    - unless: test -x /home/{{ defaults.user }}/.bash_it/install.sh

install_jetbrains_toolbox:
  cmd.run:
    - name: |
        #!/bin/bash

        [ $(id -u) != "0" ] && exec sudo "$0" "$@"

        function getLatestUrl() {
        USER_AGENT=('User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36')

        URL=$(curl 'https://data.services.jetbrains.com//products/releases?code=TBA&latest=true&type=release' -H 'Origin: https://www.jetbrains.com' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.8' -H "${USER_AGENT[@]}" -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: https://www.jetbrains.com/toolbox/download/' -H 'Connection: keep-alive' -H 'DNT: 1' --compressed | grep -Po '"linux":.*?[^\\]",' | awk -F ':' '{print $3,":"$4}'| sed 's/[", ]//g')
        echo $URL
        }
        getLatestUrl

        FILE=$(basename ${URL})
        DEST=$PWD/$FILE

        wget -cO  ${DEST} ${URL} --read-timeout=5 --tries=0
        DIR="/opt/jetbrains-toolbox"

        if mkdir ${DIR}; then
            tar -xzf ${DEST} -C ${DIR} --strip-components=1
        fi

        chmod -R +rwx ${DIR}
        touch ${DIR}/jetbrains-toolbox.sh
        echo "#!/bin/bash" >> $DIR/jetbrains-toolbox.sh
        echo "$DIR/jetbrains-toolbox" >> $DIR/jetbrains-toolbox.sh

        ln -s ${DIR}/jetbrains-toolbox.sh /usr/local/bin/jetbrains-toolbox
        chmod -R +rwx /usr/local/bin/jetbrains-toolbox
        rm ${DEST}
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 60
    - unless: test -x /usr/local/bin/jetbrains-toolbox

enable_bash_it_rbenv:
  file.symlink:
    - name: /home/{{ defaults.user }}/.bash_it/enabled/250---rbenv.plugin.bash
    - target: /home/{{ defaults.user }}/.bash_it/plugins/available/rbenv.plugin.bash
    - user: {{ defaults.user }}
    - group: {{ defaults.group }}

enable_bash_it_aws:
  file.symlink:
    - name: /home/{{ defaults.user }}/.bash_it/enabled/250---aws.plugin.bash
    - target: /home/{{ defaults.user }}/.bash_it/plugins/available/aws.plugin.bash
    - user: {{ defaults.user }}
    - group: {{ defaults.group }}

enable_bash_it_docker:
  file.symlink:
    - name: /home/{{ defaults.user }}/.bash_it/enabled/250---docker.plugin.bash
    - target: /home/{{ defaults.user }}/.bash_it/plugins/available/docker.plugin.bash
    - user: {{ defaults.user }}
    - group: {{ defaults.group }}

enable_bash_it_ssh:
  file.symlink:
    - name: /home/{{ defaults.user }}/.bash_it/enabled/250---ssh.plugin.bash
    - target: /home/{{ defaults.user }}/.bash_it/plugins/available/ssh.plugin.bash
    - user: {{ defaults.user }}
    - group: {{ defaults.group }}

# enable_bash_it_pyenv:
#   cmd.run:
#     - name: bashit enable plugin pyenv
#     - runas: {{ defaults.user }}
#     - shell: /bin/bash
#     - timeout: 100
#     - unless: test -x /home/{{ defaults.user }}/.bash_it/enabled/*pyenv.plugin.bash
