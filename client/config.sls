{% from slspath + "/map.jinja" import defaults with context %}

/home/{{ defaults.user }}/custom/dconf.settings:
  file.managed:
    - template: jinja
    - source: salt://client/templates/dconf.jinja
    - user: {{ defaults.user }}
    - group: {{ defaults.group }}
    - mode: 755
    - makedirs: true

load_dconf:
  cmd.run:
    - name: dconf load / < /home/{{ defaults.user }}/custom/dconf.settings
    - onchanges:
      - file: /home/{{ defaults.user }}/custom/dconf.settings

Copy Cinnamon Config:
  file.recurse:
    - name: /home/{{ defaults.user }}/.cinnamon/configs/
    - source: salt://client/files/
    - mkdirs: true
