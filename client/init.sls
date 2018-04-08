include:
{% if grains['os_family'] == 'Debian' %}
  - client.packages
  - client.custom_packages
  - client.pip_packages
  - client.gem_packages
  - client.dotfiles
  - client.config
{% elif grains['os_family'] == 'Windows' %}
  - client.chocolately_packages
  - client.pip_packages
  - client.dotfiles
  - client.config
{% endif %}
