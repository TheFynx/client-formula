# Requires -Version 3.0

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Script requires Admin Privileges.`nPlease re-run this script as an Administrator."
    Break
}

$introduction = @"
### This Script will:
1. Install Chocolatey
2. Install Salt Minion, Git, and Python
3. Run Client Formula to Setup System and DotFiles
"@

Clear-Host

Write-Host $introduction

Set-ExecutionPolicy Unrestricted

# Install Chocolatey
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Git
C:\ProgramData\chocolatey\bin\choco.exe install -y git python saltminion

# Create Directories
New-Item C:\salt\srv -ItemType Directory
New-Item C:\Users\levit\formulas -ItemType Directory

# Clone Repo
Set-Location -Path C:\Users\levit\formulas
git clone https://github.com/TheFynx/client-formula.git

# Link Directories
mklink /J C:\Users\levit\formulas\client-formula\client C:\salt/srv/salt

# Run salt
Set-Location -Path C:\salt\srv\salt
salt-call --statefile client.sls --local state.apply

# End message to indicate completion of setup
Write-Host "`n`nClient is now configured."
