{% from slspath + "/map.jinja" import defaults with context %}

{% for package in
    'googlechrome', 'adobereader', 'git.install', '7zip.install', 'vlc', 'jdk8',
    'dropbox', 'awscli', 'golang', 'conemu', 'python', 'python3', 'ditto',
    'insomnia-rest-api-client', 'gpg4win', 'docker-for-windows', 'ruby',
    'neovim', 'atom', 'firefox', 'greenshot', 'simplenote', 'packer', 'zoom',
    'terraform', 'slack', 'vagrant', 'chefdk'
%}

{{ package }}:
   chocolatey.installed:
     - name: {{ package }}
{% endfor %}
