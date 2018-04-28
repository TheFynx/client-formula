{% from slspath + "/map.jinja" import defaults with context %}

install_ruby_build:
  cmd.run:
    - name: |
        mkdir -p "$(rbenv root)"/plugins
        git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
    - shell: /bin/bash
    - runas: {{ defaults.user }}
    - timeout: 100
    - unless: test -x "$(rbenv root)"/plugins

update_ruby_build:
  cmd.run:
    - name: cd "$(rbenv root)"/plugins/ruby-build && git pull
    - shell: /bin/bash
    - runas: {{ defaults.user }}
    - timeout: 100
    - onlyif: test -x "$(rbenv root)"/plugins

{% for version in defaults.ruby_versions %}
install_ruby_version {{ version }}:
  cmd.run:
    - name: rbenv install -s {{ version }}
    - shell: /bin/bash
    - runas: {{ defaults.user }}
    - timeout: 600
    - unless: $(rbenv versions | grep {{ version }})
{% endfor %}

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
