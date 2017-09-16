{% from "map.jinja" import dot_files with context %}

{% if grains['os_family'] == 'Debian' %}
{% set user = salt['pillar.get']('client:user', 'levi') %}
{% set group = salt['pillar.get']('client:group', 'levi') %}
{% set home = salt['pillar.get']('client:home', '/home/levi') %}
{% elif grains['os_family'] == 'Windows' %}
{% set user = salt['pillar.get']('client:user', 'levit') %}
{% set group = salt['pillar.get']('client:group', 'levit') %}
{% set home = salt['pillar.get']('client:home', '/Users/levit') %}
{% endif %}

{% if grains['os_family'] == 'Debian' %}
{% for dot in dot_files %}
{{ home }}/.{{ dot }}:
  file.managed:
    - template: jinja
    - source: salt://templates/{{ dot }}.jinja
    - user: {{ user }}
    - group: {{ group }}
    - mode: 775
    - defaults:
        home: {{ home }}
        os: {{ grains['os_family'] }}
    - makedirs: True
{% endfor %}
{% elif grains['os_family'] == 'Windows' %}
{% for dot in dot_files %}
{{ home }}/.{{ dot }}:
  file.managed:
    - template: jinja
    - source: salt://templates/{{ dot }}.jinja
    - user: {{ user }}
    - group: {{ group }}
    - defaults:
        home: {{ home }}
        os: {{ grains['os_family'] }}
    - makedirs: True
{% endfor %}
{{ home }}/_vimrc:
  file.managed:
    - template: jinja
    - user: {{ user }}
    - group: {{ group }}
    - makedirs: True
    - source: salt://templates/vimrc.jinja
{% endif %}
