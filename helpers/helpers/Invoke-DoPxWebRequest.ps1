﻿<#############################################################################
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

# SIG # Begin signature block
# MIIZIAYJKoZIhvcNAQcCoIIZETCCGQ0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUue7XLN9cS4FZcbDKRlvWyW7E
# GregghRWMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggUSMIID+qADAgECAhAN//fSWE4vjemplVn1wnAjMA0GCSqGSIb3DQEBBQUAMG8x
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xLjAsBgNVBAMTJURpZ2lDZXJ0IEFzc3VyZWQgSUQgQ29k
# ZSBTaWduaW5nIENBLTEwHhcNMTQxMDAzMDAwMDAwWhcNMTUxMDA3MTIwMDAwWjBo
# MQswCQYDVQQGEwJDQTEQMA4GA1UECBMHT250YXJpbzEPMA0GA1UEBxMGT3R0YXdh
# MRowGAYDVQQKExFLaXJrIEFuZHJldyBNdW5ybzEaMBgGA1UEAxMRS2lyayBBbmRy
# ZXcgTXVucm8wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDIANwog4/2
# JUJCJ1PKeXu8S+eBp1F8fHaVFVgMToGhyNz+UptqDVBIsOu21AXNd4s/3WqhOnOt
# yBvyn5thWNGCMB/XcX6/SdV8lSyg0swreiiR7ksJc1jK75aDJV2UE/mOiMtcWo01
# SQGddbF4FpK3LxbzjKGMPP7uI1TUFTxmdR8t8HaRlI7KcsZkckGffkboAm5CWDhZ
# d4f9YhVzZ8uV0jAN9i+mtmIOHTMMskQ7tZy17GkgyjiGrnMxy6VZ18hya062ZLcV
# 20LUqsUkjr0oNvf54KrhZrPQhULagcpKwmxw3hzDfvWov4yVLWdgWT6a+TUG8D39
# HUuVCpXG+OgZAgMBAAGjggGvMIIBqzAfBgNVHSMEGDAWgBR7aM4pqsAXvkl64eU/
# 1qf3RY81MjAdBgNVHQ4EFgQUG+clmaBur2rhO4i38pTJHCFSya0wDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMG0GA1UdHwRmMGQwMKAuoCyGKmh0
# dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9hc3N1cmVkLWNzLWcxLmNybDAwoC6gLIYq
# aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL2Fzc3VyZWQtY3MtZzEuY3JsMEIGA1Ud
# IAQ7MDkwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRp
# Z2ljZXJ0LmNvbS9DUFMwgYIGCCsGAQUFBwEBBHYwdDAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMEwGCCsGAQUFBzAChkBodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURDb2RlU2lnbmluZ0NBLTEu
# Y3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQEFBQADggEBACJI6tx95+XcEC6X
# EAxbRZjIXJ085IDdqWXImnfQ8To+yAeHM5kP506ddtzlztW9esOxqnhnfIAClB1e
# 1f/FAlgpxrEQ2IRCuUHuMfy4AxqRkD9jePVZ7NYKcKxJZ87iu32iuGT+phFip+ZP
# O9GkqDYkvzQmB74b7hQ3knn6qFLqUZ8njpSceIeC8PHINZmSx+v+KVkEavN/z0hF
# T9xYR2VPPjIIk3MnwtkyHhTWWxNoKGCg+BZV2mApwR9EsWJHVpiGru6DNfNwSQpB
# oIvMGOOL919XgE4J1B022xnAcnCCxoGjjSmBPb1TWemijGsGD2Je8/EALw9geBB9
# vbJvwn8wggajMIIFi6ADAgECAhAPqEkGFdcAoL4hdv3F7G29MA0GCSqGSIb3DQEB
# BQUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQg
# SUQgUm9vdCBDQTAeFw0xMTAyMTExMjAwMDBaFw0yNjAyMTAxMjAwMDBaMG8xCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xLjAsBgNVBAMTJURpZ2lDZXJ0IEFzc3VyZWQgSUQgQ29kZSBT
# aWduaW5nIENBLTEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCcfPmg
# jwrKiUtTmjzsGSJ/DMv3SETQPyJumk/6zt/G0ySR/6hSk+dy+PFGhpTFqxf0eH/L
# er6QJhx8Uy/lg+e7agUozKAXEUsYIPO3vfLcy7iGQEUfT/k5mNM7629ppFwBLrFm
# 6aa43Abero1i/kQngqkDw/7mJguTSXHlOG1O/oBcZ3e11W9mZJRru4hJaNjR9H4h
# webFHsnglrgJlflLnq7MMb1qWkKnxAVHfWAr2aFdvftWk+8b/HL53z4y/d0qLDJG
# 2l5jvNC4y0wQNfxQX6xDRHz+hERQtIwqPXQM9HqLckvgVrUTtmPpP05JI+cGFvAl
# qwH4KEHmx9RkO12rAgMBAAGjggNDMIIDPzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0l
# BAwwCgYIKwYBBQUHAwMwggHDBgNVHSAEggG6MIIBtjCCAbIGCGCGSAGG/WwDMIIB
# pDA6BggrBgEFBQcCARYuaHR0cDovL3d3dy5kaWdpY2VydC5jb20vc3NsLWNwcy1y
# ZXBvc2l0b3J5Lmh0bTCCAWQGCCsGAQUFBwICMIIBVh6CAVIAQQBuAHkAIAB1AHMA
# ZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0AGkAZgBpAGMAYQB0AGUAIABjAG8A
# bgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBlAHAAdABhAG4AYwBlACAAbwBmACAA
# dABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABDAFAALwBDAFAAUwAgAGEAbgBkACAA
# dABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABhAHIAdAB5ACAAQQBnAHIAZQBlAG0A
# ZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBpAHQAIABsAGkAYQBiAGkAbABpAHQA
# eQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBvAHIAcABvAHIAYQB0AGUAZAAgAGgA
# ZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQByAGUAbgBjAGUALjASBgNVHRMBAf8E
# CDAGAQH/AgEAMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8EejB4
# MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVk
# SURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGln
# aUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMB0GA1UdDgQWBBR7aM4pqsAXvkl64eU/
# 1qf3RY81MjAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzANBgkqhkiG
# 9w0BAQUFAAOCAQEAe3IdZP+IyDrBt+nnqcSHu9uUkteQWTP6K4feqFuAJT8Tj5uD
# G3xDxOaM3zk+wxXssNo7ISV7JMFyXbhHkYETRvqcP2pRON60Jcvwq9/FKAFUeRBG
# JNE4DyahYZBNur0o5j/xxKqb9to1U0/J8j3TbNwj7aqgTWcJ8zqAPTz7NkyQ53ak
# 3fI6v1Y1L6JMZejg1NrRx8iRai0jTzc7GZQY1NWcEDzVsRwZ/4/Ia5ue+K6cmZZ4
# 0c2cURVbQiZyWo0KSiOSQOiG3iLCkzrUm2im3yl/Brk8Dr2fxIacgkdCcTKGCZly
# CXlLnXFp9UH/fzl3ZPGEjb6LHrJ9aKOlkLEM/zGCBDQwggQwAgEBMIGDMG8xCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xLjAsBgNVBAMTJURpZ2lDZXJ0IEFzc3VyZWQgSUQgQ29kZSBT
# aWduaW5nIENBLTECEA3/99JYTi+N6amVWfXCcCMwCQYFKw4DAhoFAKB4MBgGCisG
# AQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFJWN
# orFxNCfnArt2Fwa24D3xcCntMA0GCSqGSIb3DQEBAQUABIIBAJgkb+qGVauA8SF5
# GbOZ2sgg1sL723toaa2RbvpBk3tDDoqkKv3tuXYDTTQj+Wygt1zT/xC0Z004gKzr
# elHETbKQdRej5uaLWt1x2wfMWcGYwtLX6Ij5rt9LPmE3GfTlDvf3b0aoslm5btAv
# f/ZtlUtcpjbYQLXqGOZFSr0w9Lugm9iLkYQZgo/RMFPBhv0SLHrEIC6rb4NU5Uxp
# 1GuoChkCHjdJZkhDpl+CtDeDiN+aQ/ZW7a8AVCc5HgJh8KCxH98NtcMM5dKVbmS/
# cuc7D60+jal5UGUoXQrcpVTbwcvIiYmUK5L9Lnc8kt+zeawtSM6yRWT86Ssj9F37
# 8Jyh276hggILMIICBwYJKoZIhvcNAQkGMYIB+DCCAfQCAQEwcjBeMQswCQYDVQQG
# EwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5
# bWFudGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMgIQDs/0OMj+vzVu
# BNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAc
# BgkqhkiG9w0BCQUxDxcNMTQxMDA4MTMwODE3WjAjBgkqhkiG9w0BCQQxFgQU5BuM
# gb+k3hXJIBr4lFucc3sbUM8wDQYJKoZIhvcNAQEBBQAEggEALuzekv+IQZP9k9Wk
# mzSgvScJbdjXfEVNnHMB46L62RMiEBF1RZMKBaFCXRjwGTFt/nJRzot7m/ffVNHE
# /tm3O9nXWEIWFKc/KXnjF2IoU9ML+QwXCQqkfIf1vXIgRXaLB/KXFSV3WnqJ3YIh
# dRKO+08xNLB01H9tPo0HeDjecLLWzsXui2pi1HM6qc4TWnEHTxXm/qVHgD1O4Ihj
# C121xysrdoUXwwqArwibsJozFiCHUS2Be6OR56/QdaSB2TmPP9lroIUebVQuO4ZE
# MHBiNPOunEWnvJgnb/0qRQoPhs+0NlBg0DjbofOLgRPMwx+6jkkjrNZS7H/8ETmd
# DKD+tA==
# SIG # End signature block