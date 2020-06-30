class PackageGroup {
    [string] $Group
    [string] $Manager
    [string] $InstallFlags
    [bool] $AsSudo
}

function Test-Command (
    [Parameter(Mandatory = $true)] [string] $Name
) {
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Initialize-PackageManager (
    [Parameter(Mandatory = $true)] [string] $Manager
) {
    function confirm {
        Write-HostAsk "Install missing package manager '$Manager' ([Y]es/[n]o): " `
            -NoNewline

        ((Read-Host) -notlike '*n*')
    }

    function missing ($o, $m) {
        ($env:OSID -eq $o) -and ($m -eq $Manager) -and -not (Test-Command $m)
    }

    if ((missing 'windows' 'choco') -and (confirm)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force

        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    if ((missing 'arch' 'yay') -and (confirm)) {
        git clone 'https://aur.archlinux.org/yay-bin.git' "$env:HOME/yay-bin"

        Push-Location "$env:HOME/yay-bin"
        makepkg -sri
        Pop-Location

        Remove-Item "$env:HOME/yay-bin" -Recurse -Force
    }
}

function Get-PackageGroup {
    $group = ($env:OSID).ToLowerInvariant()
    Import-AssetCsv "$global:SETUPS_ASSETS_DIR/packages.csv" |
        Where-Object { $_.Group.ToLowerInvariant() -eq $group } |
        Select-Object -First 1
}

function Get-Packages (
    [Parameter(Mandatory = $false)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $Manager
) {
    if (-not $GroupName) { $GroupName = $env:HOSTNAME }

    $group = $GroupName.ToLowerInvariant()
    $manager = $Manager.ToLowerInvariant()

    Import-AssetList "$global:SETUPS_ASSETS_DIR/package-groups/$manager/$group.txt"
}

enum PackagesOperation {
    upgrade
    cleanup
    install
    list
}

function Invoke-Packages (
    [Parameter(Mandatory = $false)] [PackagesOperation] $Operation = [PackagesOperation]::upgrade
    , [Parameter(Mandatory = $false)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
) {
    $packageGroup = Get-PackageGroup

    if (-not $packageGroup -or -not $packageGroup.Manager) {
        Write-Host 'no matching package manager found..'
        return
    }

    if (-not $WhatIf.IsPresent) {
        Initialize-PackageManager $packageGroup.Manager
    }

    $flags = switch ($Operation) {
        ([PackagesOperation]::upgrade) { $packageGroup.UpgradeFlags }
        ([PackagesOperation]::cleanup) { $packageGroup.CleanupFlags }
        ([PackagesOperation]::install) { $packageGroup.InstallFlags }
        ([PackagesOperation]::list) { $packageGroup.ListFlags }
    }

    if (([PackagesOperation]::install) -eq $Operation) {
        $packages = Get-Packages $GroupName $packageGroup.Manager
        if (-not $packages) {
            Write-Host 'no matching packages found..'
            return
        }
    }

    if (-not $flags) {
        Write-Host "no matching operation '$Operation' for manager '$($packageGroup.Manager)'.."
        return
    }

    $command = Get-ConsoleCommand `
        -Line "$($packageGroup.AsSudo ? 'sudo ' : '')$($packageGroup.Manager) $flags $($packages -join ' ')"

    Invoke-CommandsConcurrent `
        -Commands $command `
        -WhatIf:$WhatIf
}

Export-ModuleMember -Function Invoke-Packages