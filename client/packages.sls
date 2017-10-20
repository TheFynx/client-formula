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
{% for package in
    'googlechrome', 'adobereader', 'git.install', '7zip.install', 'vlc', 'jdk8',
    'virtualbox', 'rust', 'dropbox', 'visualstudiocode', 'awscli', 'golang',
    'conemu', 'python', 'insomnia-rest-api-client', 'gpg4win',
    'docker-toolbox', 'atom', 'everything', 'atom'
%}
{{ package }}:
   chocolatey.installed:
   - name: {{ package }}
{% endfor %}
# ChocolateyPackages:
#   cmd.run:
#     - name: choco install -y googlechrome git.install 7zip.install vlc jdk8 virtualbox dropbox awscli conemu python insomnia-rest-api-client gpg4win docker-toolbox atom everything wox
{% else %}

rust_ppa:
  pkgrepo.managed:
    - ppa: jonathonf/rustlang

  pkg.latest:
    - name: rustc
    - refresh: True

cinnamon_ppa:
  pkgrepo.managed:
    - ppa: embrosyn/cinnamon

  pkg.latest:
    - name: cinnamon
    - refresh: True

albert_ppa:
  pkgrepo.managed:
    - ppa: nilarimogard/webupd8

  pkg.latest:
    - name: albert
    - refresh: True

golang_ppa:
  pkgrepo.managed:
    - ppa: hnakamur/golang-1.9

  pkg.latest:
    - name: golang
    - refresh: True

atom_ppa:
  pkgrepo.managed:
    - ppa: webupd8team/atom

  pkg.latest:
    - name: atom
    - refresh: True

client_packages:
  pkg.installed:
    - pkgs: ['python-pip', 'htop', 'terminator', 'build-essential', 'chromium-browser', 'docker', 'vagrant', 'cargo']

vim_support:
  pkg.installed:
    - pkgs: ['liblua5.2-dev', 'luajit', 'libluajit-5.1-2', 'zlib1g-dev', 'python-dev', 'ruby-dev',
             'libperl-dev', 'libncurses5-dev', 'libatk1.0-dev', 'libx11-dev', 'libxpm-dev', 'libxt-dev',
             'cmake', 'libxt-dev', 'libbonoboui2-dev', 'python3-dev', 'libperl-dev', 'lua5.2', 'build-essential']

{% for pkg in 'vim', 'vim-runtime', 'vim-gnome', 'vim-tiny', 'vim-gui-common' %}
{{ pkg }}:
  pkg.removed
{% endfor %}

install_pygments:
  pip.installed:
    - name: pygments

install_vim:
  cmd.run:
    - name: |
        if [ -d "/tmp/vim" ]; then rm -rf /tmp/vim; fi &&\
        if [ -d "/usr/bin/vim" ]; then rm /usr/bin/vim; fi &&\
        if [ ! -d "/usr/include/lua" ]; then ln -s /usr/include/lua5.2 /usr/include/lua && ln -s /usr/lib/x86_64-linux-gnu/liblua5.2.so /usr/local/lib/liblua.so; fi &&\
        cd /tmp &&\
        git clone https://github.com/vim/vim &&\
        cd vim &&\
        ./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp \
            --enable-pythoninterp \
            --with-python-config-dir=$(python-config --configdir) \
            --enable-python3interp \
            --with-python3-config-dir=$(python3-config --configdir) \
            --enable-perlinterp \
            --enable-luainterp \
            --with-lua-prefix=/usr/include/lua5.2 \
            --enable-gui=no \
            --enable-cscope \
            --prefix=/usr \
        make VIMRUNTIMEDIR=/usr/share/vim/vim80 &&\
        make install &&\
        touch {{ home }}/.local/.vim_built
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 300
    - unless: test -f {{ home }}/.local/.vim_built

install_exa:
  cmd.run:
    - name: cargo install --git https://github.com/ogham/exa
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
