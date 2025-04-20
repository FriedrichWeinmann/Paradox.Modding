[CmdletBinding()]
param ()

$ErrorActionPreference = 'Stop'
trap {
	Write-Warning "Script failed: $_"
	throw $_
}

# Import Modules
Import-Module Paradox.Modding.Core
Import-Module Paradox.Modding.HOI4

# Build it all
Build-PdxMod -Path $PSScriptRoot -Game HOI4 -Tags HOI4

# Alternative: Build to a specific path
# Build-PdxMod -Path $PSScriptRoot -OutPath '~/Documents/Paradox Interactive/Hearts of Iron IV/mod/' -Tags HOI4