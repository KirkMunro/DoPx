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
    Creates a new snapshot for a droplet that is available in your DigitalOcean environment.
.DESCRIPTION
    The New-DoPxSnapshot command creates a new snapshot for a droplet that is available in your DigitalOcean environment.
.INPUTS
    digitalocean.droplet
.OUTPUTS
    digutalocean.action,digitalocean.image
.NOTES
    This command sends an HTTP POST request that includes your access token to a DigitalOcean REST API v2 endpoint. To learn more about the DigitalOcean REST API, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> New-DoPxSnapshot -DropletId 4849480 -Name 'Before kernel upgrade'

    This command creates a new snapshot called "Before kernel upgrade" for the droplet with id 4849480.
.LINK
    Copy-DoPxSnapshot
.LINK
    Get-DoPxSnapshot
.LINK
    Remove-DoPxSnapshot
.LINK
    Rename-DoPxSnapshot
.LINK
    Restore-DoPxSnapshot
#>
function New-DoPxSnapshot {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('digitalocean.action')]
    [OutputType('digitalocean.snapshot')]
    param(
        # The numeric id of the droplet.
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateRange(1,[System.Int32]::MaxValue)]
        [Alias('Id')]
        [System.Int32]
        $DropletId,

        # The name you want to give to the droplet snapshot.
        [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        # The access token for your DigitalOcean account, in secure string format.
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
                #region Move the id from the DropletId parameter to the Id parameter.

                $PSCmdlet.MyInvocation.BoundParameters['Id'] = $DropletId
                $PSCmdlet.MyInvocation.BoundParameters.Remove('DropletId') > $null

                #endregion

                #region Replace the Name bound parameter with a parameter hashtable for the action.

                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Name')) {
                    $PSCmdlet.MyInvocation.BoundParameters['Parameter'] = @{name=$Name}
                    $PSCmdlet.MyInvocation.BoundParameters.Remove('Name') > $null
                }

                #endregion

                #region Add additional required parameters to the BoundParameters hashtable.

                $PSCmdlet.MyInvocation.BoundParameters['Action'] = 'snapshot'
                $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'droplets'

                #endregion
            }
        }
        Invoke-Snippet -Name ProxyFunction.Process.NoPipeline
        Invoke-Snippet -Name ProxyFunction.End
    }
}

Export-ModuleMember -Function New-DoPxSnapshot