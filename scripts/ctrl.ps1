enum CsUpdateRCloneRemote {
    local
    sftp
}

enum CtrlOperation {
    Setups
    Backups
    DotFiles
    Packages
}

function csUpdate (
    [Parameter(Mandatory = $true)] [CsUpdateTarget] $Target
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
) {
    switch ($Target) {
        ([CsUpdateTarget]::Host2000) {
            csUpdateHost2000 `
                -WhatIf:$WhatIf
        }
        ([CsUpdateTarget]::LookupServiceIndexes) {
            csUpdateLookupServiceIndexes `
                -WhatIf:$WhatIf
        }
        ([CsUpdateTarget]::Neo4jCsvFilesLocal) {
            csUpdateNeo4jCsvFiles `
                -Remote $([CsUpdateRCloneRemote]::local) `
                -WhatIf:$WhatIf
        }
        ([CsUpdateTarget]::Neo4jCsvFilesSftp) {
            csUpdateNeo4jCsvFiles `
                -Remote $([CsUpdateRCloneRemote]::sftp) `
                -WhatIf:$WhatIf
        }
    }
}