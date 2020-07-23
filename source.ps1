Invoke-SafeAppendToModulePath "$PSScriptRoot/Modules"

$d = "$PSScriptRoot/scripts"
if (Test-Path $d) {
    Get-ChildItem -Path $d -Filter '*.ps1' |
    ForEach-Object { . $_.FullName }
}

$global:SETUPS_ASSETS_DIR = "$PSScriptRoot/assets"