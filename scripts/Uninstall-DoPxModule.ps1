<#############################################################################
The DoPx module provides a rich set of commands that extend the automation
capabilities of the DigitalOcean (DO) cloud service. These commands make it
easier to manage your DigitalOcean environment from Windows PowerShell. When
used with the LinuxPx module, you can manage all aspects of your environment
from one shell.

Copyright (c) 2014 Kirk Munro.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License in the
license folder that is included in the SmaPx module. If not, see
<https://www.gnu.org/licenses/gpl.html>.
#############################################################################>

# This script should only be invoked when you want to uninstall DoPx.

[CmdletBinding(SupportsShouldProcess=$true)]
[OutputType([System.Void])]
param(
    [Parameter()]
    [System.Management.Automation.SwitchParameter]
    $RemovePersistentData
)
try {
    #region Get the currently installed module (if there is one).

    Write-Progress -Activity 'Uninstalling DoPx' -Status 'Looking for an installed DoPx module.'
    $module = Get-Module -ListAvailable | Where-Object {$_.Guid -eq [System.Guid]'2aa000e6-a689-4443-a34e-20be26bfdabb'}
    if ($module -is [System.Array]) {
        [System.String]$message = 'More than one version of DoPx is installed on this system. This is not supported. Manually remove the versions you are not using and then try again.'
        [System.Management.Automation.SessionStateException]$exception = New-Object -TypeName System.Management.Automation.SessionStateException -ArgumentList $message
        [System.Management.Automation.ErrorRecord]$errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $exception,'SessionStateException',([System.Management.Automation.ErrorCategory]::InvalidOperation),$module
        throw $errorRecord
    }

    #endregion

    #region Remove the module.

    if ($module) {
        Write-Progress -Activity 'Uninstalling DoPx' -Status 'Unloading and removing the installed DoPx module.'
        # Unload the module if it is currently loaded.
        if ($loadedModule = Get-Module | Where-Object {$_.Guid -eq $module.Guid}) {
            $loadedModule | Remove-Module -ErrorAction Stop
        }
        # Remove the currently installed module.
        Remove-Item -LiteralPath $module.ModuleBase -Recurse -Force -ErrorAction Stop
    }

    #endregion

    #region Now remove the persistent data for the module if the caller requested it.

    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('RemovePersistentData') -and $RemovePersistentData) {
        foreach ($mlsRoot in $env:LocalAppData,$env:ProgramData) {
            $mlsPath = Join-Path -Path $mlsRoot -ChildPath "WindowsPowerShell\Modules\$($module.Name)"
            if (Test-Path -LiteralPath $mlsPath) {
                Remove-Item -LiteralPath $mlsPath -Recurse -Force -ErrorAction Stop
            }
        }
    }

    #endregion
} catch {
    $PSCmdlet.ThrowTerminatingError($_)
}