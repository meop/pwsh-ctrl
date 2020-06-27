$f = "$env:HOME/setups/source.ps1"
if (Test-Path $f) { . $f }

Set-Alias -Name dotfiles -Value Invoke-DotFiles
Set-Alias -Name backups -Value Invoke-Backups
Set-Alias -Name packages -Value Invoke-Packages