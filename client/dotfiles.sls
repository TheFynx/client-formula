{% from "client/map.jinja" import files with context %}

{% for file in files %}
dotfile_{{file}}:
  file:
    - managed
    - name: {{home}}/_{{file}}
    - template: jinja
    - user: {{user}}
    - group: {{group}}
    - mode: 775
    - source: salt://client/templates/{{file}}.jinja
{% endfor %}

{% if grains['os'] == 'Windows' %}
vimrc:
  file:
    - managed
    - name: {{home}}/_vimrc
    - template: jinja
    - user: {{user}}
    - group: {{group}}
    - mode: 775
    - source: salt://client/templates/vimrc.jinja
{% endif %}

