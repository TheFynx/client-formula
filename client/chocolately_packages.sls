{% from slspath + "/map.jinja" import defaults with context %}

{% for package in
    'googlechrome', 'adobereader', 'git.install', '7zip.install', 'vlc', 'jdk8',
    'dropbox', 'awscli', 'golang', 'conemu', 'python', 'python3', 'wox', 'ditto',
    'insomnia-rest-api-client', 'gpg4win', 'docker-for-windows', 'ruby', neovim,
    'everything', 'atom', 'firefox', 'gotomeeting', 'greenshot', 'keepass',
    'simplenote', 'openvpn', 'packer', 'terraform', 'slack', 'vagrant'
%}

{{ package }}:
   chocolatey.installed:
     - name: {{ package }}
{% endfor %}
