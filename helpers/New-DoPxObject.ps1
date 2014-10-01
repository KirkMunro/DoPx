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

function New-DoPxObject {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('digitalocean.object')]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $RelativeUri,

        [Parameter(Position=1)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $Id,

        [Parameter(Position=2)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $RelatedObjectUri,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias('PropertyValues')]
        [System.Collections.Hashtable]
        $Property,

        [Parameter()]
        [ValidateNotNull()]
        [System.Security.SecureString]
        $AccessToken
    )
    try {
        #region If Id is used without the RelatedObjectUri parameter, raise an error.

        $PSCmdlet.ValidateParameterDependency('Id','RelatedObjectUri')

        #endregion

        #region Add the relative uri with the endpoint prefix.

        $uri = "${script:DigitalOceanEndpointUri}/$($RelativeUri -replace '^/+|/+$')"

        #endregion

        #region Identify the passthru ShouldProcess parameters.

        $shouldProcessParameters = $PSCmdlet.GetBoundShouldProcessParameters()

        #endregion

        #region Prefix the Uri parameters with a slash if not present.

        if (-not $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Id')) {
            $internalId = '' -as [System.String[]]
        } else {
            $internalId = $Id -replace '^([^/])','/$1' -as $Id.GetType()
        }
        if (-not $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('RelatedObjectUri')) {
            $internalRelatedObjectUri = '' -as [System.String]
        } else {
            $internalRelatedObjectUri = $RelatedObjectUri -replace '^([^/])','/$1' -as $RelatedObjectUri.GetType()
        }

        #endregion

        #region Initialize the web request headers.

        $accessTokenParameter = $PSCmdlet.GetSplattableParameters('AccessToken')
        $headers = Get-DoPxWebRequestHeader -Method Post @accessTokenParameter

        #endregion

        foreach ($item in $internalId) {
            #region Construct the Uri according to the parameter values used in this iteration.

            $endpointUri = $uri
            if ($item) {
                $endpointUri += $item
            }
            if ($internalRelatedObjectUri) {
                $endpointUri += $internalRelatedObjectUri
            }

            #endregion

            #region Invoke the web request.

            Invoke-DoPxWebRequest -Uri $endpointUri -Method Post -Headers $headers -Body $Property @shouldProcessParameters

            #endregion
        }
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

Export-ModuleMember -Function New-DoPxObject