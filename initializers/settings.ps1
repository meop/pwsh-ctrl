$h = $IsWindows ? "$env:USERPROFILE" : "/home/$env:USER"
$f = "$h/settings/source.ps1"
if (Test-Path $f) { . $f }

Set-Alias -Name settings -Value Invoke-Settings