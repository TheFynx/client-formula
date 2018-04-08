include:
{% if grains['os_family'] == 'Debian' %}
{% if grains['quick'] %}
  - client.packages
  - client.pip_packages
  - client.gem_packages
  - client.custom_packages
  - client.dotfiles
  - client.config
{% else %}
  - client.packages
  - client.pip_packages
  - client.gem_packages
  - client.custom_packages
  - client.atom
  - client.dotfiles
  - client.config
{% endif %}
{% elif grains['os_family'] == 'Windows' %}
  - client.chocolately_packages
  - client.pip_packages
  - client.dotfiles
  - client.config
{% endif %}
