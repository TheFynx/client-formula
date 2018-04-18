include:
{% if grains['os_family'] == 'Debian' %}
{% if not grains['quick'] %}
  - client.packages
  - client.pip_packages
  - client.gem_packages
  - client.custom_packages
  - client.atom
{% endif %}
  - client.dotfiles
  - client.config
{% elif grains['os_family'] == 'Windows' %}
  - client.chocolately_packages
  - client.dotfiles
{% endif %}
