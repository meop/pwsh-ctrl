Import-Module "$PSScriptRoot/setups.psm1"

Set-Alias -Name setups -Value Update-Setups

Import-Module "$PSScriptRoot/clones.psm1"

Set-Alias -Name backups -Value Invoke-Backups
Set-Alias -Name dotfiles -Value Invoke-DotFiles

Import-Module "$PSScriptRoot/packages.psm1"

Set-Alias -Name prepare -Value Initialize-Packages
Set-Alias -Name packages -Value Invoke-Packages

$global:SETUPS_ASSETS_DIR = "$PSScriptRoot/assets"