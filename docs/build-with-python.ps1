<#
Example for a mod-specific build file you would place as build.ps1 in the root of the mod directory.
In this case, we want to do the actual mod automation in Python!

This assumes Python is available by name alone (added to the Path environment variable, as a default install would do)
#>
python (Get-Item -Path "$PSScriptRoot/build.py").FullName # This ensures that the slashes in the path are OS-appropriate, no matter where