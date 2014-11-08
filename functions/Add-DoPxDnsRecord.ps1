<#############################################################################
The DoPx module provides a rich set of commands that extend the automation
capabilities of the DigitalOcean (DO) cloud service. These commands make it
easier to manage your DigitalOcean environment from Windows PowerShell. When
used with the LinuxPx module, you can manage your entire DigitalOcean
environment from one shell.

Copyright 2014 Kirk Munro

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
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
# SIG # Begin signature block
# MIIZIAYJKoZIhvcNAQcCoIIZETCCGQ0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUngzjPnY3hblwOxA2AZc0kdsZ
# ne+gghRWMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggUSMIID+qADAgECAhAN//fSWE4vjemplVn1wnAjMA0GCSqGSIb3DQEBBQUAMG8x
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xLjAsBgNVBAMTJURpZ2lDZXJ0IEFzc3VyZWQgSUQgQ29k
# ZSBTaWduaW5nIENBLTEwHhcNMTQxMDAzMDAwMDAwWhcNMTUxMDA3MTIwMDAwWjBo
# MQswCQYDVQQGEwJDQTEQMA4GA1UECBMHT250YXJpbzEPMA0GA1UEBxMGT3R0YXdh
# MRowGAYDVQQKExFLaXJrIEFuZHJldyBNdW5ybzEaMBgGA1UEAxMRS2lyayBBbmRy
# ZXcgTXVucm8wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDIANwog4/2
# JUJCJ1PKeXu8S+eBp1F8fHaVFVgMToGhyNz+UptqDVBIsOu21AXNd4s/3WqhOnOt
# yBvyn5thWNGCMB/XcX6/SdV8lSyg0swreiiR7ksJc1jK75aDJV2UE/mOiMtcWo01
# SQGddbF4FpK3LxbzjKGMPP7uI1TUFTxmdR8t8HaRlI7KcsZkckGffkboAm5CWDhZ
# d4f9YhVzZ8uV0jAN9i+mtmIOHTMMskQ7tZy17GkgyjiGrnMxy6VZ18hya062ZLcV
# 20LUqsUkjr0oNvf54KrhZrPQhULagcpKwmxw3hzDfvWov4yVLWdgWT6a+TUG8D39
# HUuVCpXG+OgZAgMBAAGjggGvMIIBqzAfBgNVHSMEGDAWgBR7aM4pqsAXvkl64eU/
# 1qf3RY81MjAdBgNVHQ4EFgQUG+clmaBur2rhO4i38pTJHCFSya0wDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMG0GA1UdHwRmMGQwMKAuoCyGKmh0
# dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9hc3N1cmVkLWNzLWcxLmNybDAwoC6gLIYq
# aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL2Fzc3VyZWQtY3MtZzEuY3JsMEIGA1Ud
# IAQ7MDkwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRp
# Z2ljZXJ0LmNvbS9DUFMwgYIGCCsGAQUFBwEBBHYwdDAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMEwGCCsGAQUFBzAChkBodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURDb2RlU2lnbmluZ0NBLTEu
# Y3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQEFBQADggEBACJI6tx95+XcEC6X
# EAxbRZjIXJ085IDdqWXImnfQ8To+yAeHM5kP506ddtzlztW9esOxqnhnfIAClB1e
# 1f/FAlgpxrEQ2IRCuUHuMfy4AxqRkD9jePVZ7NYKcKxJZ87iu32iuGT+phFip+ZP
# O9GkqDYkvzQmB74b7hQ3knn6qFLqUZ8njpSceIeC8PHINZmSx+v+KVkEavN/z0hF
# T9xYR2VPPjIIk3MnwtkyHhTWWxNoKGCg+BZV2mApwR9EsWJHVpiGru6DNfNwSQpB
# oIvMGOOL919XgE4J1B022xnAcnCCxoGjjSmBPb1TWemijGsGD2Je8/EALw9geBB9
# vbJvwn8wggajMIIFi6ADAgECAhAPqEkGFdcAoL4hdv3F7G29MA0GCSqGSIb3DQEB
# BQUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQg
# SUQgUm9vdCBDQTAeFw0xMTAyMTExMjAwMDBaFw0yNjAyMTAxMjAwMDBaMG8xCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xLjAsBgNVBAMTJURpZ2lDZXJ0IEFzc3VyZWQgSUQgQ29kZSBT
# aWduaW5nIENBLTEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCcfPmg
# jwrKiUtTmjzsGSJ/DMv3SETQPyJumk/6zt/G0ySR/6hSk+dy+PFGhpTFqxf0eH/L
# er6QJhx8Uy/lg+e7agUozKAXEUsYIPO3vfLcy7iGQEUfT/k5mNM7629ppFwBLrFm
# 6aa43Abero1i/kQngqkDw/7mJguTSXHlOG1O/oBcZ3e11W9mZJRru4hJaNjR9H4h
# webFHsnglrgJlflLnq7MMb1qWkKnxAVHfWAr2aFdvftWk+8b/HL53z4y/d0qLDJG
# 2l5jvNC4y0wQNfxQX6xDRHz+hERQtIwqPXQM9HqLckvgVrUTtmPpP05JI+cGFvAl
# qwH4KEHmx9RkO12rAgMBAAGjggNDMIIDPzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0l
# BAwwCgYIKwYBBQUHAwMwggHDBgNVHSAEggG6MIIBtjCCAbIGCGCGSAGG/WwDMIIB
# pDA6BggrBgEFBQcCARYuaHR0cDovL3d3dy5kaWdpY2VydC5jb20vc3NsLWNwcy1y
# ZXBvc2l0b3J5Lmh0bTCCAWQGCCsGAQUFBwICMIIBVh6CAVIAQQBuAHkAIAB1AHMA
# ZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0AGkAZgBpAGMAYQB0AGUAIABjAG8A
# bgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBlAHAAdABhAG4AYwBlACAAbwBmACAA
# dABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABDAFAALwBDAFAAUwAgAGEAbgBkACAA
# dABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABhAHIAdAB5ACAAQQBnAHIAZQBlAG0A
# ZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBpAHQAIABsAGkAYQBiAGkAbABpAHQA
# eQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBvAHIAcABvAHIAYQB0AGUAZAAgAGgA
# ZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQByAGUAbgBjAGUALjASBgNVHRMBAf8E
# CDAGAQH/AgEAMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8EejB4
# MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVk
# SURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGln
# aUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMB0GA1UdDgQWBBR7aM4pqsAXvkl64eU/
# 1qf3RY81MjAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzANBgkqhkiG
# 9w0BAQUFAAOCAQEAe3IdZP+IyDrBt+nnqcSHu9uUkteQWTP6K4feqFuAJT8Tj5uD
# G3xDxOaM3zk+wxXssNo7ISV7JMFyXbhHkYETRvqcP2pRON60Jcvwq9/FKAFUeRBG
# JNE4DyahYZBNur0o5j/xxKqb9to1U0/J8j3TbNwj7aqgTWcJ8zqAPTz7NkyQ53ak
# 3fI6v1Y1L6JMZejg1NrRx8iRai0jTzc7GZQY1NWcEDzVsRwZ/4/Ia5ue+K6cmZZ4
# 0c2cURVbQiZyWo0KSiOSQOiG3iLCkzrUm2im3yl/Brk8Dr2fxIacgkdCcTKGCZly
# CXlLnXFp9UH/fzl3ZPGEjb6LHrJ9aKOlkLEM/zGCBDQwggQwAgEBMIGDMG8xCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xLjAsBgNVBAMTJURpZ2lDZXJ0IEFzc3VyZWQgSUQgQ29kZSBT
# aWduaW5nIENBLTECEA3/99JYTi+N6amVWfXCcCMwCQYFKw4DAhoFAKB4MBgGCisG
# AQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFNn+
# 3g4SNPXIHXX0hqJRlLzdnOWcMA0GCSqGSIb3DQEBAQUABIIBAMcZdqipnHZLQDWa
# QicdiY8amey5XdfnALLsSVfBCQA6kX6p2UmT+YLs1gXR7z0ihrWGp1Y7wG26dlo5
# 8b7KpIQ1U0Y22UNvEoMNGxINxSaPDxa1S7NRbfy3AsyvjIuRORGL/sNkekzVYAd6
# ov2NpRTRvt4N0m54J53vm1kAGKG/Gqg7sDNqw1lcubjs+7EC9zkW7UkaciiFC+c4
# u/K3hPVX7n4LPuszkZFAXae+bRPJqhPfRO6ckZNZ/2nghBF3tDyUZfdDIATEL8Z5
# KeFye+Z2QT+TGY4PSCOPOyYGZO3z24IcOEQ0VunkH2tjwIiuOlkJy3tbvEy+y69F
# 3/rIwNWhggILMIICBwYJKoZIhvcNAQkGMYIB+DCCAfQCAQEwcjBeMQswCQYDVQQG
# EwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5
# bWFudGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMgIQDs/0OMj+vzVu
# BNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAc
# BgkqhkiG9w0BCQUxDxcNMTQxMTA4MjMzMzIyWjAjBgkqhkiG9w0BCQQxFgQUbGP3
# GCGBtPn9CA8rCg4L57tw6K0wDQYJKoZIhvcNAQEBBQAEggEAZmP5KK/7/WTz78eP
# NrQSViJ1ejumVGISKcSpHwiNhdJn8C35AI2v5V5x/gnFiuclt7mlSIF6r4Rg5bt+
# edQByuF5tqrHtvlgu5hHXENojbaFSFXpiC3gzeKJSXMs/wYzt0R0xcA3oLnLiGDT
# sP72JYVmfsmm95nZa7e0tngc2PmAHl9MP9h+R1shpvJNleCruxDjuTNU+TXq5jwi
# y6Qn6Is0GvSvLsyLXB9e42kQWtFQ5JPxIh43j9MVQI2vh3+etq2lHL8kCHspa/ae
# DYKVqWqtJBpTYStGFWUi7RuWZEhtdiMJkn/ZPP/EB+DulGcnafNlMaWbjwacydGe
# OQAQ3A==
# SIG # End signature block
