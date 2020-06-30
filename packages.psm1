class PackageGroup {
    [string] $GroupName
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

        ((Read-Host) -like '*n*')
    }

    function missing ($n) {
        ($n -eq $Manager) -and -not (Test-Command $n)
    }

    if ((missing 'choco') -and
        ($env:OSID -eq 'windows')
    ) {
        if (-not (confirm)) { break }

        Set-ExecutionPolicy Bypass -Scope Process -Force

        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    if ((missing 'yay') -and
        ($env:OSID -eq 'arch')
    ) {
        if (-not (confirm)) { break }

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
    [Parameter(Mandatory = $true)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $Manager
) {
    if (-not $GroupName) { $GroupName = $env:HOSTNAME }

    $group = $GroupName.ToLowerInvariant()
    $manager = $Manager.ToLowerInvariant()

    Import-AssetList "$global:SETUPS_ASSETS_DIR/package-groups/$manager/$group.txt"
}

function Invoke-Packages (
    [Parameter(Mandatory = $false)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
) {
    if (-not $GroupName) { $GroupName = $env:HOSTNAME }

    $packageGroup = Get-PackageGroup

    if (-not $packageGroup -or -not $packageGroup.Manager) {
        Write-Host 'no matching package manager found..'
        return
    }

    $packages = Get-Packages $GroupName $packageGroup.Manager

    if (-not $packages) {
        Write-Host 'no matching packages found..'
        return
    }

    Initialize-PackageManager $packageGroup.Manager

    $command = Get-ConsoleCommand `
        -Line "$($packageGroup.AsSudo ? 'sudo ' : '')$($packageGroup.Manager) $($packageGroup.InstallFlags) $($packages -join ' ')"

    Invoke-CommandsConcurrent `
        -Commands $command `
        -WhatIf:$WhatIf
}

Export-ModuleMember -Function Invoke-Packages