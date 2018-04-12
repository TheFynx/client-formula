{% from slspath + "/map.jinja" import defaults with context %}

install_pyenv:
  cmd.run:
    - name: git clone https://github.com/pyenv/pyenv.git /home/{{ defaults.user }}/.pyenv
    - shell: /bin/bash
    - runas: {{ defaults.user }}
    - timeout: 100
    - unless: test -x /home/{{ defaults.user }}/.pyenv

update_pyenv:
  cmd.run:
    - name: git pull
    - shell: /bin/bash
    - cwd: /home/{{ defaults.user }}/.pyenv
    - runas: {{ defaults.user }}
    - timeout: 100
    - onlyif: test -x /home/{{ defaults.user }}/.pyenv

{% for version in defaults.python_versions %}
install_python_version {{ version }}:
  cmd.run:
    - name: pyenv install -s {{ version }}
    - shell: /bin/bash
    - runas: {{ defaults.user }}
    - timeout: 600
    - unless: $(pyenv versions | grep {{ version }})
{% endfor %}

set_python_version:
  cmd.run:
    - name: pyenv global {{ defaults.python_version }}
    - cwd: /tmp
    - shell: /bin/bash
    - runas: {{ defaults.user }}
    - timeout: 300
    - unless: python --version | grep '{{ defaults.python_version }}'

install_pygments:
  pip.installed:
    - name: pygments

install_jinja2:
  pip.installed:
    - name: Jinja2
