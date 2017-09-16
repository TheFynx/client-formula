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
# {% for package in 'googlechrome', 'adobereader', 'git.install', '7zip.install', 'vlc', 'jdk8', 'virtualbox', 'rust', 'dropbox', 'visualstudiocode', 'awscli', 'golang', 'conemu', 'python', 'insomnia-rest-api-client' %}
# {{ package }}:
#   chocolatey.installed:
#     - name: {{ package }}
# {% endfor %}
ChocolateyPackages:
  cmd.run:
    - name: choco install -y googlechrome adobereader git.install 7zip.install vlc jdk8 virtualbox rust dropbox visualstudiocode awscli golang conemu python insomnia-rest-api-client
{% else %}
client_packages:
  pkg.installed:
    - pkgs: ['python-pip', 'htop', 'terminator', 'build-essential', 'chromium-browser', 'docker', 'vagrant', 'rustc', 'cargo']
exa_support:
  pkg.installed:
    - pkgs: ['cmake', 'zlib1g-dev']
vim_support:
  pkg.installed:
    - pkgs: ['liblua5.1-dev', 'luajit', 'libluajit-5.1-2', 'python-dev', 'ruby-dev', 'libperl-dev', 'libncurses5-dev', 'libatk1.0-dev', 'libx11-dev', 'libxpm-dev', 'libxt-dev']

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

install_pygments:
  pip.installed:
    - name: pygments

install_vim:
  cmd.run:
    - name: |
        cd /tmp
        git clone https://github.com/vim/vim.git
        cd vim/src
        make distclean
        ./configure \
          --enable-multibyte \
          --enable-perlinterp=dynamic \
          --enable-rubyinterp=dynamic \
          --with-ruby-command=/usr/local/bin/ruby \
          --enable-pythoninterp=dynamic \
          --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
          --enable-python3interp \
          --with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu \
          --enable-luainterp \
          --with-luajit \
          --enable-cscope \
          --enable-gui=auto \
          --with-features=huge \
          --with-x \
          --enable-fontset \
          --enable-largefile \
          --disable-netbeans \
          --enable-fail-if-missing
        make
        make install
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 300
    - unless: vim --version | grep '+python'

install_exa:
  cmd.run:
    - name: |
        cargo install --git https://github.com/ogham/exa
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x /usr/local/bin/exa

install_bash_it:
  cmd.run:
    - name: |
        git clone --depth=1 https://github.com/Bash-it/bash-it.git {{ home }}/.bash_it
        {{ home }}/.bash_it/install.sh -s
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ home }}/.bash_it/install.sh
{% endif %}
