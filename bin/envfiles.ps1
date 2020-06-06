param(
    [Parameter(Mandatory = $false)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $SourceName
    , [Parameter(Mandatory = $false)] [string] $RemoteName
    , [Parameter(Mandatory = $false)] [string] $Filter
    , [Parameter(Mandatory = $false)] [switch] $Restore
    , [Parameter(Mandatory = $false)] [switch] $CopyLinks
    , [Parameter(Mandatory = $false)] [switch] $DryRun
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
)

if (-not $GroupName) { $GroupName = $env:OS_ID }

$old_profile_assets_dir = $global:PROFILE_ASSETS_DIR
$global:PROFILE_ASSETS_DIR = "$PSScriptRoot/../assets"

Push-Location "$PSScriptRoot/.."

rcloneGroup `
    -GroupName $GroupName `
    -SourceName $SourceName `
    -RemoteName $RemoteName `
    -Filter $Filter `
    -Restore:$Restore `
    -CopyLinks:$CopyLinks `
    -DryRun:$DryRun `
    -WhatIf:$WhatIf

$global:PROFILE_ASSETS_DIR = $old_profile_assets_dir

Pop-Location