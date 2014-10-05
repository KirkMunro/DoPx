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
    Creates a new DNS record in your DigitalOcean environment.
.DESCRIPTION
    The Add-DoPxDnsRecord command creates a new DNS record in your DigitalOcean environment.

    You can create A, AAAA, CNAME, MX, TXT, SRV, and NS records with this command. Select the appropriate switch to identify the type of record that you want to create.
.INPUTS
    None
.OUTPUTS
    digitalocean.domainrecord
.NOTES
    This command sends an HTTP POST request that includes your access token to a DigitalOcean REST API v2 endpoint. To learn more about the DigitalOcean REST API, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Add-DoPxDnsRecord -DomainName example.com -A -HostName subdomain -IPv4Address 127.0.0.1

    This command creates a new A record for domain example.com, with the subdomain "subdomain" routed to IP address 127.0.0.1.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Add-DoPxDnsRecord -DomainName example.com -AAAA -HostName subdomain -IPv6Address 2001:db8::ff00:42:8329

    This command creates a new AAAA record for domain example.com, with the subdomain "subdomain" routed to IP address 2001:db8::ff00:42:8329.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Add-DoPxDnsRecord -DomainName example.com -CNAME -AliasName newalias -HostName hosttarget

    This command creates a new CNAME record for domain example.com, with the "newalias" alias routed to host "hosttarget".
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Add-DoPxDnsRecord -DomainName example.com -MX -HostName 127.0.0.1 -Priority 5

    This command creates a new MX record for domain example.com, routing mail traffic to host 127.0.0.1 with a priority of 5.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Add-DoPxDnsRecord -DomainName example.com -TXT -RecordName recordname -Message 'arbitrary data here'

    This command creates a new TXT record for domain example.com, with the record named "recordname" containing the message "arbitrary data here".
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Add-DoPxDnsRecord -DomainName example.com -SRV -ServiceName servicename -HostName targethost -Priority 0 -Port 1 -Weight 2

    This command creates a new SRV record for domain example.com, directing service requests for service "servicename" to host "targethost" on port 1 with a priority of 0 and a weight of 2.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Add-DoPxDnsRecord -DomainName example.com -NS -NameServer ns1.digitalocean.com

    This command creates a new NS record for domain example.com, identifying name server ns1.digitalocean.com as authoritative for the domain.
.LINK
    Get-DoPxDomain
.LINK
    Get-DoPxDnsRecord
.LINK
    Remove-DoPxDnsRecord
.LINK
    Rename-DoPxDnsRecord
