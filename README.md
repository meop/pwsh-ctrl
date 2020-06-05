# Prerequisite

Install PowerShell profile project

https://tfs.prd.costargroup.com/CostarCollection/CoStarSuite-Git/_git/analytics-profile-pwsh


# Setup

Make a copy of the assets directory so that you have your own directory in parallel, ie:

> pseudo: cp -r ./assets-example ./assets

Copy the Initializers file to the corresponding profile folder

> pseudo: cp ./Initializers/* /%userprofile%/Documents/Powershell/Initializers/

Edit your /Initializers/*.ps1 file to set the path to this repo


# Configure

In the backups.csv, a default RClone target named 'local' can be used, which would target a local folder on your local file system

But if you set up RClone, per its docs, with another remote, ie. to Microsoft OneDrive, then you could use that remote name instead

You can also put other rows in the file, targeting different remotes, using either the same or another backup-group definition

The library should name match and run through all the backups you define


# Run

Remove the `-WhatIf` flag to really run the commands

## Basic

Allowing GroupName to default to os id

> envfiles.ps1 -WhatIf

Specifying a GroupName

> envfiles.ps1 -GroupName some_other_csv_config_name -WhatIf

Specifying an RClone remote

> envfiles.ps1 -RemoteName onedrive -WhatIf

## Restoring

Restoring backups, ie. changing the direction of the operation

> envfiles.ps1 -Restore -WhatIf

Restoring backups selectively

> envfiles.ps1 -Restore -Filter iis -WhatIf


# Advanced

There are a few of other flags that the library wrapping RClone supports, like symlinks, etc.. so feel free to explore

You could also set up the binary to run on a schedule in your OS with some arguments, to automate backups