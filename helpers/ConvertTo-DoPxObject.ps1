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

function ConvertTo-DoPxObject {
    [CmdletBinding()]
    [OutputType('digitalocean.object')]
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [System.Object]
        $InputObject,

        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Property,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $TypePrefix = 'digitalocean'
    )
    begin {
        try {
            #region Turn down strict mode so that we can use JSON data without validating member existence first.

            Set-StrictMode -Version 1

            #endregion
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    process {
        try {
            foreach ($item in $InputObject) {
                foreach ($propertyItem in $item.$Property) {
                    #region If the property is a PSCustomObject, add type information to it.

                    if ($propertyItem -is [System.Management.Automation.PSCustomObject]) {
                        #region Identify the type name by combining the prefix and the property.

                        $typeName = "${TypePrefix}.$($Property -replace '_|s$')"

                        #endregion

                        #region Convert nested properties as well if they are arrays or of type PSCustomObject.

                        foreach ($member in $propertyItem.PSObject.Properties) {
                            if ($member.TypeNameOfValue -eq 'System.Object[]') {
                                $propertyItem.$($member.Name) = @(ConvertTo-DoPxObject -InputObject $propertyItem -Property $member.Name -TypePrefix $typeName)
                            } else { #if ($property.TypeNameOfValue -eq 'System.Management.Automation.PSCustomObject') {
                                $propertyItem.$($member.Name) = ConvertTo-DoPxObject -InputObject $propertyItem -Property $member.Name -TypePrefix $typeName
                            }
                        }

                        #endregion

                        #region Set the type information that is desired for all PSCustomObjects.

                        $propertyItem.PSTypeNames.Clear()
                        Add-Member -InputObject $propertyItem -TypeName 'digitalocean.object'
                        if (@('digitalocean.backup','digitalocean.snapshot') -contains $typeName) {
                            Add-Member -InputObject $propertyItem -TypeName 'digitalocean.image'
                        }
                        Add-Member -InputObject $propertyItem -TypeName $typeName

                        #endregion
                    }

                    #endregion

                    #region If the property is a string in datetime format, convert it and return it to the caller.

                    if (($propertyItem -is [System.String]) -and
                        ($propertyItem -match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$')) {
                        $propertyItem = $propertyItem -as [System.DateTime]
                    }

                    #endregion

                    #region Return the property value back to the caller.

                    $propertyItem

                    #endregion
                }
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}