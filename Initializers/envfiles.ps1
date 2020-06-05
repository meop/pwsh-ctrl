$h = $IsWindows ? "$env:USERPROFILE" : "/home/$env:USER"
$d = "$h/.envfiles/bin"
if (Test-Path $d) { Invoke-SafeAppendToPath $d }