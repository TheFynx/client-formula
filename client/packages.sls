{% from slspath + "/map.jinja" import defaults with context %}

{% if grains['os_family'] == 'Windows' %}
{% for package in
    'googlechrome', 'adobereader', 'git.install', '7zip.install', 'vlc', 'jdk8',
    'dropbox', 'awscli', 'golang', 'conemu', 'python', 'python3', 'wox', 'ditto',
    'insomnia-rest-api-client', 'gpg4win', 'docker-for-windows', 'ruby', neovim,
    'everything', 'atom', 'firefox', 'gotomeeting', 'greenshot', 'keepass',
    'simplenote', 'openvpn', 'packer', 'terraform', 'slack', 'vagrant'
%}

{{ package }}:
   chocolatey.installed:
     - name: {{ package }}
{% endfor %}

{% else %}

docker_repo:
  pkgrepo.managed:
    - humanname: 'Docker CE'
    - name: 'deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable'
    - file: '/etc/apt/sources.list.d/docker.list'
    - key_url: 'https://download.docker.com/linux/ubuntu/gpg'
    - require_in:
      - pkg: docker

rust_ppa:
  pkgrepo.managed:
    - ppa: jonathonf/rustlang

  pkg.latest:
    - name: rustc
    - refresh: True

golang_ppa:
  pkgrepo.managed:
    - ppa: longsleep/golang-backports

  pkg.latest:
    - name: golang-go
    - refresh: True

neovim_ppa:
  pkgrepo.managed:
    - ppa: neovim-ppa/stable

  pkg.latest:
    - name: neovim
    - refresh: True

atom_ppa:
  pkgrepo.managed:
    - ppa: webupd8team/atom

  pkg.latest:
    - name: atom
    - refresh: True

{% for pkg in
  'vim', 'vim-runtime', 'vim-gnome', 'vim-tiny', 'vim-gui-common', 'firefox',
  'thunderbird', 'tomboy', 'docker', 'docker-engine', 'docker.io', 'hexchat',
  'pidgin', 'redshift', 'timeshift', 'rhythmbox', 'transmission-gtk'
%}
{{ pkg }}:
  pkg.removed
{% endfor %}


client_packages:
  pkg.installed:
    - pkgs: ['python-pip', 'htop', 'terminator', 'build-essential', 'docker-ce',
             'cargo', 'vlc', 'chromium-browser', 'dconf-cli', 'clipit',
             'python-dev', 'python3-dev', 'python3-pip', 'ncurses-dev',
             'libtolua-dev', 'exuberant-ctags', 'pandoc', 'lynx']

install_pygments:
  pip.installed:
    - name: pygments

install_jinja2:
  pip.installed:
    - name: Jinja2

install_exa:
  cmd.run:
    - name: cargo install --git https://github.com/ogham/exa
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x /home/{{ defaults.user }}/.cargo/bin/exa

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
{% endif %}
