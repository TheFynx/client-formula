{% from slspath + "/map.jinja" import defaults with context %}

{% if grains['os_family'] == 'Debian' %}
{% for dot in 'aliases', 'bash_profile', 'bashrc', 'exports', 'functions', 'gitconfig', 'gitignore', 'path', 'profile' %}
{{ home }}/.{{ dot }}:
  file.managed:
    - template: jinja
    - source: salt://client/templates/{{ dot }}.jinja
    - user: {{ user }}
    - group: {{ group }}
    - mode: 775
    - defaults:
        home: {{ home }}
        os: {{ grains['os_family'] }}
        gpgkey: false
    - makedirs: True

{% endfor %}

{{ home }}/.config/terminator/config:
  file.managed:
    - template: jinja
    - source: salt://client/templates/terminator.jinja
    - user: {{ user }}
    - group: {{ group }}
    - mode: 775
    - defaults:
        home: {{ home }}
        os: {{ grains['os_family'] }}
    - makedirs: True

{{ home }}/.vimrc:
  file.managed:
    - source: salt://client/templates/vimrc
    - target: {{ home }}/.vimrc
    - makedirs: True

{% elif grains['os_family'] == 'Windows' %}
{% for dot in 'aliases', 'bash_profile', 'bashrc', 'exports', 'functions', 'gitconfig', 'gitignore', 'path', 'profile' %}
{{ home }}/.{{ dot }}:
  file.managed:
    - template: jinja
    - source: salt://client/templates/{{ dot }}.jinja
    - user: {{ user }}
    - group: {{ group }}
    - defaults:
        home: {{ home }}
        os: {{ grains['os_family'] }}
    - makedirs: True
{% endfor %}

{{ home }}/.vimrc:
  file.managed:
    - source: salt://client/templates/vimrc
    - target: {{ home }}/.vimrc
    - makedirs: True

{{ home }}/AppData/Roaming/ConEmu.xml:
  file.managed:
    - source: salt://client/templates/conemu.xml.jinja
    - target: {{ home }}/AppData/Roaming/ConEmu.xml
    - makedirs: True
{% endif %}
