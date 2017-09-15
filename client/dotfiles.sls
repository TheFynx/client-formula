{% from "map.jinja" import dot_files with context %}
{% set user = salt['pillar.get']('client:user', 'levi') %}
{% set group = salt['pillar.get']('client:group', 'levi') %}
{% set home = salt['pillar.get']('client:home', '/users/levi') %}

{% for dot in dot_files %}
dotfile_{{ dot }}:
  file:
    - managed
    - name: {{ home }}/_{{ dot }}
    - template: jinja
    - user: {{ user }}
    - group: {{ group }}
    - mode: 775
    - makedirs: True
    - source: salt://client/templates/{{ dot }}.jinja
{% endfor %}

{% if grains['os'] == 'Windows' %}
vimrc:
  file:
    - managed
    - name: {{ home }}/_vimrc
    - template: jinja
    - user: {{ user }}
    - group: {{ group }}
    - mode: 775
    - makedirs: True
    - source: salt://client/templates/vimrc.jinja
{% endif %}
