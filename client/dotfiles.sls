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

/home/{{ defaults.user }}/.vimrc:
  file.managed:
    - source: salt://client/templates/vimrc
    - target: /home/{{ defaults.user }}/.vimrc
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

C:\Users\{{ defaults.user }}/.vimrc:
  file.managed:
    - source: salt://client/templates/vimrc
    - target: C:\Users\{{ defaults.user }}/.vimrc
    - makedirs: True

C:\Users\{{ defaults.user }}/AppData/Roaming/ConEmu.xml:
  file.managed:
    - source: salt://client/templates/conemu.xml.jinja
    - target: C:\Users\{{ defaults.user }}/AppData/Roaming/ConEmu.xml
    - makedirs: True
{% endif %}
