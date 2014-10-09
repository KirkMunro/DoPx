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

<#
.SYNOPSIS
    Waits for one or more DigitalOcean actions to complete.
.DESCRIPTION
    The Wait-DoPxAction command waits for one or more DigitalOcean actions to complete.
.INPUTS
    digitalocean.action
.OUTPUTS
    digitalocean.action
.NOTES
    This command sends an HTTP GET request that includes your access token to the DigitalOcean REST API v2 endpoint. To learn more about the DigitalOcean REST API, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Wait-DoPxAction -Id 51666486

    This command waits for the action with id 51666486 to finish running.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Get-DoPxAction -Id 51666486 | Wait-DoPxAction

    This command gets the action with id 51666486 from your DigitalOcean environment and waits until that action has finished running.
.LINK
    Get-DoPxAction
.LINK
    Receive-DoPxAction
#>
function Wait-DoPxAction {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('digitalocean.action')]
    param(
        # The numeric id of the action.
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateRange(1,[System.Int32]::MaxValue)]
        [System.Int32[]]
        $Id,

        # The access token for your DigitalOcean account, in secure string format.
        [Parameter()]
        [ValidateNotNull()]
        [System.Security.SecureString]
        $AccessToken
    )
    begin {
        try {
            #region Get a splattable AccessToken parameter.

            $accessTokenParameter = $PSCmdlet.GetSplattableParameters('AccessToken')

            #endregion

            #region Create an array to store the actions we are waiting for.

            $actions = @()

            #endregion
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    process {
        try {
            #region Get the current state of the action.

            if ($_.PSTypeNames -contains 'digitalocean.action') {
                $actions += $_
            } else {
                $actions += Get-DoPxAction -Id $Id @accessTokenParameter
            }

            #endregion
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    end {
        try {
            #region Wait until the actions have finished running.

            $completedActionIds = @()
            do {
                # Sleep for 500 milliseconds between checks
                Start-Sleep -Milliseconds 500
                for ($index = 0; $index -lt $actions.Count; $index++) {
                    # Get the current action
                    $action = $actions[$index]
                    # If this action already completed and was processed, skip it
                    if ($completedActionIds -contains $action.id) {
                        continue
                    }
                    # If this action has completed, process it
                    if ($action.completed_at -ne $null) {
                        # Add the action id to the list of completed actions that were processed
                        $completedActionIds += $action.id
                        # Return the action once it completes successfully
                        $action
                        # Now process the next action
                        continue
                    }
                    # Refresh the actions that are not processed and that have not completed yet
                    $actions[$index] = $action = Get-DoPxAction -Id $action.id @accessTokenParameter
                }
            } while ($completedActionIds.Count -lt $actions.Count)

            #endregion
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}

Export-ModuleMember -Function Wait-DoPxAction