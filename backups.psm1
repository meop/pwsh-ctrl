function Get-Backups (
    [Parameter(Mandatory = $true)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $SourceFilter
    , [Parameter(Mandatory = $false)] [string] $RemoteFilter
) {
    $gn = $GroupName.ToLowerInvariant()
    $x = Import-AssetCsv "$global:SETUPS_ASSETS_DIR/backups.csv" |
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

function Get-BackupGroups (
    [Parameter(Mandatory = $true)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $PathFilter
) {
    $gn = $GroupName.ToLowerInvariant()
    $x = Import-AssetCsv "$global:SETUPS_ASSETS_DIR/backup-groups/$env:OS_KERNEL/$gn.csv"

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

function Invoke-DotFiles (
    [Parameter(Mandatory = $false)] [string] $BackupSourceFilter
    , [Parameter(Mandatory = $false)] [string] $BackupRemoteFilter
    , [Parameter(Mandatory = $false)] [string] $BackupGroupsPathFilter
    , [Parameter(Mandatory = $false)] [switch] $Gather
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
) {
    Invoke-Backups `
        -GroupName 'dotfiles' `
        -BackupSourceFilter $BackupSourceFilter `
        -BackupRemoteFilter $BackupRemoteFilter `
        -BackupGroupsPathFilter $BackupGroupsPathFilter `
        -Restore:$($Gather.IsPresent ? $false : $true) `
        -WhatIf:$WhatIf
}

function Invoke-Backups (
    [Parameter(Mandatory = $false)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $BackupSourceFilter
    , [Parameter(Mandatory = $false)] [string] $BackupRemoteFilter
    , [Parameter(Mandatory = $false)] [string] $BackupGroupsPathFilter
    , [Parameter(Mandatory = $false)] [switch] $Restore
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
) {
    if (-not $GroupName) { $GroupName = $env:OS_ID }

    $backups = Get-Backups `
        -GroupName $GroupName `
        -SourceFilter $BackupSourceFilter `
        -RemoteFilter $BackupRemoteFilter

    if (-not $backups) {
        Write-Host "no matching backups"
    }

    $backupGroups = Get-BackupGroups `
        -GroupName $GroupName `
        -PathFilter $BackupGroupsPathFilter

    if (-not $backupGroups) {
        Write-Host "no matching backup groups"
    }

    $rCloneBackupItems = $BackupGroups | ForEach-Object {
        [RCloneBackupItem] @{
            Operation = $_.Operation
            Path      = $_.Path
            NewPath   = $_.NewPath
            CopyLinks = $_.CopyLinks ? [System.Convert]::ToBoolean($_.CopyLinks) : $false
            AsSudo    = $_.AsSudo ? [System.Convert]::ToBoolean($_.AsSudo) : $false
        }
    }

    # relative paths in targets should start in base folder
    Push-Location "$PSScriptRoot/.."

    foreach ($backup in $Backups) {
        $rCloneBackup = [RCloneBackup] @{
            Source     = $backup.Source
            Remote     = $backup.Remote
            RemotePath = $backup.RemotePath
            Items      = $rCloneBackupItems
        }

        Invoke-RCloneBackup `
            -Backup $rCloneBackup `
            -Restore:$Restore `
            -WhatIf:$WhatIf
    }

    Pop-Location
}

Export-ModuleMember -Function Invoke-DotFiles, Invoke-Backups