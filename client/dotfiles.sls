{% from "map.jinja" import dot_files with context %}

{% if grains['os_family'] == 'Debian' %}
{% set user = salt['pillar.get']('client:user', 'levi') %}
{% set group = salt['pillar.get']('client:group', 'levi') %}
{% set home = salt['pillar.get']('client:home', '/home/levi') %}
{% elif grains['os_family'] == 'Windows' %}
{% set user = salt['pillar.get']('client:user', 'levit') %}
{% set group = salt['pillar.get']('client:group', 'levit') %}
{% set home = salt['pillar.get']('client:home', '/Users/levi') %}
{% endif %}

{% for dot in dot_files %}
{{ home }}/.{{ dot }}:
  file.managed:
    - source: salt://client/templates/{{ dot }}.jinja
    - user: {{ user }}
    - group: {{ group }}
    - mode: 775
    - makedirs: True
{% endfor %}

{% if grains['os_family'] == 'Windows' %}
{{ home }}/_vimrc:
  file.managed:
    - user: {{ user }}
    - group: {{ group }}
    - mode: 775
    - makedirs: True
    - source: salt://client/templates/vimrc.jinja
{% endif %}
