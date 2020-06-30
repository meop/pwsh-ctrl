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

function Select-Groups (
    [Parameter(Mandatory = $false)] [CloneGroup[]] $Groups
    , [Parameter(Mandatory = $false)] [string] $SourceFilter
    , [Parameter(Mandatory = $false)] [string] $RemoteFilter
) {
    if ($SourceFilter) {
        $sf = $SourceFilter.ToLowerInvariant()
        $Groups | Where-Object { $_.Source -and $_.Source.ToLowerInvariant().Contains($sf) }
    } elseif ($RemoteFilter) {
        $rf = $RemoteFilter.ToLowerInvariant()
        $Groups | Where-Object { $_.Remote -and $_.Remote.ToLowerInvariant().Contains($rf) }
    } else {
        $Groups
    }
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
                 (-not $IsWindows -and -not (Test-Path "$env:HOME/.vim/autoload/plug.vim")))
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

function Select-Items (
    [Parameter(Mandatory = $false)] [CloneItem[]] $Items
    , [Parameter(Mandatory = $false)] [string] $PathFilter
) {
    if ($PathFilter) {
        $pf = $PathFilter.ToLowerInvariant()
        $Items | Where-Object {
            ($_.Path -and $_.Path.ToLowerInvariant().Contains($pf)) -or
            ($_.NewPath -and $_.NewPath.ToLowerInvariant().Contains($pf))
        }
    } else {
        $Items
    }
}

function Invoke-Backups (
    [Parameter(Mandatory = $false)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $SourceFilter
    , [Parameter(Mandatory = $false)] [string] $RemoteFilter
    , [Parameter(Mandatory = $false)] [string] $ItemPathFilter
    , [Parameter(Mandatory = $false)] [switch] $Restore
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
) {
    $groups = Select-Groups (Get-CloneGroups $GroupName) $SourceFilter $RemoteFilter
    $items = Select-Items (Get-BackupItems $GroupName) $ItemPathFilter

    Invoke-RCloneItems `
        -Groups $groups `
        -Items $items `
        -Restore:$Restore `
        -WhatIf:$WhatIf
}

function Invoke-DotFiles (
    [Parameter(Mandatory = $false)] [string] $SourceFilter
    , [Parameter(Mandatory = $false)] [string] $RemoteFilter
    , [Parameter(Mandatory = $false)] [string] $ItemPathFilter
    , [Parameter(Mandatory = $false)] [switch] $Gather
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
) {
    $groups = Select-Groups (Get-CloneGroups 'dotfiles') $SourceFilter $RemoteFilter
    $items = Select-Items (Get-DotFileItems $null) $ItemPathFilter

    Invoke-RCloneItems `
        -Groups $groups `
        -Items $items `
        -Restore:$(-not $Gather.IsPresent) `
        -WhatIf:$WhatIf

    if (-not $WhatIf.IsPresent) {
        Initialize-DotFilePlugins $items
    }
}

function Invoke-RCloneItems (
    [Parameter(Mandatory = $false)] [CloneGroup[]] $Groups
    , [Parameter(Mandatory = $false)] [CloneItem[]] $Items
    , [Parameter(Mandatory = $false)] [switch] $Restore
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
) {
    if (-not $Groups) {
        Write-Host "no matching clone groups found.."
        return
    }

    if (-not $Items) {
        Write-Host "no matching clone items found.."
        return
    }

    $rCloneItems = $Items | ForEach-Object {
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

    foreach ($group in $Groups) {
        $rCloneParameters = [RCloneParameters] @{
            Source     = $group.Source
            Remote     = $group.Remote
            RemotePath = $group.RemotePath
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