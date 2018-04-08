{% from slspath + "/map.jinja" import defaults with context %}

docker_repo:
  pkgrepo.managed:
    - humanname: 'Docker CE'
    - name: 'deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable'
    - file: '/etc/apt/sources.list.d/docker.list'
    - key_url: 'https://download.docker.com/linux/ubuntu/gpg'

insomnia_repo:
  pkgrepo.managed:
    - humanname: 'Insomnia Repo Client'
    - name: 'deb https://dl.bintray.com/getinsomnia/Insomnia /'
    - file: '/etc/apt/sources.list.d/insomnia.list'
    - key_url: 'https://insomnia.rest/keys/debian-public.key.asc'

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
             'cargo', 'vlc', 'chromium-browser', 'dconf-cli', 'clipit', 'xclip',
             'python-dev', 'python3-dev', 'python3-pip', 'libncurses5-dev',
             'rbenv', 'libtolua-dev', 'exuberant-ctags', 'pandoc', 'lynx',
             'insomnia']
