class CloneGroup {
    [string] $Group
    [string] $Source
    [string] $Remote
    [string] $RemotePath
}

class CloneItem {
    [string] $Operation
    [string] $Path
    [string] $NewPath
    [bool] $CopyLinks
    [bool] $AsSudo
}

function Get-CloneGroups (
    [Parameter(Mandatory = $false)] [string] $GroupName
) {
    if (-not $GroupName) { $GroupName = $env:OSID }
    $GroupName = $GroupName.ToLowerInvariant()
    Import-AssetCsv "$global:SETUPS_ASSETS_DIR/clones.csv" |
    Where-Object { $_.Group.ToLowerInvariant() -eq $GroupName }
}

function Get-BackupItems (
    [Parameter(Mandatory = $false)] [string] $GroupName
) {
    if (-not $GroupName) { $GroupName = $env:OSID }
    $group = $GroupName.ToLowerInvariant()
    Import-AssetCsv "$global:SETUPS_ASSETS_DIR/backup-groups/$group.csv"
}

function Get-DotFileItems (
    [Parameter(Mandatory = $false)] [string] $GroupName
) {
    if (-not $GroupName) { $GroupName = ($IsWindows ? 'windows' : $IsMacOS ? 'macos' : 'linux') }
    $group = $GroupName.ToLowerInvariant()
    Import-AssetCsv "$global:SETUPS_ASSETS_DIR/dotfile-groups/$group.csv"
}

function Invoke-Backups (
    [Parameter(Mandatory = $false)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $SourceFilter
    , [Parameter(Mandatory = $false)] [string] $RemoteFilter
    , [Parameter(Mandatory = $false)] [string] $ItemsPathFilter
    , [Parameter(Mandatory = $false)] [switch] $Restore
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
) {
    $cloneGroups = Get-CloneGroups $GroupName
    $cloneItems = Get-BackupItems $GroupName

    Invoke-RCloneItems `
        -CloneGroups $cloneGroups `
        -CloneItems $cloneItems `
        -SourceFilter $SourceFilter `
        -RemoteFilter $RemoteFilter `
        -ItemsPathFilter $ItemsPathFilter `
        -Restore:$Restore `
        -WhatIf:$WhatIf
}

function Initialize-DotFilePlugins (
    [Parameter(Mandatory = $true)] [CloneItem[]] $CloneItems
) {
    function confirm ($n) {
        Write-HostAsk "Install missing dotfile plugin '$n' ([Y]es/[n]o): " `
            -NoNewLine

        ((Read-Host) -notlike '*n*')
    }

    function missing ($n) {
        switch ($n) {
            'vim-plug' {
                (($IsWindows -and -not (Test-Path "$env:HOME/vimfiles/autoload/plug.vim")) -or
                 (-not $IsWindows -and -not (Test-Path "$env:HOME/.vim/autoload.plug.vim")))
            }
            'tpm' {
                (-not $IsWindows -and -not (Test-Path "$env:HOME/.tmux/plugins/tpm"))
            }
            'zplug' {
                (-not $IsWindows -and -not (Test-Path "$env:HOME/.zplug"))
            }
        }

    }

    foreach ($cloneItem in $CloneItems) {
        if (($cloneItem.Path.Contains('vim')) -and (missing 'vim-plug') -and (confirm 'vim-plug')) {
            $uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
            if ($IsWindows) {
                mkdir "$env:HOME/vimfiles/autoload" | Out-Null
                (New-Object Net.WebClient).DownloadFile(
                    $uri,
                    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
                        "$env:HOME/vimfiles/autoload/plug.vim"
                    )
                )
            } else {
                curl -fLo "$env:HOME/.vim/autoload/plug.vim" --create-dirs $uri
            }
        }

        if (($cloneItem.Path.Contains('tmux')) -and (missing 'tpm') -and (confirm 'tpm')) {
            git clone 'https://github.com/tmux-plugins/tpm' "$env:HOME/.tmux/plugins/tpm"
        }

        if (($cloneItem.Path.Contains('zsh')) -and (missing 'zplug') -and (confirm 'zplug')) {
            git clone 'https://github.com/zplug/zplug' "$env:HOME/.zplug"
        }
    }
}

