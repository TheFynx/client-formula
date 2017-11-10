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
if ((Get-Command "choco.exe" -ErrorAction SilentlyContinue) -eq $null) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install Git
C:\ProgramData\chocolatey\bin\choco.exe install -y git python saltminion

# Refresh shell
refreshenv

# Create Directories
New-Item C:\salt\srv\base -ItemType Directory -Force
New-Item C:\Users\levit\formulas -ItemType Directory -Force

# Clone Repo
if ( Test-Path C:\Users\levit\formulas\client-formula ) {
    Set-Location -Path C:\Users\levit\formulas\client-formula
    git pull
} else {
    Set-Location -Path C:\Users\levit\formulas
    git clone https://github.com/TheFynx/client-formula.git
}

# Link Directories
if (!(Test-Path C:\salt\srv\salt)) {
    New-Item -Path C:\salt\srv\salt\base\client -ItemType SymbolicLink -Value C:\Users\levit\formulas\client-formula\client
}

$salt_minion = @"
file_roots:
  base:
    - /srv/salt/base
file_client: local
"@
$salt_minion | Out-File -FilePath C:\salt\etc\salt\minion -Encoding ASCII

$salt_minion_id = @"
id: client
"@
$salt_minion_id | Out-File -FilePath C:\salt\etc\salt\minion_id -Encoding ASCII

$salt_top = @"
base:
  '*':
    - client
"@
$salt_top | Out-File -FilePath C:\salt\srv\salt\top.sls -Encoding ASCII

# Run salt
Set-Location -Path C:\salt\srv\salt
salt-call state.apply

# End message to indicate completion of setup
Write-Host "`n`nClient is now configured."
