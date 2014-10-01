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