function Test-Command ($command) {
    $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
}

function Get-Packages (
    [Parameter(Mandatory = $true)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [string] $PackageManager
) {
    $gn = $GroupName.ToLowerInvariant()
    $pm = $PackageManager.ToLowerInvariant()

    Import-AssetList "$global:SETUPS_ASSETS_DIR/packages/$pm/$gn.txt"
}

function Invoke-Packages (
    [Parameter(Mandatory = $false)] [string] $GroupName
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
) {
    if (-not $GroupName) { $GroupName = $env:HOSTNAME }

    if (Test-Command 'apt') {
        $sudo = $true
        $pm = 'apt'
        $inst = "install"
    }

    if (Test-Command 'choco') {
        $pm = 'choco'
        $inst = "install"
    }

    if (Test-Command 'yay') {
        $pm = 'yay'
        $inst = "-S"
    }

    if (-not $pm) {
        Write-Host 'no valid package manager found..'
    }

    $packages = Get-Packages $GroupName $pm

    if (-not $packages) {
        Write-Host "no matching packages"
    }

    $command = Get-ConsoleCommand `
        -Line "$($sudo ? 'sudo ' : '')$pm $inst $($packages -join ' ')"

    Invoke-CommandsConcurrent `
        -Commands $command `
        -WhatIf:$WhatIf
}

Export-ModuleMember -Function Invoke-Packages
