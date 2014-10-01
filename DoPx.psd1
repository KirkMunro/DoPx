<#############################################################################
The DoPx module provides a rich set of commands that extend the automation
capabilities of the Digital Ocean (DO) cloud service. These commands make it
easier to manage your Digital Ocean environment from Windows PowerShell. When
used with the SshPx module, you can manage all aspects of your environment
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

@{
      ModuleToProcess = 'DoPx.psm1'

        ModuleVersion = '1.0.0.0'

                 GUID = '2aa000e6-a689-4443-a34e-20be26bfdabb'

               Author = 'Kirk Munro'

          CompanyName = 'Poshoholic Studios'

            Copyright = '© 2014 Kirk Munro'

          Description = 'The DoPx module provides a rich set of commands that extend the automation capabilities of the Digital Ocean (DO) cloud service. These commands make it easier to manage your Digital Ocean environment from Windows PowerShell. When used with the SshPx module, you can manage your entire DigitalOcean environment from one shell.'

    PowerShellVersion = '3.0'

      RequiredModules = @(
                        #'SshPx'
                        'TypePx'
                        'SnippetPx'
                        )

     ScriptsToProcess = @(
                        )

    FunctionsToExport = @(
                        'Add-DoPxDomain'
                        'Add-DoPxDnsRecord'
                        'Add-DoPxSshKey'
                        'Clear-DoPxDefaultAccessToken'
                        'Copy-DoPxBackup'
                        'Copy-DoPxSnapshot'
                        'Disable-DoPxDropletOption'
                        'Enable-DoPxDropletOption'
                        'Get-DoPxAction'
                        'Get-DoPxBackup'
                        'Get-DoPxDefaultAccessToken'
                        'Get-DoPxDomain'
                        'Get-DoPxDnsRecord'
                        'Get-DoPxDroplet'
                        'Get-DoPxImage'
                        'Get-DoPxKernel'
                        'Get-DoPxRegion'
                        'Get-DoPxSize'
                        'Get-DoPxSnapshot'
                        'Get-DoPxSshKey'
                        'New-DoPxDroplet'
                        'New-DoPxSnapshot'
                        'Receive-DoPxAction'
                        'Remove-DoPxBackup'
                        'Remove-DoPxDomain'
                        'Remove-DoPxDnsRecord'
                        'Remove-DoPxDroplet'
                        'Remove-DoPxSnapshot'
                        'Remove-DoPxSshKey'
                        'Rename-DoPxBackup'
                        'Rename-DoPxDnsRecord'
                        'Rename-DoPxDroplet'
                        'Rename-DoPxSnapshot'
                        'Rename-DoPxSshKey'
                        'Reset-DoPxDroplet'
                        'Resize-DoPxDroplet'
                        'Restart-DoPxDroplet'
                        'Restore-DoPxBackup'
                        'Restore-DoPxSnapshot'
                        'Set-DoPxDefaultAccessToken'
                        'Start-DoPxDroplet'
                        'Stop-DoPxDroplet'
                        'Update-DoPxKernel'
                        'Wait-DoPxAction'
                        )

             FileList = @(
                        'DoPx.psd1'
                        'DoPx.psm1'
                        'functions\Add-DoPxDomain.ps1'
                        'functions\Add-DoPxDnsRecord.ps1'
                        'functions\Add-DoPxSshKey.ps1'
                        'functions\Clear-DoPxDefaultAccessToken.ps1'
                        'functions\Copy-DoPxBackup.ps1'
                        'functions\Copy-DoPxSnapshot.ps1'
                        'functions\Disable-DoPxDropletOption.ps1'
                        'functions\Enable-DoPxDropletOption.ps1'
                        'functions\Get-DoPxAction.ps1'
                        'functions\Get-DoPxDefaultAccessToken.ps1'
                        'functions\Get-DoPxBackup.ps1'
                        'functions\Get-DoPxDomain.ps1'
                        'functions\Get-DoPxDnsRecord.ps1'
                        'functions\Get-DoPxDroplet.ps1'
                        'functions\Get-DoPxImage.ps1'
                        'functions\Get-DoPxKernel.ps1'
                        'functions\Get-DoPxRegion.ps1'
                        'functions\Get-DoPxSize.ps1'
                        'functions\Get-DoPxSnapshot.ps1'
                        'functions\Get-DoPxSshKey.ps1'
                        'functions\New-DoPxDroplet.ps1'
                        'functions\New-DoPxSnapshot.ps1'
                        'functions\Receive-DoPxAction.ps1'
                        'functions\Remove-DoPxDomain.ps1'
                        'functions\Remove-DoPxDnsRecord.ps1'
                        'functions\Remove-DoPxBackup.ps1'
                        'functions\Remove-DoPxDroplet.ps1'
                        'functions\Remove-DoPxSnapshot.ps1'
                        'functions\Remove-DoPxSshKey.ps1'
                        'functions\Rename-DoPxBackup.ps1'
                        'functions\Rename-DoPxDnsRecord.ps1'
                        'functions\Rename-DoPxDroplet.ps1'
                        'functions\Rename-DoPxSnapshot.ps1'
                        'functions\Rename-DoPxSshKey.ps1'
                        'functions\Reset-DoPxDroplet.ps1'
                        'functions\Resize-DoPxDroplet.ps1'
                        'functions\Restart-DoPxDroplet.ps1'
                        'functions\Restore-DoPxBackup.ps1'
                        'functions\Restore-DoPxSnapshot.ps1'
                        'functions\Set-DoPxDefaultAccessToken.ps1'
                        'functions\Start-DoPxDroplet.ps1'
                        'functions\Stop-DoPxDroplet.ps1'
                        'functions\Update-DoPxKernel.ps1'
                        'functions\Wait-DoPxAction.ps1'
                        'helpers\ConvertTo-DoPxObject.ps1'
                        'helpers\Get-DoPxObject.ps1'
                        'helpers\Get-DoPxWebRequestHeader.ps1'
                        'helpers\Invoke-DoPxObjectAction.ps1'
                        'helpers\Invoke-DoPxWebRequest.ps1'
                        'helpers\New-DoPxObject.ps1'
                        'helpers\Remove-DoPxObject.ps1'
                        'helpers\Set-DoPxObject.ps1'
                        'license\gpl-3.0.txt'
                        )
}