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
    Gets the domains that have been added to your DigitalOcean environment.
.DESCRIPTION
    The Get-DoPxDomain command gets the domains that have been added to your DigitalOcean environment.

    Without the Id parameter, Get-DoPxDomain gets all of the domains that have been added to your DigitalOcean environment. You can also use Get-DoPxDomain command to get specific domains by passing the domain IDs to the Id parameter or fingerprints to the Fingerprint parameter.
.PARAMETER First
    Get only the specified number of domains.
.PARAMETER Skip
    Skip the specified number of domains. If this parameter is used in conjunction with the First parameter, the specified number of domains will be skipped before the paging support starts counting the first domains to return.
.PARAMETER IncludeTotalCount
    Return the total count of domains that will be returned before returning the domains themselves.
.INPUTS
    None
.OUTPUTS
    digitalocean.domain
.NOTES
    This command sends an HTTP GET request that includes your access token to a DigitalOcean REST API v2 endpoint. To learn more about the DigitalOcean REST API, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Get-DoPxDomain

    This command gets all domains that have been added to your DigitalOcean environment.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Get-DoPxDomain -Name example.com

    This command gets the domain with name "example.com" from your DigitalOcean environment.
.LINK
    Add-DoPxDomain
.LINK
    Remove-DoPxDomain
#>
function Get-DoPxDomain {
    [CmdletBinding(SupportsPaging=$true)]
    [OutputType('digitalocean.domain')]
    param(
        # The name of the domain.
        [Parameter(Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $Name,

        # The access token for your DigitalOcean environment, in secure string format.
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
                #region Set up the ID properly if a name is being used in the search.

                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Name')) {
                    $PSCmdlet.MyInvocation.BoundParameters['Id'] = $Name
                    $PSCmdlet.MyInvocation.BoundParameters.Remove('Name') > $null
                }

                #endregion

                #region Add additional required parameters to the BoundParameters hashtable.

                $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'domains'

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

Export-ModuleMember -Function Get-DoPxDomain