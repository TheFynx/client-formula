Client Formula

Salt Formula to setup my Client/Workstation and DotFiles

# Install

## Powershell

- `iwr https://raw.githubusercontent.com/TheFynx/client-forumla/master/install.ps1 -UseBasicParsing | iex`

### Options

- For Custom Username `install.ps1 username`

## Bash/Shell

Options to download and run in the same command

- `curl https://raw.githubusercontent.com/TheFynx/client-forumla/master/install.sh | bash`
- `wget -O - bootstrap-salt.sh https://raw.githubusercontent.com/TheFynx/client-forumla/master/install.sh | bash`
- `python -c 'import urllib; print urllib.urlopen(" https://raw.githubusercontent.com/TheFynx/client-forumla/master/install.sh").read()' | bash`

Just download and run locally

- `curl https://raw.githubusercontent.com/TheFynx/client-forumla/master/install.sh -o /tmp/install.sh`
- `wget -O - bootstrap-salt.sh https://raw.githubusercontent.com/TheFynx/client-forumla/master/install.sh`

### Options

- For custom user or group `install.sh -u username -g groupname`
- Use the `-?` flag to get the latest Options

  ```bash
  >>> Usage:
  -u | Pass Customer User - install.sh -u USER
  -g | Pass Customer Group - install.sh -g GROUP
  -p | Pass Packer Version to Install - install.sh -p 1.2.2
  -t | Pass Terraform Version to Install - install.sh -t 0.11.6
  -r | Pass Ruby Version to Set for RBENV - install.sh -r 2.5.0
  -a | Pass Atom User to installed starred items from - install.sh -a USERNAME
  -q | Set quick run mode, does not include longer running states - install.sh -q y
  -? | List this help menu
  ```
