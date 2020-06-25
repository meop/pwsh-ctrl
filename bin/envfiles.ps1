param(
    [Parameter(Mandatory = $false)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $SourceFilter
    , [Parameter(Mandatory = $false)] [string] $RemoteFilter
    , [Parameter(Mandatory = $false)] [string] $PathFilter
    , [Parameter(Mandatory = $false)] [switch] $Restore
    , [Parameter(Mandatory = $false)] [switch] $CopyLinks
    , [Parameter(Mandatory = $false)] [switch] $DryRun
    , [Parameter(Mandatory = $false)] [switch] $AsSudo
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
)

. "$PSScriptRoot/../source.ps1"

if (-not $GroupName) { $GroupName = $env:OS_ID }

$backups = rCloneGetBackups `
    -GroupName $GroupName `
    -SourceFilter $SourceFilter `
    -RemoteFilter $RemoteFilter

if (-not $backups) {
    Write-Host "no matching backups"
}

$backupItems = rCloneGetBackupItems `
    -GroupName $GroupName `
    -PathFilter $PathFilter

if (-not $backupItems) {
    Write-Host "no matching backup items"
}

$rCloneBackupItems = $backupItems | ForEach-Object { [RCloneBackupItem] @{
        Operation = $_.Operation
        Path      = $_.Path
        NewPath   = $_.NewPath
    } }

# relative paths in targets should start in base folder
Push-Location "$PSScriptRoot/.."

foreach ($backup in $backups) {
    $rCloneBackup = [RCloneBackup] @{
        Source     = $backup.Source
        Remote     = $backup.Remote
        RemotePath = $backup.RemotePath
        Items      = $rCloneBackupItems
    }

    Invoke-RCloneBackup `
        -Backup $rCloneBackup `
        -Restore:$Restore `
        -CopyLinks:$CopyLinks `
        -DryRun:$DryRun `
        -AsSudo:$AsSudo `
        -WhatIf:$WhatIf
}

Pop-Location