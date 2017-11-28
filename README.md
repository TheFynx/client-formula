# Client Formula

Salt Formula to setup my Client/Workstation and DotFiles

## Install

### Powershell
* `iwr https://raw.githubusercontent.com/TheFynx/client-forumla/master/install.ps1 -UseBasicParsing | iex`

#### Options
* for customer username
`install.ps1 username`

### Bash/Shell
* `curl https://raw.githubusercontent.com/TheFynx/client-forumla/master/install.sh | bash`
* `wget -O - bootstrap-salt.sh https://raw.githubusercontent.com/TheFynx/client-forumla/master/install.sh | bash`
* `python -c 'import urllib; print urllib.urlopen(" https://raw.githubusercontent.com/TheFynx/client-forumla/master/install.sh").read()' | bash`

#### Options
* For custom user or group
`install.sh -u username -g groupname`
