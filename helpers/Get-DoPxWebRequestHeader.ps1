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

function Get-DoPxWebRequestHeader {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [System.Security.SecureString]
        $AccessToken
    )
    try {
        #region Get a BSTR pointer to the access token.

        $bstrAccessToken = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($AccessToken)

        #endregion

        #region Create the web request header with the default values that are always passed in.

        $headers = @{
            # Always specify that we want JSON data (even errors should come back as JSON)
            'Accept' = 'application/json'
            # Authorization token
            'Authorization' = "Bearer $([Runtime.InteropServices.Marshal]::PtrToStringAuto($bstrAccessToken))"
        }

        #endregion

        #region Return the headers to the caller.

        $headers

        #endregion
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    } finally {
        #region Free our BSTR pointer.

        if ($bstrAccessToken -ne $null) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstrAccessToken)
        }

        #endregion
    }
}