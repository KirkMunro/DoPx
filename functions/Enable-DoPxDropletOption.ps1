﻿<#############################################################################
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
    Enables IPv6 or private networking on a droplet in your DigitalOcean environment.
.DESCRIPTION
    The Enable-DoPxDropletOption command enables IPv6 or private networking on a droplet in your DigitalOcean environment.
.INPUTS
    digitalocean.droplet
.OUTPUTS
    digutalocean.action,digitalocean.droplet
.NOTES
    This command sends an HTTP POST request that includes your access token to a DigitalOcean REST API v2 endpoint. To learn more about the DigitalOcean REST API, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Enable-DoPxDropletOption -DropletId 4849480 -IPv6

    This command enables IPv6 on the droplet with id 4849480.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Enable-DoPxDropletOption -DropletId 4849480 -PrivateNetworking

    This command enables private networking on the droplet with id 4849480.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Get-DoPxDroplet | Enable-DoPxDropletOption -IPv6

    This command enables automatic backup on all droplets in your DigitalOcean environment.
.LINK
    Disable-DoPxDropletOption
.LINK
    Get-DoPxDroplet
#>
function Enable-DoPxDropletOption {
    [CmdletBinding(SupportsShouldProcess=$true, DefaultParameterSetName='IPv6')]
    [OutputType('digitalocean.action')]
    [OutputType('digitalocean.droplet')]
    param(
        # The numeric id of one or more droplets with options that you want to enable.
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateRange(1,[System.Int32]::MaxValue)]
        [Alias('Id')]
        [System.Int32[]]
        $DropletId,

        # Enables IPv6 on the droplet.
        [Parameter(Mandatory=$true, ParameterSetName='IPv6')]
        [ValidateScript({
            if (-not $_.IsPresent) {
                throw 'Passing false into the IPv6 parameter is not supported.'
            }
            $true
        })]
        [System.Management.Automation.SwitchParameter]
        $IPv6,

        # Enables private networking on the droplet.
        [Parameter(Mandatory=$true, ParameterSetName='PrivateNetworking')]
        [ValidateScript({
            if (-not $_.IsPresent) {
                throw 'Passing false into the PrivateNetworking parameter is not supported.'
            }
            $true
        })]
        [System.Management.Automation.SwitchParameter]
        $PrivateNetworking,

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
                #region Replace the DropletId parameter with the Id parameter.

                $PSCmdlet.MyInvocation.BoundParameters['Id'] = $DropletId
                $PSCmdlet.MyInvocation.BoundParameters.Remove('DropletId') > $null

                #endregion

                #region Add additional required parameters to the BoundParameters hashtable.

                if ($PSCmdlet.ParameterSetName -eq 'IPv6') {
                    $PSCmdlet.MyInvocation.BoundParameters['Action'] = 'enable_ipv6'
                } else {
                    $PSCmdlet.MyInvocation.BoundParameters['Action'] = 'enable_private_networking'
                }
                $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'droplets'

                #endregion
            }
        }
        Invoke-Snippet -Name ProxyFunction.Process.NoPipeline
        Invoke-Snippet -Name ProxyFunction.End
    }
}

Export-ModuleMember -Function Enable-DoPxDropletOption