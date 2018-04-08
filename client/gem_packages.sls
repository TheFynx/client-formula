{% from slspath + "/map.jinja" import defaults with context %}

set_ruby_version:
  cmd.run:
    - name: rbenv global {{ defaults.ruby_version }}
    - cwd: /tmp
    - shell: /bin/bash
    - runas: {{ defaults.user }}
    - timeout: 300
    - unless: ruby --version | grep '{{ defaults.ruby_version }}'

travis:
  gem.installed:
    - user: {{ defaults.user }}

bundle:
  gem.installed:
    - user: {{ defaults.user }}

rsense:
  gem.installed:
    - user: {{ defaults.user }}
