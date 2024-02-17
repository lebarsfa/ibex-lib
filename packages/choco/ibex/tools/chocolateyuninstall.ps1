﻿$ErrorActionPreference = 'Stop'; # Stop on all errors.

# Source variables which are shared between install and uninstall.
. $PSScriptRoot\sharedVars.ps1

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$pp = Get-PackageParameters
$packageDir = Join-Path "$toolsDir" ".." -Resolve
$installDir = Join-Path "$packageDir" ".." -Resolve
if ($pp.InstallDir -or $pp.InstallationPath) { 
	$installDir = $pp.InstallDir + $pp.InstallationPath 
}
Write-Host "IBEX is going to be uninstalled from '$installDir'"

$root = Join-Path $installDir "ibex"

$newpath = [environment]::GetEnvironmentVariable("Path","Machine")
$newpath = ($newpath.Split(';') | Where-Object { $_ -ne "$root\bin" }) -join ';'
[environment]::SetEnvironmentVariable("Path",$newpath,"Machine")

try {
    Get-ItemProperty -Path $CMakeSystemRepositoryPath\$CMakePackageName | Select-Object -ExpandProperty "$CMakePackageName$CMakePackageVer`_$arch" -ErrorAction Stop | Out-Null
    Remove-ItemProperty -Path $CMakeSystemRepositoryPath\$CMakePackageName -Name "$CMakePackageName$CMakePackageVer`_$arch"
}
catch {

}

if (Test-Path $root) {
    if ((Resolve-Path $root).Path -notcontains (Resolve-Path $packageDir).Path) {
        Remove-Item -Recurse -Force $root
    }
}
