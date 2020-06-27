# Prerequisite

Install PowerShell profile project

https://github.com/meop/profile-pwsh.git


# Setup

> pseudo: cp ./Initializers/* /%userprofile%/Documents/Powershell/Initializers/

Edit your /Initializers/*.ps1 file to set the path to this repo


# Configure

In the backups.csv, a default RClone target named 'local' can be used, which would target a local folder on your local file system

But if you set up RClone, per its docs, with another remote, ie. to Microsoft OneDrive, then you could use that remote name instead

You can also put other rows in the file, targeting different remotes, using either the same or another backup-group definition

The library should name match and run through all the backups you define


# DotFiles

## Installing

Hardcodes GroupName to 'dotfiles'

> dotfiles -WhatIf

Specifying an RClone source

> dotfiles -BackupSourceFilter local -WhatIf

Specifying an RClone remote

> dotfiles -BackupRemoteFilter onedrive -WhatIf

Being selective

> dotfiles -BackupGroupsPathFilter term -WhatIf

## Gathering

Reverse, gather dotfiles

> dotfiles -Gather -WhatIf

You can also use the same filters as above


# Backups

Remove the `-WhatIf` flag to really run the commands

## Copying files / Syncing folders

Defaults GroupName to $env:OS_ID

> backups -WhatIf

Specifying GroupName

> backups -GroupName some_other_csv_config_name -WhatIf

Specifying an RClone source

> backups -BackupSourceFilter local -WhatIf

Specifying an RClone remote

> backups -BackupRemoteFilter onedrive -WhatIf

Being selective

> backups -BackupGroupsPathFilter term -WhatIf

## Restoring

Restoring backups, ie. changing the direction of the operation

> backups -Restore -WhatIf

You can also use the same filters as above


# Packages

Defaults GroupName to $env:HOSTNAME

> packages -WhatIf

> packages -GroupName something_else -WhatIf


# Advanced

These are all on-demand examples, but you could also setup scripts to run using a task scheduler