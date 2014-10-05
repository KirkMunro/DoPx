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
    Adds an ssh key to your DigitalOcean account.
.DESCRIPTION
    The Add-DoPxSshKey command adds an ssh keys to your DigitalOcean account.
.INPUTS
    None
.OUTPUTS
    digitalocean.sshkey
.NOTES
    This command sends an HTTP POST request that includes your access token to a DigitalOcean REST API v2 endpoint. To learn more about the DigitalOcean REST API, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Add-DoPxSshKey -Name RailsKey -PublicKey $publicKey

    This command adds an ssh key named RailsKey that is identified by $publicKey to your DigitalOcean account.
.LINK
    Get-DoPxSshKey
.LINK
    Rename-DoPxSshKey
.LINK
    Remove-DoPxSshKey
#>
function Add-DoPxSshKey {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('digitalocean.sshkey')]
    param(
        # The name of the ssh key.
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        # The public key.
        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $PublicKey,

        # The access token for your DigitalOcean account, in secure string format.
        [Parameter()]
        [ValidateNotNull()]
        [System.Security.SecureString]
        $AccessToken
    )
    process {
        Invoke-Snippet -Name ProxyFunction.Begin -Parameters @{
            CommandName = 'New-DoPxObject'
            CommandType = 'Function'
            PreProcessScriptBlock = {
                #region Identify the endpoint that is used when adding an ssh key.

                $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'account/keys'

                #endregion

                #region Identify the properties that will be assigned to the ssh key you are adding.

                $PSCmdlet.MyInvocation.BoundParameters['Property'] = @{
                          name = $Name
                    public_key = $PublicKey
                }
                $PSCmdlet.MyInvocation.BoundParameters.Remove('Name') > $null
                $PSCmdlet.MyInvocation.BoundParameters.Remove('PublicKey') > $null

                #endregion
            }
        }
        Invoke-Snippet -Name ProxyFunction.Process.NoPipeline
        Invoke-Snippet -Name ProxyFunction.End
    }
}

Export-ModuleMember -Function Add-DoPxSshKey