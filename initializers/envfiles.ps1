$h = $IsWindows ? "$env:USERPROFILE" : "/home/$env:USER"
$d = "$h/.files/env/bin"
if (Test-Path $d) { Invoke-SafeAppendToPath $d }