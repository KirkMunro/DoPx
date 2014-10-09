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
    Renames a DNS records in your DigitalOcean environment.
.DESCRIPTION
    The Rename-DoPxDnsRecord command renames a DNS records in your DigitalOcean environment.
.INPUTS
    digitalocean.domainrecord
.OUTPUTS
    digitalocean.domainrecord
.NOTES
    This command sends an HTTP PUT request that includes your access token to a DigitalOcean REST API v2 endpoint. To learn more about the DigitalOcean REST API, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Rename-DoPxDnsRecord -DomainName example.com -Id 4536712 -NewName IPv6

    This command sets the name of the DNS record with id 4536712 that was created for the "example.com" domain to "IPv6".
.LINK
    Add-DoPxDnsRecord
.LINK
    Get-DoPxDnsRecord
.LINK
    Remove-DoPxDnsRecord
#>
function Rename-DoPxDnsRecord {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('digitalocean.domainrecord')]
    param(
        # The name of a domain with a DNS record that you want to rename.
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainName,

        # The id of the DNS record you want to rename.
        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateRange(1,[System.Int32]::MaxValue)]
        [System.Int32]
        $Id,

        # The new name that you want to assign to the DNS record.
        [Parameter(Position=2, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $NewName,

        # The access token for your DigitalOcean account, in secure string format.
        [Parameter()]
        [ValidateNotNull()]
        [System.Security.SecureString]
        $AccessToken
    )
    process {
        Invoke-Snippet -Name ProxyFunction.Begin -Parameters @{
            CommandName = 'Set-DoPxObject'
            CommandType = 'Function'
            PreProcessScriptBlock = {
                #region Reorganize the input parameters.

                $PSCmdlet.MyInvocation.BoundParameters['RelatedObjectId'] = $Id
                $PSCmdlet.MyInvocation.BoundParameters['Id'] = $DomainName
                $PSCmdlet.MyInvocation.BoundParameters['Property'] = @{name=$NewName}
                $PSCmdlet.MyInvocation.BoundParameters.Remove('DomainName') > $null
                $PSCmdlet.MyInvocation.BoundParameters.Remove('NewName') > $null

                #endregion

                #region Add additional required parameters to the BoundParameters hashtable.

                $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'domains'
                $PSCmdlet.MyInvocation.BoundParameters['RelatedObjectUri'] = 'records'

                #endregion
            }
        }
        Invoke-Snippet -Name ProxyFunction.Process.NoPipeline
        Invoke-Snippet -Name ProxyFunction.End
    }
}

Export-ModuleMember -Function Rename-DoPxDnsRecord