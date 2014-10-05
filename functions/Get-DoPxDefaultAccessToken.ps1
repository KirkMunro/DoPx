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
    Gets the access token that is being used by default in other DoPx commands.
.DESCRIPTION
    The Get-DoPxDefaultAccessToken command gets the access token that is being used by default in other DoPx commands.
.INPUTS
    None
.OUTPUTS
    System.Security.SecureString
.NOTES
    To learn more about the DigitalOcean REST API security, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> Get-DoPxDefaultAccessToken

    This command gets the access token that is being be used by default in all other DoPx commands.
.LINK
    Clear-DoPxDefaultAccessToken
.LINK
    Set-DoPxDefaultAccessToken
#>
function Get-DoPxDefaultAccessToken {
    [CmdletBinding()]
    [OutputType([System.Security.SecureString])]
    param()
    try {
        #region If there is a default access token set for the module, return it.

        $Script:PSDefaultParameterValues['Get-DoPxWebRequestHeader:AccessToken']

        #endregion
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

Export-ModuleMember -Function Get-DoPxDefaultAccessToken