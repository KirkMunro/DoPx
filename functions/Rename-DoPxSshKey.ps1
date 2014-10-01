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
    Rename an ssh key that has been added to your DigitalOcean account.
.DESCRIPTION
    The Rename-DoPxSshKey command renames an ssh key that has been added to your DigitalOcean account.

    You can use Rename-DoPxSshKey command to rename a specific ssh key by passing the ssh key ID to the Id parameter or fingerprint to the Fingerprint parameter.
.INPUTS
    digitalocean.sshkey
.OUTPUTS
    digitalocean.sshkey
.NOTES
    This command sends an HTTP PUT request that includes your access token to a DigitalOcean REST API v2 endpoint. To learn more about the DigitalOcean REST API, consult the DigitalOcean API documentation online at https://developers.digitalocean.com.
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Rename-DoPxSshKey -Id 542108 -NewName Personal

    This command sets the name for the ssh key with id 542108 to "Personal".
.EXAMPLE
    PS C:\> $accessToken = ConvertTo-SecureString -String a91a22c7d3c572306e9d6ebfce5f1f697bd7fe8d910d9497ca0f75de2bb37a32 -AsPlainText -Force
    PS C:\> Set-DoPxDefaultAccessToken -AccessToken $accessToken
    PS C:\> Rename-DoPxSshKey -Fingerprint 0b:87:45:bd:f0:bf:c9:26:fc:79:1c:ea:d2:a3:e5:36 -NewName Personal

    This command sets the name for the ssh key that has the fingerprint '0b:87:45:bd:f0:bf:c9:26:fc:79:1c:ea:d2:a3:e5:36' to "Personal".
.LINK
    Add-DoPxSshKey
.LINK
    Get-DoPxSshKey
.LINK
    Remove-DoPxSshKey
#>
function Rename-DoPxSshKey {
    [CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName='Id')]
    [OutputType('droplet.sshkey')]
    param(
        # The numeric id of the ssh key.
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='Id')]
        [ValidateNotNull()]
        [ValidateRange(1,[System.Int32]::MaxValue)]
        [System.Int32]
        $Id,

        # The fingerprint of the ssh key.
        [Parameter(Position=0, Mandatory=$true, ParameterSetName='Fingerprint')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Fingerprint,

        # The new name of the ssh key.
        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $NewName,

        # The access token for your DigitalOcean account, in secure string format.
        [Parameter()]
        [ValidateNotNull()]
        [System.Security.SecureString]
        $AccessToken,

        # Returns the updated sshkey object to the pipeline. By default, this command does not return anything.
        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )
    process {
        Invoke-Snippet -Name ProxyFunction.Begin -Parameters @{
            CommandName = 'Set-DoPxObject'
            CommandType = 'Function'
            PreProcessScriptBlock = {
                #region Set up the ID properly if a fingerprint is being used in the search.

                if ($PSCmdlet.ParameterSetName -eq 'Fingerprint') {
                    $PSCmdlet.MyInvocation.BoundParameters['Id'] = $Fingerprint
                    $PSCmdlet.MyInvocation.BoundParameters.Remove('Fingerprint') > $null
                }

                #endregion

                #region Replace the NewName bound parameter with a parameter hashtable for the action.

                $PSCmdlet.MyInvocation.BoundParameters['Property'] = @{name=$NewName}
                $PSCmdlet.MyInvocation.BoundParameters.Remove('NewName') > $null

                #endregion

                #region Add additional required parameters to the BoundParameters hashtable.

                $PSCmdlet.MyInvocation.BoundParameters['RelativeUri'] = 'account/keys'

                #endregion
            }
        }
        Invoke-Snippet -Name ProxyFunction.Process.NoPipeline
        Invoke-Snippet -Name ProxyFunction.End
    }
}

Export-ModuleMember -Function Rename-DoPxSshKey