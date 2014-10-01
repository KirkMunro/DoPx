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

<#
.SYNOPSIS
    Copies a backup in your DigitalOcean environment to a different region.
.DESCRIPTION
    The Copy-DoPxBackup command copies a backup in your DigitalOcean environment to a different region.
.INPUTS
    digitalocean.backup
.OUTPUTS
    digitalocean.action,digitalocean.image
.NOTES
    This command sends an HTTP POST request that includes your access token to a DigitalOcean REST API v2 endpoint. To learn more about the DigitalOcean REST API, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Copy-DoPxBackup -Id 7606405 -RegionId nyc3

    This command copies backup id 7606405 to region "nyc3".
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Get-DoPxBackup | Copy-DoPxBackup -RegionId nyc3

    This command copies all backups in your DigitalOcean environment to region "nyc3".
.LINK
    Get-DoPxBackup
.LINK
    Remove-DoPxBackup
.LINK
    Rename-DoPxBackup
.LINK
    Restore-DoPxBackup
#>
function Copy-DoPxBackup {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('digitalocean.action')]
    [OutputType('digitalocean.image')]
    param(
        # The numeric id of one or more backups.
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateRange(1,[System.Int32]::MaxValue)]
        [System.Int32[]]
        $Id,

        # The region to which those backups will be copied.
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $RegionId,

        # The access token for your DigitalOcean environment, in secure string format.
        [Parameter()]
        [ValidateNotNull()]
        [System.Security.SecureString]
        $AccessToken,

        # Waits for the action to complete, and then returns the updated object to the pipeline. By default, this command returns the action to the pipeline.
        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Wait
    )
    process {
        Invoke-Snippet -Name ProxyFunction.Begin -Parameters @{
            CommandName = 'Invoke-DoPxObjectAction'
            CommandType = 'Function'
            PreProcessScriptBlock = {
                #region Replace the RegionId bound parameter with a parameter hashtable for the action.

                $PSCmdlet.MyInvocation.BoundParameters['Parameter'] = @{region=$RegionId}
                $PSCmdlet.MyInvocation.BoundParameters.Remove('RegionId') > $null

                #endregion

                #region Add additional required parameters to the BoundParameters hashtable.

                $PSCmdlet.MyInvocation.BoundParameters['Action'] = 'transfer'
                $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'images'

                #endregion
            }
        }
        Invoke-Snippet -Name ProxyFunction.Process.NoPipeline
        Invoke-Snippet -Name ProxyFunction.End
    }
}

Export-ModuleMember -Function Copy-DoPxBackup