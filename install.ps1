# Requires -Version 3.0

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Script requires Admin Privileges.`nPlease re-run this script as an Administrator."
    Break
}

function die {
    param ($msg="Client Setup encountered an error. Exiting")
    Write-host "$msg."
    Break
}

$tempInstallDir = Join-Path -path $env:TEMP -childpath 'client-formula'

$introduction = @"
### This Script will:
1. Install Chocolatey
2. Install Salt Minion, Git, and Python
3. Run Client Formula to Setup System and DotFiles
"@

Clear-Host

Write-Host $introduction

# Create the temporary installation directory
if (!(Test-Path $tempInstallDir -pathType container)) {
    New-Item -ItemType 'directory' -path $tempInstallDir
}

Set-ExecutionPolicy Unrestricted

# Install Chocolatey
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Git
C:\ProgramData\chocolatey\bin\choco.exe install -y git python saltminion

Push-Location $tempInstallDir

# Run salt
Set-Location -Path $tempInstallDir
salt-call --local state.apply

if ( -not $? ) { Pop-Location;  die "Error running salt minion" }

Pop-Location

# End message to indicate completion of setup
Write-Host "`n`nClient is now configured."
