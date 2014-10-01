﻿<#############################################################################
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

function Invoke-DoPxObjectAction {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('digitalocean.object')]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $RelativeUri,

        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $Id,

        [Parameter(Position=2)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $RelatedObjectUri,

        [Parameter(Position=3)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $RelatedObjectId,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Action,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('ParameterValues')]
        [System.Collections.Hashtable]
        $Parameter = @{},

        [Parameter()]
        [ValidateNotNull()]
        [System.Security.SecureString]
        $AccessToken,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Wait
    )
    try {
        #region If RelatedObjectId is used without the Id parameter, raise an error.

        $PSCmdlet.ValidateParameterDependency('RelatedObjectUri','Id')

        #endregion

        #region If RelatedObjectId is used without the RelatedObjectUri parameter, raise an error.

        $PSCmdlet.ValidateParameterDependency('RelatedObjectId','RelatedObjectUri')

        #endregion

        #region Identify the passthru ShouldProcess parameters.

        $shouldProcessParameters = $PSCmdlet.GetBoundShouldProcessParameters()

        #endregion

        #region Add the relative uri with the endpoint prefix.

        $uri = "${script:DigitalOceanEndpointUri}/$($RelativeUri -replace '^/+|/+$')"

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
        if (-not $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('RelatedObjectId')) {
            $internalRelatedObjectId = '' -as [System.String[]]
        } else {
            $internalRelatedObjectId = $RelatedObjectId -replace '^([^/])','/$1' -as $RelatedObjectId.GetType()
        }

        #endregion

        #region Add a type parameter with the name of the action being invoked.

        $Parameter['type'] = $Action

        #endregion

        #region Get a splattable AccessToken parameter.

        $accessTokenParameter = $PSCmdlet.GetSplattableParameters('AccessToken')

        #endregion

        #region Initialize the web request headers.

        $headers = Get-DoPxWebRequestHeader -Method Put @accessTokenParameter

        #endregion

        #region Define an array that will hold the actions created from our requests.

        $actions = @()

        #endregion

        foreach ($item in $internalId) {
            foreach ($relatedItem in $internalRelatedObjectId) {
                #region Construct the Uri according to the parameter values used in this iteration.

                $endpointUri = $uri
                if ($item) {
                    $endpointUri += $item
                }
                if ($internalRelatedObjectUri) {
                    $endpointUri += "${internalRelatedObjectUri}${relatedItem}"
                }
                $endpointUri += '/actions'

                #endregion

                #region Invoke the web request.

                $actions += Invoke-DoPxWebRequest -Uri $endpointUri -Method Post -Headers $headers -Body $Parameter -PassThru @shouldProcessParameters

                #endregion
            }
        }

        #region If we are not waiting, return the actions to the caller; otherwise, wait.

        if (-not $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Wait') -or -not $Wait) {
            $actions
        } else {
            $actions | Wait-DoPxAction @accessTokenParameter | Receive-DoPxAction @accessTokenParameter
        }

        #endregion
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

Export-ModuleMember -Function Invoke-DoPxObjectAction