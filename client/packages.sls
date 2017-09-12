{% from "client/map.jinja" import packages with context %}
{% set user = salt['pillar.get']('client:user', 'levi') %}
{% set group = salt['pillar.get']('client:group', 'levi') %}
{% set home = salt['pillar.get']('client:home', '/users/levi') %}

client_packages:
  pkg.installed:
    - pkgs: {{ packages }}