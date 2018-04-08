{% from slspath + "/map.jinja" import defaults with context %}

install_pygments:
  pip.installed:
    - name: pygments

install_jinja2:
  pip.installed:
    - name: Jinja2