#>
function Add-DoPxDnsRecord {
    [CmdletBinding(SupportsShouldProcess=$true, DefaultParameterSetName='A')]
    [OutputType('digitalocean.domainrecord')]
    param(
        # The name of the domain to which this DNS record will be added.
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Name')]
        [System.String]
        $DomainName,

        # Creates an A record.
        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='A')]
        [ValidateNotNull()]
        [ValidateScript({
            if (-not $_.IsPresent) {
                throw 'Passing false into the A parameter is not supported.'
            }
            $true
        })]
        [System.Management.Automation.SwitchParameter]
        $A,

        # Creates an AAAA record.
        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='AAAA')]
        [ValidateNotNull()]
        [ValidateScript({
            if (-not $_.IsPresent) {
                throw 'Passing false into the AAAA parameter is not supported.'
            }
            $true
        })]
        [System.Management.Automation.SwitchParameter]
        $AAAA,

        # Creates a CNAME record.
        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='CNAME')]
        [ValidateNotNull()]
        [ValidateScript({
            if (-not $_.IsPresent) {
                throw 'Passing false into the CNAME parameter is not supported.'
            }
            $true
        })]
        [System.Management.Automation.SwitchParameter]
        $CNAME,

        # Creates a MX record.
        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='MX')]
        [ValidateNotNull()]
        [ValidateScript({
            if (-not $_.IsPresent) {
                throw 'Passing false into the MX parameter is not supported.'
            }
            $true
        })]
        [System.Management.Automation.SwitchParameter]
        $MX,

        # Creates a TXT record.
        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='TXT')]
        [ValidateNotNull()]
        [ValidateScript({
            if (-not $_.IsPresent) {
                throw 'Passing false into the TXT parameter is not supported.'
            }
            $true
        })]
        [System.Management.Automation.SwitchParameter]
        $TXT,

        # Creates a SRV record.
        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='SRV')]
        [ValidateNotNull()]
        [ValidateScript({
            if (-not $_.IsPresent) {
                throw 'Passing false into the SRV parameter is not supported.'
            }
            $true
        })]
        [System.Management.Automation.SwitchParameter]
        $SRV,

        # Creates a NS record.
        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='NS')]
        [ValidateNotNull()]
        [ValidateScript({
            if (-not $_.IsPresent) {
                throw 'Passing false into the NS parameter is not supported.'
            }
            $true
        })]
        [System.Management.Automation.SwitchParameter]
        $NS,

        # The name of the new alias.
        [Parameter(Position=2, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='CNAME')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $AliasName,

        # The name of the record.
        [Parameter(Position=2, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='TXT')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $RecordName,

        # The name for the service being configured.
        [Parameter(Position=2, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='SRV')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServiceName,

        # This parameter has different meanings for different DNS record types, as follows:
        #
        # -- A: The host name, or subdomain, to configure.
        #
        # -- AAAA: The host name, or subdomain, to configure.
        #
        # -- CNAME: The host name that will be given to clients requesting the alias.
        #
        # -- MX: The host name or IP address that mail should be routed to.
        #
        # -- SRV: The host name to direct requests for the service to.
        [Parameter(Position=2, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='A')]
        [Parameter(Position=2, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='AAAA')]
        [Parameter(Position=3, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='CNAME')]
        [Parameter(Position=3, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='MX')]
        [Parameter(Position=3, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='SRV')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $HostName,

        # The IPv4 IP address to route requests to.
        [Parameter(Position=3, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='A')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $IPv4Address,

        # The IPv6 IP address to route requests to.
        [Parameter(Position=3, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='AAAA')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $IPv6Address,

        # The arbitrary text message.
        [Parameter(Position=3, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='TXT')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        # The name of a name server that is authoritative for the domain.
        [Parameter(Position=3, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='NS')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $NameServer,

        # The priority of the target host. Lower values have higher priority. Valid priorities are numbers between 0 and 65535.
        [Parameter(Position=4, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='MX')]
        [Parameter(Position=4, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='SRV')]
        [ValidateNotNull()]
        [ValidateRange(0,65535)]
        [System.Int32]
        $Priority,

        # The port where the service is found on the target host. A valid port is an number between 1 and 65535.
        [Parameter(Position=5, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='SRV')]
        [ValidateNotNull()]
        [ValidateRange(1,65535)]
        [System.Int32]
        $Port,

        # The relative weight of targets for the service that have the same priority. A larger value has a higher priority. Valid weights are between 0 and 65535.
        [Parameter(Position=6, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='SRV')]
        [ValidateNotNull()]
        [ValidateRange(0,65535)]
        [System.Int32]
        $Weight,

        # The access token for your DigitalOcean environment, in secure string format.
        [Parameter()]
        [ValidateNotNull()]
        [System.Security.SecureString]
        $AccessToken
    )
    process {
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'A' {
                    Invoke-Snippet -Name ProxyFunction.Begin -Parameters @{
                        CommandName = 'New-DoPxObject'
                        CommandType = 'Function'
                        PreProcessScriptBlock = {
                            #region Identify the endpoint that is used when creating a DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'domains'
                            $PSCmdlet.MyInvocation.BoundParameters['Id'] = $DomainName
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('DomainName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters['RelatedObjectUri'] = 'records'

                            #endregion

                            #region Identify the properties that will be assigned to the new DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['Property'] = @{
                                type = 'A'
                                name = $HostName
                                data = $IPv4Address
                            }
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('A') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('HostName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('IPv4Address') > $null

                            #endregion
                        }
                    }
                    break
                }
                'AAAA' {
                    Invoke-Snippet -Name ProxyFunction.Begin -Parameters @{
                        CommandName = 'New-DoPxObject'
                        CommandType = 'Function'
                        PreProcessScriptBlock = {
                            #region Identify the endpoint that is used when creating a DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'domains'
                            $PSCmdlet.MyInvocation.BoundParameters['Id'] = $DomainName
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('DomainName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters['RelatedObjectUri'] = 'records'

                            #endregion

                            #region Identify the properties that will be assigned to the new DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['Property'] = @{
                                type = 'AAAA'
                                name = $HostName
                                data = $IPv6Address
                            }
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('AAAA') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('HostName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('IPv6Address') > $null

                            #endregion
                        }
                    }
                    break
                }
                'CNAME' {
                    Invoke-Snippet -Name ProxyFunction.Begin -Parameters @{
                        CommandName = 'New-DoPxObject'
                        CommandType = 'Function'
                        PreProcessScriptBlock = {
                            #region Identify the endpoint that is used when creating a DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'domains'
                            $PSCmdlet.MyInvocation.BoundParameters['Id'] = $DomainName
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('DomainName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters['RelatedObjectUri'] = 'records'

                            #endregion

                            #region Identify the properties that will be assigned to the new DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['Property'] = @{
                                type = 'CNAME'
                                name = $AliasName
                                data = $HostName
                            }
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('CNAME') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('AliasName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('HostName') > $null

                            #endregion
                        }
                    }
                    break
                }
                'MX' {
                    Invoke-Snippet -Name ProxyFunction.Begin -Parameters @{
                        CommandName = 'New-DoPxObject'
                        CommandType = 'Function'
                        PreProcessScriptBlock = {
                            #region Identify the endpoint that is used when creating a DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'domains'
                            $PSCmdlet.MyInvocation.BoundParameters['Id'] = $DomainName
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('DomainName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters['RelatedObjectUri'] = 'records'

                            #endregion

                            #region Identify the properties that will be assigned to the new DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['Property'] = @{
                                    type = 'MX'
                                    data = $HostName
                                priority = $Priority
                            }
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('MX') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('HostName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('Priority') > $null

                            #endregion
                        }
                    }
                    break
                }
                'TXT' {
                    Invoke-Snippet -Name ProxyFunction.Begin -Parameters @{
                        CommandName = 'New-DoPxObject'
                        CommandType = 'Function'
                        PreProcessScriptBlock = {
                            #region Identify the endpoint that is used when creating a DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'domains'
                            $PSCmdlet.MyInvocation.BoundParameters['Id'] = $DomainName
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('DomainName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters['RelatedObjectUri'] = 'records'

                            #endregion

                            #region Identify the properties that will be assigned to the new DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['Property'] = @{
                                type = 'TXT'
                                name = $RecordName
                                data = $Message
                            }
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('TXT') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('RecordName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('Message') > $null

                            #endregion
                        }
                    }
                    break
                }
                'SRV' {
                    Invoke-Snippet -Name ProxyFunction.Begin -Parameters @{
                        CommandName = 'New-DoPxObject'
                        CommandType = 'Function'
                        PreProcessScriptBlock = {
                            #region Identify the endpoint that is used when creating a DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'domains'
                            $PSCmdlet.MyInvocation.BoundParameters['Id'] = $DomainName
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('DomainName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters['RelatedObjectUri'] = 'records'

                            #endregion

                            #region Identify the properties that will be assigned to the new DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['Property'] = @{
                                    type = 'SRV'
                                    name = $ServiceName
                                    data = $HostName
                                    port = $Port
                                priority = $Priority
                                  weight = $Weight
                            }
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('SRV') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('ServiceName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('HostName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('Port') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('Priority') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('Weight') > $null

                            #endregion
                        }
                    }
                    break
                }
                'NS' {
                    Invoke-Snippet -Name ProxyFunction.Begin -Parameters @{
                        CommandName = 'New-DoPxObject'
                        CommandType = 'Function'
                        PreProcessScriptBlock = {
                            #region Identify the endpoint that is used when creating a DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'domains'
                            $PSCmdlet.MyInvocation.BoundParameters['Id'] = $DomainName
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('DomainName') > $null
                            $PSCmdlet.MyInvocation.BoundParameters['RelatedObjectUri'] = 'records'

                            #endregion

                            #region Identify the properties that will be assigned to the new DNS record.

                            $PSCmdlet.MyInvocation.BoundParameters['Property'] = @{
                                type = 'NS'
                                data = $NameServer -replace '([^\.])$','$1.'
                            }
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('NS') > $null
                            $PSCmdlet.MyInvocation.BoundParameters.Remove('NameServer') > $null

                            #endregion
                        }
                    }
                    break
                }
            }
            Invoke-Snippet -Name ProxyFunction.Process.NoPipeline
            Invoke-Snippet -Name ProxyFunction.End
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}

Export-ModuleMember -Function Add-DoPxDnsRecord