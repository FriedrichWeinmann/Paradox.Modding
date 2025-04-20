[CmdletBinding()]
param (
	$ApiKey,
	
	$WorkingDirectory,
	
	$Repository = 'PSGallery'
)

$ErrorActionPreference = 'Stop'
trap {
	Write-Warning "Script failed: $_"
	Get-PSFTempItem | Remove-PSFTempItem
	throw $_
}

#region Handle Working Directory Defaults
if (-not $WorkingDirectory) {
	if ($env:RELEASE_PRIMARYARTIFACTSOURCEALIAS) {
		$WorkingDirectory = Join-Path -Path $env:SYSTEM_DEFAULTWORKINGDIRECTORY -ChildPath $env:RELEASE_PRIMARYARTIFACTSOURCEALIAS
	}
	else { $WorkingDirectory = $env:SYSTEM_DEFAULTWORKINGDIRECTORY }
}
if (-not $WorkingDirectory) { $WorkingDirectory = Split-Path $PSScriptRoot }
#endregion Handle Working Directory Defaults

Install-Module PSFramework.NuGet -Force -Repository $Repository

#region Functions
function Find-ParadoxModule {
	[CmdletBinding()]
	param (
		[string]
		$Repository,

		[string[]]
		$ExtraModules
	)

	Find-PSFModule -Repository $Repository -Name (@('Paradox.Modding.*') + $ExtraModules | Remove-PSFNull) | Group-Object Name | ForEach-Object {
		$_.Group | Sort-Object Type -Descending | Select-Object -First 1
	}
}

function Find-ReleaseModule {
	[CmdletBinding()]
	param (
		[string]
		$Repository,

		[string]
		$Name
	)

	try { Find-PSFModule -Repository $Repository -Name $Name -ErrorAction Ignore 2>$null | Sort-Object Type -Descending | Select-Object -First 1 }
	catch { }
}

function Test-VersionUpdate {
	[CmdletBinding()]
	param (
		$Available,

		[AllowNull()]
		$Current
	)

	if (-not $Current) { return $true }

	$currentHash = @{ }
	foreach ($dependency in $Current.Object.Dependencies) {
		# PSResourceGet
		if ($dependency.VersionRange.MinVersion) {
			$currentHash[$dependency.Name] = $dependency.VersionRange.MinVersion.OriginalVersion
		}
		# PowerShellGet
		else {
			$currentHash[$dependency.Name] = $dependency.MinimumVersion
		}
	}

	foreach ($module in $Available) {
		if (-not $currentHash[$module.Name]) { return $true }
		if ($Available.Version -gt $currentHash[$module.Name]) { return $true }
	}

	$false
}

function Publish-WrapperModule {
	[CmdletBinding()]
	param (
		[string]
		$Name,

		[string]
		$Repository,

		$Dependencies,

		$LastVersion,

		$Manifest,

		[string]
		$ApiKey
	)

	$tempDir = New-PSFTempDirectory -Name Test -ModuleName Build -DirectoryName $Name
	Copy-Item -Path $Manifest -Destination "$tempDir\$Name.psd1"

	$dependencyData = foreach ($dependency in $Dependencies) {
		@{ ModuleName = $dependency.Name; ModuleVersion = $dependency.Version }
	}
	Update-PSFModuleManifest -Path "$tempDir\$Name.psd1" -RequiredModules $dependencyData
	if ($LastVersion) {
		$manifestData = Import-PSFPowerShellDataFile -Path "$tempDir\$Name.psd1"
		$mVersion = $manifestData.ModuleVersion -as [version]
		$major = $mVersion.Major, $LastVersion.Version.Major | Sort-Object -Descending | Select-Object -First 1
		$minor = $mVersion.Minor, $LastVersion.Version.Minor | Sort-Object -Descending | Select-Object -First 1
		$build = $mVersion.Build, $LastVersion.Version.Build | Sort-Object -Descending | Select-Object -First 1

		$newVersion = [version]::new($major, $minor, ($build + 1))
		Update-PSFModuleManifest -Path "$tempDir\$Name.psd1" -ModuleVersion $newVersion
	}

	"" | Set-Content -Path "$tempDir\$Name.psm1"
	Publish-PSFModule -Path $tempDir -Repository $Repository -ApiKey $ApiKey -SkipDependenciesCheck

	Get-PSFTempItem | Remove-PSFTempItem
}
#endregion Functions

$dependencyVersions = Find-ParadoxModule -Repository $Repository -ExtraModules 'PSFramework', 'String'
$releasedVersions = Find-ReleaseModule -Repository $Repository -Name 'Paradox.Modding'
if (Test-VersionUpdate -Available $dependencyVersions -Current $releasedVersions) {
	Publish-WrapperModule -Name 'Paradox.Modding' -Repository $Repository -Dependencies $dependencyVersions -LastVersion $releasedVersions -ApiKey $ApiKey -Manifest "$PSScriptRoot\Paradox.Modding.psd1"
}