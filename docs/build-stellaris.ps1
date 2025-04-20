[CmdletBinding()]
param ()

$ErrorActionPreference = 'Stop'
trap {
	Write-Warning "Script failed: $_"
	throw $_
}

# Import Modules
Import-Module Paradox.Modding.Core
Import-Module Paradox.Modding.Stellaris

# Build it all
Build-PdxMod -Path $PSScriptRoot -Game Stellaris -Tags Stellaris

# Alternative: Build to a specific path
# Build-PdxMod -Path $PSScriptRoot -OutPath '~/Documents/Paradox Interactive/Stellaris/mod/' -Tags Stellaris