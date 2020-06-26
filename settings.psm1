$SETTINGS_ASSETS_DIR = "$PSScriptRoot/assets"

function Get-RCloneBackups (
    [Parameter(Mandatory = $true)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $SourceFilter
    , [Parameter(Mandatory = $false)] [string] $RemoteFilter
) {
    $gn = $GroupName.ToLowerInvariant()
    $x = Import-AssetCsv "$SETTINGS_ASSETS_DIR/backups.csv" |
    Where-Object { $_.Group.ToLowerInvariant() -eq $gn }

    if ($SourceFilter) {
        $sf = $SourceFilter.ToLowerInvariant()
        $x | Where-Object { $_.Source -and $_.Source.ToLowerInvariant().Contains($sf) }
    } elseif ($RemoteFilter) {
        $rf = $RemoteFilter.ToLowerInvariant()
        $x | Where-Object { $_.Remote -and $_.Remote.ToLowerInvariant().Contains($rf) }
    } else {
        $x
    }
}

function Get-RCloneBackupItems (
    [Parameter(Mandatory = $true)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $PathFilter
) {
    $gn = $GroupName.ToLowerInvariant()
    $x = Import-AssetCsv "$SETTINGS_ASSETS_DIR/backup-items/$gn.csv"

    if ($PathFilter) {
        $pf = $PathFilter.ToLowerInvariant()
        $x | Where-Object {
            ($_.Path -and $_.Path.ToLowerInvariant().Contains($pf)) -or
            ($_.NewPath -and $_.NewPath.ToLowerInvariant().Contains($pf))
        }
    } else {
        $x
    }
}

function Invoke-Settings (
    [Parameter(Mandatory = $false)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $BackupSourceFilter
    , [Parameter(Mandatory = $false)] [string] $BackupRemoteFilter
    , [Parameter(Mandatory = $false)] [string] $BackupItemsPathFilter
    , [Parameter(Mandatory = $false)] [switch] $Restore
    , [Parameter(Mandatory = $false)] [switch] $CopyLinks
    , [Parameter(Mandatory = $false)] [switch] $DryRun
    , [Parameter(Mandatory = $false)] [switch] $AsSudo
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
) {

    if (-not $GroupName) { $GroupName = $env:OS_ID }

    $backups = Get-RCloneBackups `
        -GroupName $GroupName `
        -SourceFilter $BackupSourceFilter `
        -RemoteFilter $BackupRemoteFilter

    if (-not $backups) {
        Write-Host "no matching backups"
    }

    $backupItems = Get-RCloneBackupItems `
        -GroupName $GroupName `
        -PathFilter $BackupItemsPathFilter

    if (-not $backupItems) {
        Write-Host "no matching backup items"
    }

    $rCloneBackupItems = $backupItems | ForEach-Object {
        [RCloneBackupItem] @{
            Operation = $_.Operation
            Path      = $_.Path
            NewPath   = $_.NewPath
        }
    }

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
}

Export-ModuleMember -Function Invoke-Settings