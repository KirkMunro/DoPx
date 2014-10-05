<#############################################################################
The DoPx module provides a rich set of commands that extend the automation
capabilities of the Digital Ocean (DO) cloud service. These commands make it
easier to manage your Digital Ocean environment from Windows PowerShell. When
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

<#
.SYNOPSIS
    Removes one or more droplets from your DigitalOcean environment.
.DESCRIPTION
    The Remove-DoPxDroplet command removes one or more droplets from your DigitalOcean environment.
.INPUTS
    digitalocean.droplet
.OUTPUTS
    none
.NOTES
    This command sends an HTTP DELETE request that includes your access token to the DigitalOcean REST API v2 endpoint. To learn more about the DigitalOcean REST API, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Remove-DoPxDroplet -Id 4849480

    This command removes the droplet with id 4849480 from the DigitalOcean environment identified by the access token that is provided.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Get-DoPxDroplet | Remove-DoPxDroplet

    This command removes the all droplets from the DigitalOcean environment identified by the access token that is provided.
.LINK
    Disable-DoPxDropletOption
.LINK
    Enable-DoPxDropletOption
.LINK
    Get-DoPxBackup
.LINK
    Get-DoPxDroplet
.LINK
    Get-DoPxKernel
.LINK
    Get-DoPxSnapshot
.LINK
    New-DoPxDroplet
.LINK
    Rename-DoPxDroplet
.LINK
    Reset-DoPxDroplet
.LINK
    Resize-DoPxDroplet
.LINK
    Restart-DoPxDroplet
.LINK
    Start-DoPxDroplet
.LINK
    Stop-DoPxDroplet
#>
function Remove-DoPxDroplet {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('digitalocean.droplet')]
    param(
        # The numeric id of the droplet.
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateRange(1,[System.Int32]::MaxValue)]
        [System.Int32[]]
        $Id,

        # The access token for your DigitalOcean account, in secure string format.
        [Parameter()]
        [ValidateNotNull()]
        [System.Security.SecureString]
        $AccessToken
    )
    process {
        Invoke-Snippet -Name ProxyFunction.Begin -Parameters @{
            CommandName = 'Remove-DoPxObject'
            CommandType = 'Function'
            PreProcessScriptBlock = {
                #region Add additional required parameters to the BoundParameters hashtable.

                $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'droplets'

                #endregion
            }
        }
        Invoke-Snippet -Name ProxyFunction.Process.NoPipeline
        Invoke-Snippet -Name ProxyFunction.End
    }
}

Export-ModuleMember -Function Remove-DoPxDroplet