{% from slspath + "/map.jinja" import defaults with context %}

install_exa:
  cmd.run:
    - name: cargo install --git https://github.com/ogham/exa
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x /home/{{ defaults.user }}/.cargo/bin/exa

install_packer:
  cmd.run:
    - name: |
        curl https://releases.hashicorp.com/packer/{{ defaults.packer_version }}/packer_{{ defaults.packer_version }}_linux_amd64.zip -o packer.zip &&\
        unzip packer.zip -d /usr/local/bin/
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 300
    - check_cmd:
      - if [ "$(packer --version)" == '{{ defaults.packer_version }}' ]; then return 0; fi

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
    - timeout: 300
    - unless: test -x /home/{{ defaults.user }}/.local/share/fonts

install_bash_it:
  cmd.run:
    - name: |
        git clone --depth=1 https://github.com/Bash-it/bash-it.git /home/{{ defaults.user }}/.bash_it &&\
        /home/{{ defaults.user }}/.bash_it/install.sh -s
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x /home/{{ defaults.user }}/.bash_it/install.sh
