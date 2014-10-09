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

<#
.SYNOPSIS
    Gets the droplets that are available in your DigitalOcean environment.
.DESCRIPTION
    The Get-DoPxDroplet command gets the droplets that are available in your DigitalOcean environment.

    Without the Id parameter, Get-DoPxDroplet gets all of the droplets that are available in your DigitalOcean environment. You can also use Get-DoPxDroplet command to get specific droplets by passing the droplet IDs to the Id parameter.
.PARAMETER First
    Get only the specified number of droplets.
.PARAMETER Skip
    Skip the specified number of droplets. If this parameter is used in conjunction with the First parameter, the specified number of droplets will be skipped before the paging support starts counting the first droplets to return.
.PARAMETER IncludeTotalCount
    Return the total count of droplets that will be returned before returning the droplets themselves.
.INPUTS
    None
.OUTPUTS
    digitalocean.droplet
.NOTES
    This command sends an HTTP GET request that includes your access token to a DigitalOcean REST API v2 endpoint. To learn more about the DigitalOcean REST API, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Get-DoPxDroplet

    This command gets all droplets from the DigitalOcean account identified by the access token that is provided.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Get-DoPxDroplet -Id 4849480

    This command gets the droplet with id 4849480 from the DigitalOcean account identified by the access token that is provided.
.LINK
    Disable-DoPxDropletOption
.LINK
    Enable-DoPxDropletOption
.LINK
    Get-DoPxBackup
.LINK
    Get-DoPxKernel
.LINK
    Get-DoPxSnapshot
.LINK
    New-DoPxDroplet
.LINK
    Remove-DoPxDroplet
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
function Get-DoPxDroplet {
    [CmdletBinding(SupportsPaging=$true)]
    [OutputType('digitalocean.droplet')]
    param(
        # The numeric id of the droplet.
        [Parameter(Position=0)]
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
    begin {
        Invoke-Snippet -Name ProxyFunction.Begin -Parameters @{
            CommandName = 'Get-DoPxObject'
            CommandType = 'Function'
            PreProcessScriptBlock = {
                #region Add additional required parameters to the BoundParameters hashtable.

                $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'droplets'

                #endregion
            }
        }
    }
    process {
        Invoke-Snippet -Name ProxyFunction.Process.NoPipeline
    }
    end {
        Invoke-Snippet -Name ProxyFunction.End
    }
}

Export-ModuleMember -Function Get-DoPxDroplet