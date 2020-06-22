$FILES_ASSETS_DIR = "$PSScriptRoot/assets"

function rCloneGetBackups (
    [Parameter(Mandatory = $true)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $SourceFilter
    , [Parameter(Mandatory = $false)] [string] $RemoteFilter
) {
    $gn = $GroupName.ToLowerInvariant()
    $x = Import-AssetCsv "$FILES_ASSETS_DIR/backups.csv" |
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

function rCloneGetBackupItems (
    [Parameter(Mandatory = $true)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $PathFilter
) {
    $gn = $GroupName.ToLowerInvariant()
    $x = Import-AssetCsv "$FILES_ASSETS_DIR/backup-items/$gn.csv"

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