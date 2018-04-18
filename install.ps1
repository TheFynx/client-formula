# Requires -Version 3.0

$user=$args[0]

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
New-Item C:\salt\srv\salt\base -ItemType Directory -Force
New-Item C:\Users\$user\formulas -ItemType Directory -Force

# Clone Repo
Write-Host "Getting Client Salt Formula"
if ( Test-Path C:\Users\$user\formulas\client-formula ) {
    Set-Location -Path C:\Users\$user\formulas\client-formula
    git pull
} else {
    Set-Location -Path C:\Users\$user\formulas
    git clone https://github.com/TheFynx/client-formula.git
}

# Link Directories
if (!(Test-Path C:\salt\srv\salt\base\client)) {
  Write-Host "Linking Directories"
    New-Item -Path C:\salt\srv\salt\base\client -ItemType SymbolicLink -Value C:\Users\$user\formulas\client-formula\client
}

# Set ACLs
$UserACL  = Get-Acl -Path "C:\Users\$user\Desktop"
Set-Acl -Path "C:\salt\" -AclObject $UserACL
Get-ChildItem -Path "C:\salt\" -Recurse -Force | Set-Acl -AclObject $UserACL

$salt_minion = @"
file_roots:
  base:
    - C:\salt\srv\salt\base
file_client: local
"@

if (Test-Path C:\salt\conf) {
  Write-Host "Setting minion config"
  $salt_minion | Out-File -FilePath C:\salt\conf\minion -Encoding ASCII
}

$salt_minion_id = @"
id: client
"@

if (Test-Path C:\salt\conf\minion_id) {
  Write-Host "Setting minion id"
  $salt_minion_id | Out-File -FilePath C:\salt\conf\minion_id -Encoding ASCII
}

$salt_top = @"
base:
  '*':
    - client
"@

if (Test-Path C:\salt\srv\salt) {
  Write-Host "Creating Top File"
  $salt_top | Out-File -FilePath C:\salt\srv\salt\base\top.sls -Encoding ASCII
}

$defaults = @"
user: "$user"
group: "$user"
"@

if (Test-Path C:\salt\srv\salt\base\client) {
  Write-Host "Creating Defaults file"
  $defaults | Out-File -FilePath C:\salt\srv\salt\base\client\defaults.yaml -Encoding ASCII
}

# Run salt
salt-call state.apply

# End message to indicate completion of setup
Write-Host "`n`nClient is now configured."
