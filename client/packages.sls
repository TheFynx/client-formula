{% from "map.jinja" import packages with context %}
{% from "map.jinja" import vim_packages with context %}
{% set user = salt['pillar.get']('client:user', 'levi') %}
{% set group = salt['pillar.get']('client:group', 'levi') %}
{% set home = salt['pillar.get']('client:home', '/users/levi') %}

{% if grains['os'] == 'Windows' %}
{% for package in packages %}
{{ package }}_install:
  chocolatey.installed:
    - name: {{ package }}
{% endfor %}
{% else %}
client_packages:
  pkg.installed:
    - pkgs: {{ packages }}
    - pkgs: {{ vim_packages }}
{% endif %}

install_pygments:
  pip.installed:
    - name: pygments
    - require:
      - pkg: python-pip

{% if grains['os'] != 'Windows' %}
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
    - require:
      - pkgs: {{ vim_packages }}
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
        git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
        ~/.bash_it/install.sh -s
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x ~/.bash_it/install.sh
{% endif %}
