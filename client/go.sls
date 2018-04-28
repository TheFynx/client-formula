{% from slspath + "/map.jinja" import defaults with context %}

install_goenv:
  cmd.run:
    - name: git clone https://github.com/syndbg/goenv.git /home/{{ defaults.user }}/.goenv
    - shell: /bin/bash
    - runas: {{ defaults.user }}
    - timeout: 100
    - unless: test -x /home/{{ defaults.user }}/.goenv

update_goenv:
  cmd.run:
    - name: git pull
    - shell: /bin/bash
    - cwd: /home/{{ defaults.user }}/.goenv
    - runas: {{ defaults.user }}
    - timeout: 100
    - onlyif: test -x /home/{{ defaults.user }}/.goenv

include:
  - client.dotfiles

{% for version in defaults.golang_versions %}
install_golang_version {{ version }}:
  cmd.run:
    - name: goenv install -s {{ version }}
    - shell: /bin/bash
    - runas: {{ defaults.user }}
    - timeout: 600
    - unless: $(goenv versions | grep {{ version }})
{% endfor %}

set_golang_version:
  cmd.run:
    - name: goenv global {{ defaults.golang_version }}
    - cwd: /tmp
    - shell: /bin/bash
    - runas: {{ defaults.user }}
    - timeout: 300
    - unless: go version | grep '{{ defaults.golang_version }}'
