<#############################################################################
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

function Invoke-DoPxWebRequest {
    [CmdletBinding(SupportsShouldProcess=$true, SupportsPaging=$true)]
    [OutputType([System.UInt64])]
    [OutputType([System.Collections.Hashtable])]
    [OutputType('digitalocean.object')]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Uri,
        
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNull()]
        [Microsoft.PowerShell.Commands.WebRequestMethod]
        $Method,
        
        [Parameter(Position=2, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable]
        $Headers,

        [Parameter(Position=3)]
        [ValidateNotNullOrEmpty()]
        [System.Object]
        $Body,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru = $true
    )
    try {
        #region Copy the bound parameters to an invokeWebRequestParameters parameter hashtable, dropping the ShouldProcess and Paging parameters in the process.

        [System.Collections.Hashtable]$invokeWebRequestParameters = $PSCmdlet.MyInvocation.BoundParameters
        foreach ($key in 'WhatIf','Confirm','First','Skip','IncludeTotalCount') {
            if ($invokeWebRequestParameters.ContainsKey($key)) {
                $invokeWebRequestParameters.Remove($key)
            }
        }

        #endregion

        #region Convert the Body to JSON format if it was provided.

        if ($invokeWebRequestParameters.ContainsKey('Body')) {
            $invokeWebRequestParameters.Body = ConvertTo-Json -InputObject $Body -Compress
        }

        #endregion

        #region Remove the PassThru parameter from the pass through parameter list.

        $invokeWebRequestParameters.Remove('PassThru')

        #endregion

        #region If we are sending any data to the server, define the ContentType as JSON.

        if (@('Patch','Put','Post') -contains $Method) {
            $invokeWebRequestParameters['ContentType'] = 'application/json'
        }

        #endregion

        #region Initialize some variables to deal with paging.

        # Even if we're not going to get pages of data back, we still want to act as if we will so that
        # paged result sets are supported for every REST method that is used.

        $objectsReturned = $objectCount = 0
        $page = 1
        $resultData = $null

        #endregion

        $shouldProcessAction = $Method
        if ($invokeWebRequestParameters.ContainsKey('Body')) {
            $shouldProcessAction = "${Method} $($invokeWebRequestParameters.Body -replace '"','''')"
        }
        if ($Method -eq 'Head') {
            #region Send the request to the server and return only the headers to the caller.

            Write-Progress -Activity 'Invoking web request' -Status "Sending ${Method} request to $($invokeWebRequestParameters.Uri)..."
            if ($webResults = Invoke-WebRequest @invokeWebRequestParameters) {
                $webResults.Headers -as [System.Collections.Hashtable]
            }

            #endregion
        } elseif ((@('Get','Options') -contains $Method) -or
                  ($PSCmdlet.ShouldProcess($Uri, $shouldProcessAction))) {
            #region Write the details describing the web request being made to the verbose stream.

            Write-Verbose "Sending HTTP request ""${shouldProcessAction}"" to ""${Uri}""."

            #endregion.

            #region Send the request to the server, pulling results down one page at a time.

            do {
                Write-Progress -Activity 'Invoking web request' -Status "Sending ${Method} request to $($invokeWebRequestParameters.Uri)..."
                if (($webResults = Invoke-WebRequest @invokeWebRequestParameters) -and
                    $webResults.Content) {
                    Write-Progress -Activity 'Invoking web request' -Status "Parsing response from $($invokeWebRequestParameters.Uri)..."
                    if ($resultData = ConvertFrom-Json -InputObject $webResults.Content) {
                        # Identify which property on the data objects contains the actual data
                        $dataPropertyName = Get-Member -InputObject $resultData -MemberType NoteProperty | Where-Object {@('meta','links') -notcontains $_.Name} | Select-Object -ExpandProperty Name
                        if (-not (Get-Member -InputObject $resultData -Name meta -ErrorAction Ignore)) {
                            # If we have a single object, return it to the caller if they requested it.
                            if ($PassThru) {
                                ConvertTo-DoPxObject -InputObject $resultData -Property $dataPropertyName
                            }
                        } else {
                            # Determine how many objects are available across all pages
                            $objectCount = $resultData.meta.total -as [System.UInt64]
                            # If the page count was requested, return it as the first object
                            if ($PSCmdlet.PagingParameters.IncludeTotalCount) {
                                $PSCmdlet.PagingParameters.IncludeTotalCount = $false
                                $objectCount
                            }
                            if ($PassThru) {
                                Write-Progress -Activity 'Invoking web request' -Status "Processing page ${page} of results from $($invokeWebRequestParameters.Uri)..."
                                # Determine how many objects were returned on the current page
                                $pageResultCount = @($resultData.$($dataPropertyName)).Count
                                if ($PSCmdlet.PagingParameters.First -eq 0) {
                                    # If no objects are requested, stop processing immediately
                                    break
                                } elseif ($PSCmdlet.PagingParameters.Skip -ge $pageResultCount) {
                                    # If the current page is being skipped entirely, decrement the skip counter and skip the page
                                    $PSCmdlet.PagingParameters.Skip -= $pageResultCount
                                } else {
                                    $selectObjectParameters = @{}
                                    # Determine how many objects from the current page will be returned
                                    $pageCandidateCount = $pageResultCount - $PSCmdlet.PagingParameters.Skip
                                    if ($PSCmdlet.PagingParameters.First -lt $pageCandidateCount) {
                                        # If we're not returning a everything that isn't skipped, assign the Select-Object -First parameter value and clear the First counter
                                        $selectObjectParameters['First'] = $PSCmdlet.PagingParameters.First
                                        $PSCmdlet.PagingParameters.First = 0
                                    } else {
                                        # Don't use the Select-Object -First parameter, and decrement the First counter
                                        $PSCmdlet.PagingParameters.First -= $pageCandidateCount
                                    }
                                    if ($PSCmdlet.PagingParameters.Skip -gt 0) {
                                        # If we're skipping items, assign the Select-Object -Skip parameter and clear the Skip counter
                                        $selectObjectParameters['Skip'] = $PSCmdlet.PagingParameters.Skip
                                        $PSCmdlet.PagingParameters.Skip = 0
                                    }
                                    if ($selectObjectParameters.Count) {
                                        # If we're selecting partial page content, convert the results and pipe them to Select-Object
                                        ConvertTo-DoPxObject -InputObject $resultData -Property $dataPropertyName | Select-Object @selectObjectParameters
                                    } else {
                                        # Otherwise, just convert the results
                                        ConvertTo-DoPxObject -InputObject $resultData -Property $dataPropertyName
                                    }
                                }
                            } else {
                                break
                            }
                        }
                    }
                    $page++
                }
            } until (($PSCmdlet.PagingParameters.First -eq 0) -or -not ($invokeWebRequestParameters.Uri = & {Set-StrictMode -Version 1; $resultData.links.pages.next}))

            #endregion

            #region Mark the progress as complete.

            Write-Progress -Activity 'Invoking web request' -Status "${Method} request completed." -Completed

            #endregion
        }
    } catch [System.Net.WebException] {
        # If we have an error message in JSON format, convert the JSON format error to plain text
        # and then re-throw the error
        Set-StrictMode -Off
        try {
            $responseStream = $null
            $streamReader = $null
            if ($_.Exception.Response) {
                $responseStream = $_.Exception.Response.GetResponseStream()
                $streamReader = New-Object -TypeName System.IO.StreamReader -ArgumentList $responseStream
                if (($jsonResponse = $streamReader.ReadToEnd()) -and
                    ($errorDetails = ConvertFrom-Json -InputObject $jsonResponse) -and
                    ($errorDetails.message)) {
                    $_.ErrorDetails = "The remote server returned an error: ($($_.Exception.Response.StatusCode)) $($_.Exception.Response.StatusDescription). $($errorDetails.message -replace '([^\.])$','$1.')"
                }
            }
        } finally {
            if ($streamReader) {
                $streamReader.Close()
                $streamReader.Dispose()
            }
            if ($responseStream) {
                $responseStream.Close()
                $responseStream.Dispose()
            }
        }
        $PSCmdlet.ThrowTerminatingError($_)
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}
