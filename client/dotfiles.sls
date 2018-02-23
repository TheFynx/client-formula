{% from slspath + "/map.jinja" import defaults with context %}

{% if grains['os_family'] == 'Debian' %}
{% for dot in 'aliases', 'bash_profile', 'bashrc', 'exports', 'functions', 'gitconfig', 'gitignore', 'path', 'profile' %}
/home/{{ defaults.user }}/.{{ dot }}:
  file.managed:
    - template: jinja
    - source: salt://client/templates/{{ dot }}.jinja
    - user: {{ defaults.user }}
    - group: {{ defaults.group }}
    - mode: 775
    - defaults:
        home: /home/{{ defaults.user }}
        os: {{ grains['os_family'] }}
        gpgkey: false
    - makedirs: True
{% endfor %}

/home/{{ defaults.user }}/.config/terminator/config:
  file.managed:
    - template: jinja
    - source: salt://client/templates/terminator.jinja
    - user: {{ defaults.user }}
    - group: {{ defaults.group }}
    - mode: 775
    - defaults:
        home: /home/{{ defaults.user }}
        os: {{ grains['os_family'] }}
    - makedirs: True

/home/{{ defaults.user }}/.config/nvim/init.vim:
  file.managed:
    - target: /home/{{ defaults.user }}/.config/nvim/init.vim
    - makedirs: True
    - contents:
      - source $HOME/.config/nvim/modules/init.vim
      - source $HOME/.config/nvim/modules/general.vim
      - source $HOME/.config/nvim/modules/plugins.vim
      - source $HOME/.config/nvim/modules/bindings.vim

/home/{{ defaults.user }}/.config/nvim/modules/init.vim:
  file.managed:
    - source: salt://client/templates/neo/init.vim.jinja
    - target: /home/{{ defaults.user }}/.config/nvim/modules/init.vim
    - makedirs: True

/home/{{ defaults.user }}/.config/nvim/modules/general.vim:
  file.managed:
    - source: salt://client/templates/neo/general.vim.jinja
    - target: /home/{{ defaults.user }}/.config/nvim/modules/general.vim
    - makedirs: True

/home/{{ defaults.user }}/.config/nvim/modules/plugins.vim:
  file.managed:
    - source: salt://client/templates/neo/plugins.vim.jinja
    - target: /home/{{ defaults.user }}/.config/nvim/modules/plugins.vim
    - makedirs: True

/home/{{ defaults.user }}/.config/nvim/modules/bindings.vim:
  file.managed:
    - source: salt://client/templates/neo/bindings.vim.jinja
    - target: /home/{{ defaults.user }}/.config/nvim/modules/bindings.vim
    - makedirs: True

{% elif grains['os_family'] == 'Windows' %}
{% for dot in 'aliases', 'bash_profile', 'bashrc', 'exports', 'functions', 'gitconfig', 'gitignore', 'path', 'profile' %}
C:\Users\{{ defaults.user }}/.{{ dot }}:
  file.managed:
    - template: jinja
    - source: salt://client/templates/{{ dot }}.jinja
    - user: {{ defaults.user }}
    - group: {{ defaults.group }}
    - defaults:
        home: C:\Users\{{ defaults.user }}
        os: {{ grains['os_family'] }}
    - makedirs: True
{% endfor %}

C:\Users\{{ defaults.user }}\AppData\Local\nvim\init.vim:
  file.managed:
    - source: salt://client/templates/neo/init.vim.jinja
    - target: C:\Users\{{ defaults.user }}\AppData\Local\nvim\init.vim
    - makedirs: True

C:\Users\{{ defaults.user }}/AppData/Roaming/ConEmu.xml:
  file.managed:
    - source: salt://client/templates/conemu.xml.jinja
    - target: C:\Users\{{ defaults.user }}/AppData/Roaming/ConEmu.xml
    - makedirs: True
{% endif %}
