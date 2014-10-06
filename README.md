## DoPx

### Overview

The DoPx module provides a rich set of commands that extend the automation
capabilities of the Digital Ocean (DO) cloud service. These commands make it
easier to manage your Digital Ocean environment from Windows PowerShell. When
used with the LinuxPx module, you can manage all aspects of your environment
from one shell.

Note: The LinuxPx module is currently in development and will be released as
soon as possible.

### Minimum requirements

PowerShell 4.0
SnippetPx module
TypePx module

### License and Copyright

Copyright (c) 2014 Kirk Munro.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License in the
license folder that is included in the ScsmPx module. If not, see
<https://www.gnu.org/licenses/gpl.html>.

### Using the DoPx module

To see a list of all commands that are included in DoPx, invoke the following
command:

```powershell
Get-Command -Module DoPx
```

This will return a list of the 44 commands that are included in the DoPx module.
At the time that this module was published, every feature that is available in
version 2 of the DigitalOcean API is covered in this module.

Here are a few examples showing how you can get started using this module to
manage your DigitalOcean environment:

```powershell
# Set the default access token for all DoPx commands
$doAccessToken = ConvertTo-SecureString -AsPlainText -Force '8d6f337076302316dca51e78d3068da231ccaa9077e8e94d28bcf91db7fc3a4a'
Set-DoPxDefaultAccessToken -AccessToken $doAccessToken
# Get all droplets from your DigitalOcean environment
Get-DoPxDroplet
# Show all images that are available
Get-DoPxImage
# Show all size specifications that are available
Get-DoPxSize
# Show all regions that are available
Get-DoPxRegion
# Look at all droplet commands
Get-Command -Noun DoPxDroplet
# Start all droplets
Get-DoPxDroplet | Start-DoPxDroplet
# See what would happen if you tried to create a bunch of new droplets with IPv6 and private networking enabled using the following command
# Note that this will not actually create the droplets, but it will allow you to see what type of HTTP request is being used, the body the message would contain, and the target uri where the request would be sent
# Once you confirm that is what you want, actually create the droplets by removing -WhatIf from the command
New-DoPxDroplet -Name NewDroplet1,NewDroplet2,NewDroplet3 -ImageId ubuntu-14-04-x64 -Size 4gb -Region nyc3 -EnableIPv6 -EnablePrivateNetworking -WhatIf
```

This is just a small sample of what you can do with the DoPx module. If you want
to see what HTTP requests are being sent and which uris they are being sent to,
try running any of the commands above with the -Verbose switch. As highlighted in
the last example, you can also use -WhatIf to see what would happen if you were
to invoke a command that would change your environment (i.e. no Get-* commands,
but Add-*, Set-*, Remove-*, Rename-*, New-*, etc. all should support -WhatIf).
Also note that for the commands shown above, there are additional parameters for
more options, and full documentation is available for every command by invoking
Get-Help followed by the name of the command you want help for.

For an example on how to get help on a DoPx command, try the following:

```powershell
Get-Help New-DoPxDroplet -Full | more
```

If you would like help with specific automation scenarios with DoPx, please let
me know!

### Command List

The DoPx module currently includes the following commands:

```powershell
Add-DoPxDnsRecord
Add-DoPxDomain
Add-DoPxSshKey
Clear-DoPxDefaultAccessToken
Copy-DoPxBackup
Copy-DoPxSnapshot
Disable-DoPxDropletOption
Enable-DoPxDropletOption
Get-DoPxAction
Get-DoPxBackup
Get-DoPxDefaultAccessToken
Get-DoPxDnsRecord
Get-DoPxDomain
Get-DoPxDroplet
Get-DoPxImage
Get-DoPxKernel
Get-DoPxRegion
Get-DoPxSize
Get-DoPxSnapshot
Get-DoPxSshKey
New-DoPxDroplet
New-DoPxSnapshot
Receive-DoPxAction
Remove-DoPxBackup
Remove-DoPxDnsRecord
Remove-DoPxDomain
Remove-DoPxDroplet
Remove-DoPxSnapshot
Remove-DoPxSshKey
Rename-DoPxBackup
Rename-DoPxDnsRecord
Rename-DoPxDroplet
Rename-DoPxSnapshot
Rename-DoPxSshKey
Reset-DoPxDroplet
Resize-DoPxDroplet
Restart-DoPxDroplet
Restore-DoPxBackup
Restore-DoPxSnapshot
Set-DoPxDefaultAccessToken
Start-DoPxDroplet
Stop-DoPxDroplet
Update-DoPxKernel
Wait-DoPxAction
```