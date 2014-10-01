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
    Clears the access token that is being used by default in other DoPx commands from memory.
.DESCRIPTION
    The Clear-DoPxDefaultAccessToken command clears the access token that is being used by default in other DoPx commands from memory.
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    To learn more about the DigitalOcean REST API security, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> Clear-DoPxDefaultAccessToken

    This command clears the access token that is being be used by default in all other DoPx commands. After running this command, you must either explicitly use an access token in other DoPx commands or you must invoke Set-DoPxDefaultAccessToken to set a new default access token.
.LINK
    Get-DoPxDefaultAccessToken
.LINK
    Set-DoPxDefaultAccessToken
#>
function Clear-DoPxDefaultAccessToken {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([System.Void])]
    param()
    try {
        #region If there is an access token stored in the module scope, remove it.

        if ($PSCmdlet.ShouldProcess('AccessToken')) {
            $Script:PSDefaultParameterValues.Remove('Get-DoPxWebRequestHeader:AccessToken')
        }

        #endregion
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

Export-ModuleMember -Function Clear-DoPxDefaultAccessToken