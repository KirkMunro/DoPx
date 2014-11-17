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

- PowerShell 4.0
- TypePx module
- SnippetPx module

### License and Copyright

Copyright 2014 Kirk Munro

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

### Installing the DoPx module

DoPx is dependent on the TypePx and SnippetPx modules. You can download
and install the latest versions of DoPx, TypePx and SnippetPx using any
of the following methods:

#### PowerShellGet

If you don't know what PowerShellGet is, it's the way of the future for PowerShell
package management. If you're curious to find out more, you should read this:
<a href="http://blogs.msdn.com/b/mvpawardprogram/archive/2014/10/06/package-management-for-powershell-modules-with-powershellget.aspx" target="_blank">Package Management for PowerShell Modules with PowerShellGet</a>

Note that these commands require that you have the PowerShellGet module installed
on the system where they are invoked.

```powershell
# If you don’t have DoPx installed already and you want to install it for all
# all users (recommended, requires elevation)
Install-Module DoPx,TypePx,SnippetPx

# If you don't have DoPx installed already and you want to install it for the
# current user only
Install-Module DoPx,TypePx,SnippetPx -Scope CurrentUser

# If you have DoPx installed and you want to update it
Update-Module
```

#### PowerShell 3.0 or Later

To install from PowerShell 3.0 or later, open a native PowerShell console (not ISE,
unless you want it to take longer), and invoke one of the following commands:

```powershell
# If you want to install DoPx for all users or update a version already installed
# (recommended, requires elevation for new install for all users)
& ([scriptblock]::Create((iwr -uri http://tinyurl.com/Install-GitHubHostedModule).Content)) -ModuleName DoPx,TypePx,SnippetPx

# If you want to install DoPx for the current user
& ([scriptblock]::Create((iwr -uri http://tinyurl.com/Install-GitHubHostedModule).Content)) -ModuleName DoPx,TypePx,SnippetPx -Scope CurrentUser
```

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