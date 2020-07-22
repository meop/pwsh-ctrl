$d = "$PSScriptRoot/modules"
if (Test-Path $d) {
    Get-ChildItem -Path $d -Filter '*.psm1' |
    ForEach-Object { Import-Module $_.FullName }
}

Set-Alias -Name setups -Value Update-Setups
Set-Alias -Name backups -Value Invoke-Backups
Set-Alias -Name dotfiles -Value Invoke-DotFiles
Set-Alias -Name packages -Value Invoke-Packages

$global:SETUPS_ASSETS_DIR = "$PSScriptRoot/assets"