function Invoke-DotFiles (
    [Parameter(Mandatory = $false)] [string] $SourceFilter
    , [Parameter(Mandatory = $false)] [string] $RemoteFilter
    , [Parameter(Mandatory = $false)] [string] $ItemsPathFilter
    , [Parameter(Mandatory = $false)] [switch] $Gather
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
) {
    $cloneGroups = Get-CloneGroups 'dotfiles'
    $cloneItems = Get-DotFileItems $null

    if (-not $WhatIf.IsPresent) {
        Initialize-DotFilePlugins $cloneItems
    }

    Invoke-RCloneItems `
        -CloneGroups $cloneGroups `
        -CloneItems $cloneItems `
        -SourceFilter $SourceFilter `
        -RemoteFilter $RemoteFilter `
        -ItemsPathFilter $ItemsPathFilter `
        -Restore:$($Gather.IsPresent ? $false : $true) `
        -WhatIf:$WhatIf
}

function Invoke-RCloneItems (
    [Parameter(Mandatory = $false)] [CloneGroup[]] $CloneGroups
    , [Parameter(Mandatory = $false)] [CloneItem[]] $CloneItems
    , [Parameter(Mandatory = $false)] [string] $SourceFilter
    , [Parameter(Mandatory = $false)] [string] $RemoteFilter
    , [Parameter(Mandatory = $false)] [string] $ItemsPathFilter
    , [Parameter(Mandatory = $false)] [switch] $Restore
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
) {
    $CloneGroups =
    if ($SourceFilter) {
        $sf = $SourceFilter.ToLowerInvariant()
        $CloneGroups | Where-Object { $_.Source -and $_.Source.ToLowerInvariant().Contains($sf) }
    } elseif ($RemoteFilter) {
        $rf = $RemoteFilter.ToLowerInvariant()
        $CloneGroups | Where-Object { $_.Remote -and $_.Remote.ToLowerInvariant().Contains($rf) }
    } else {
        $CloneGroups
    }

    $CloneItems =
    if ($ItemsPathFilter) {
        $pf = $ItemsPathFilter.ToLowerInvariant()
        $CloneItems | Where-Object {
            ($_.Path -and $_.Path.ToLowerInvariant().Contains($pf)) -or
            ($_.NewPath -and $_.NewPath.ToLowerInvariant().Contains($pf))
        }
    } else {
        $CloneItems
    }

    if (-not $CloneGroups) {
        Write-Host "no matching clone groups found.."
        return
    }

    if (-not $CloneItems) {
        Write-Host "no matching clone items found.."
        return
    }

    $rCloneItems = $CloneItems | ForEach-Object {
        [RCloneItem] @{
            Operation = $_.Operation
            Path      = $_.Path
            NewPath   = $_.NewPath
            CopyLinks = $_.CopyLinks ? [System.Convert]::ToBoolean($_.CopyLinks) : $false
            AsSudo    = $_.AsSudo ? [System.Convert]::ToBoolean($_.AsSudo) : $false
        }
    }

    # relative paths in targets should start in base folder
    Push-Location "$PSScriptRoot/.."

    foreach ($cloneGroup in $cloneGroups) {
        $rCloneParameters = [RCloneParameters] @{
            Source     = $cloneGroup.Source
            Remote     = $cloneGroup.Remote
            RemotePath = $cloneGroup.RemotePath
        }

        Invoke-RClone `
            -RCloneParameters $rCloneParameters `
            -RCloneItems $rCloneItems `
            -Restore:$Restore `
            -WhatIf:$WhatIf
    }

    Pop-Location
}

Export-ModuleMember -Function Invoke-Backups, Invoke-DotFiles