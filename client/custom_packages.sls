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
