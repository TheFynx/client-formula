{% if grains['os_family'] == 'Debian' %}
{% set user = salt['pillar.get']('client:user', 'levi') %}
{% set group = salt['pillar.get']('client:group', 'levi') %}
{% set home = salt['pillar.get']('client:home', '/home/levi') %}
{% elif grains['os_family'] == 'Windows' %}
{% set user = salt['pillar.get']('client:user', 'levit') %}
{% set group = salt['pillar.get']('client:group', 'levit') %}
{% set home = salt['pillar.get']('client:home', '/Users/levi') %}
{% endif %}

{% if grains['os_family'] == 'Windows' %}
# Commented out until fix has been merged
# {% for package in 'googlechrome', 'adobereader', 'git.install', '7zip.install', 'vlc', 'jdk8', 'virtualbox', 'rust', 'dropbox', 'visualstudiocode', 'awscli', 'golang', 'conemu', 'python', 'insomnia-rest-api-client', 'gpg4win', 'docker-for-windows', 'atom' %}
# {{ package }}:
  #  chocolatey.installed:
  #  - name: {{ package }}
# {% endfor %}
ChocolateyPackages:
  cmd.run:
    - name: choco install -y googlechrome adobereader git.install 7zip.install vlc jdk8 virtualbox rust dropbox awscli golang conemu python insomnia-rest-api-client gpg4win docker-for-windows atom
{% else %}

rust_ppa:
  pkgrepo.managed:
    - humanname: Rust PPA
    - name: deb http://ppa.launchpad.net/jonathonf/rustlang/ubuntu xenial main
    - dist: xenial
    - file: /etc/apt/sources.list.d/rust.list
    - keyid: F06FC659
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: rustc

  pkg.latest:
    - name: rustc
    - refresh: True

cinnamon_ppa:
  pkgrepo.managed:
    - ppa: embrosyn/cinnamon

  pkg.latest:
    - name: cinnamon
    - refresh: True

client_packages:
  pkg.installed:
    - pkgs: ['python-pip', 'htop', 'terminator', 'build-essential', 'chromium-browser', 'docker', 'vagrant', 'rustc', 'cargo', 'cinnamon']
vim_support:
  pkg.installed:
    - pkgs: ['liblua5.1-dev', 'luajit', 'libluajit-5.1', 'zlib1g-dev', 'python-dev', 'ruby-dev', 'libperl-dev', 'libncurses5-dev', 'libatk1.0-dev', 'libx11-dev', 'libxpm-dev', 'libxt-dev', 'cmake', 'libxt-dev']
clean_packages:
  pkg.removed:
    - pkgs: ['vim', 'vim-runtime', 'vim-gnome', 'vim-tiny', 'vim-gui-common']

install_pygments:
  pip.installed:
    - name: pygments

install_vim:
  cmd.run:
    - name: |
        rm -rf /tmp/vim &&\
        rm /usr/bin/vim &&\
        mkdir /usr/include/lua5.1/include &&\
        cp /usr/include/lua5.1/*.h /usr/include/lua5.1/include/ &&\
        cd /tmp &&\
        git clone https://github.com/vim/vim &&\
        git pull && git fetch &&\
        cd vim/src &&\
        make distclean &&\
        ./configure --with-features=huge \
            --enable-rubyinterp \
            --enable-largefile \
            --disable-netbeans \
            --enable-pythoninterp \
            --with-python-config-dir=/usr/lib/python2.7/config \
            --enable-perlinterp \
            --enable-luainterp \
            --with-luajit \
            --enable-fail-if-missing \
            --with-lua-prefix=/usr/include/lua5.1 \
            --enable-cscope &&\
        make &&\
        make install &&\
        touch {{ home }}/.local/.vim_built
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ home }}/.local/.vim_built

install_exa:
  cmd.run:
    - name: |
        cargo install --git https://github.com/ogham/exa
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ home }}/.cargo/bin/exa


install_fonts:
  cmd.run:
    - name: |
        git clone https://github.com/powerline/fonts.git --depth=1 &&\
        cd fonts &&\
        sh ./install.sh &&\
        cd .. &&\
        rm -rf fonts
    - cwd: /tmp
    - runas: {{ user }}
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ home }}/.local/share/fonts

install_bash_it:
  cmd.run:
    - name: |
        git clone --depth=1 https://github.com/Bash-it/bash-it.git {{ home }}/.bash_it &&\
        {{ home }}/.bash_it/install.sh -s
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ home }}/.bash_it/install.sh
{% endif %}
