{% from slspath + "/map.jinja" import defaults with context %}

atom_ppa:
  pkgrepo.managed:
    - ppa: webupd8team/atom

  pkg.latest:
    - name: atom
    - refresh: True

install_atom_plugins:
  cmd.run:
    - name: apm stars --install --user {{ defaults.atom_user }}
    - cwd: /tmp
    - shell: /bin/bash
    - runas: {{ defaults.user }}
    - timeout: 600
