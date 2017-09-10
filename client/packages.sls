{% from "client/map.jinja" import packages with context %}
{% set user = salt['pillar.get']('client:user', 'root') %}
{% set group = salt['pillar.get']('client:group', 'root') %}
{% set home = salt['pillar.get']('client:home', '/root') %}

client_packages:
  pkg.installed:
    - pkgs: {{ packages }}