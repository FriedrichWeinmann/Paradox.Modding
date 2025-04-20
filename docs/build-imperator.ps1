[CmdletBinding()]
param ()

$ErrorActionPreference = 'Stop'
trap {
	Write-Warning "Script failed: $_"
	throw $_
}

# Import Modules
Import-Module Paradox.Modding.Core

# Build it all
Build-PdxMod -Path $PSScriptRoot -Game Imperator -Tags Imperator

# Alternative: Build to a specific path
# Build-PdxMod -Path $PSScriptRoot -OutPath '~/Documents/Paradox Interactive/Imperator/mod/' -Tags Imperator