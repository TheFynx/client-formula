{% from slspath + "/map.jinja" import defaults with context %}

{% if grains['os_family'] == 'Debian' %}
{% for dot in 'aliases', 'bash_profile', 'bashrc', 'exports', 'functions', 'gitconfig', 'gitignore', 'path', 'profile' %}
/home/{{ user }}/.{{ dot }}:
  file.managed:
    - template: jinja
    - source: salt://client/templates/{{ dot }}.jinja
    - user: {{ user }}
    - group: {{ group }}
    - mode: 775
    - defaults:
        home: /home/{{ user }}
        os: {{ grains['os_family'] }}
        gpgkey: false
    - makedirs: True

{% endfor %}

/home/{{ user }}/.config/terminator/config:
  file.managed:
    - template: jinja
    - source: salt://client/templates/terminator.jinja
    - user: {{ user }}
    - group: {{ group }}
    - mode: 775
    - defaults:
        home: /home/{{ user }}
        os: {{ grains['os_family'] }}
    - makedirs: True

/home/{{ user }}/.vimrc:
  file.managed:
    - source: salt://client/templates/vimrc
    - target: /home/{{ user }}/.vimrc
    - makedirs: True

{% elif grains['os_family'] == 'Windows' %}
{% for dot in 'aliases', 'bash_profile', 'bashrc', 'exports', 'functions', 'gitconfig', 'gitignore', 'path', 'profile' %}
C:\Users\{{ user }}/.{{ dot }}:
  file.managed:
    - template: jinja
    - source: salt://client/templates/{{ dot }}.jinja
    - user: {{ user }}
    - group: {{ group }}
    - defaults:
        home: C:\Users\{{ user }}
        os: {{ grains['os_family'] }}
    - makedirs: True
{% endfor %}

C:\Users\{{ user }}/.vimrc:
  file.managed:
    - source: salt://client/templates/vimrc
    - target: C:\Users\{{ user }}/.vimrc
    - makedirs: True

C:\Users\{{ user }}/AppData/Roaming/ConEmu.xml:
  file.managed:
    - source: salt://client/templates/conemu.xml.jinja
    - target: C:\Users\{{ user }}/AppData/Roaming/ConEmu.xml
    - makedirs: True
{% endif %}
