enum SetupsTarget {
    self
    profile
}

function Update-Setups (
    [Parameter(Mandatory = $false)] [SetupsTarget] $Target = [SetupsTarget]::self
) {
    $location =
    switch ($Target) {
        ([SetupsTarget]::profile) {
            if ($IsWIndows) {
                "$env:USERPROFILE/Documents/Powershell"
            } else {
                "$env:HOME/.config/powershell"
            }
        }
        ([SetupsTarget]::self) {
            "$env:HOME/setups"
        }
    }

    Push-Location $location

    git pull

    Pop-Location
}

Export-ModuleMember -Function Update-Setups