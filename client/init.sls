include:
{% if grains['os_family'] == 'Debian' %}
  - client.dotfiles
  - client.config
{% if not grains['quick'] %}
  - client.packages
  - client.pip_packages
  - client.gem_packages
  - client.custom_packages
  - client.atom
{% endif %}
{% elif grains['os_family'] == 'Windows' %}
  - client.chocolately_packages
  - client.pip_packages
  - client.dotfiles
  - client.config
{% endif %}
