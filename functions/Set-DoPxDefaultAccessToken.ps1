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
    Set the access token that will be used by default in other DoPx commands.
.DESCRIPTION
    The Set-DoPxDefaultAccessToken command sets the access token that will be used by default in other DoPx commands.
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    To learn more about the DigitalOcean REST API security, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken

    This command sets the access token that will be used by default in all other DoPx commands.
.LINK
    Clear-DoPxDefaultAccessToken
.LINK
    Get-DoPxDefaultAccessToken
#>
function Set-DoPxDefaultAccessToken {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([System.Void])]
    param(
        # The access token for your DigitalOcean account, in secure string format.
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [System.Security.SecureString]
        $AccessToken,

        # Passes the access token to the pipeline. By default, this command does not generate any output.
        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )
    try {
        #region Store the access token that was provided in the module scope.

        if ($PSCmdlet.ShouldProcess('AccessToken')) {
            $Script:PSDefaultParameterValues['Get-DoPxWebRequestHeader:AccessToken'] = $AccessToken
        }

        #endregion

        #region If PassThru was requested, return the access token to the caller.

        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('PassThru') -and $PassThru) {
            Get-DoPxDefaultAccessToken
        }

        #endregion
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

Export-ModuleMember -Function Set-DoPxDefaultAccessToken