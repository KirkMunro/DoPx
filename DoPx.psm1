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

#region Initialize the module.

Invoke-Snippet -Name Module.Initialize

#endregion

#region Initialize module-specific properties.

$DigitalOceanEndpointUri = 'https://api.digitalocean.com/v2'

#endregion

Update-TypeData -Force -TypeName digitalocean.action -MemberName duration -MemberType ScriptProperty -Value {if ($this.completed_at -ne $null) {$this.completed_at - $this.started_at}}

#region Import helper (private) function definitions.

Invoke-Snippet -Name ScriptFile.Import -Parameters @{
    Path = Join-Path -Path $PSModuleRoot -ChildPath helpers
}

#endregion

#region Import public function definitions.

Invoke-Snippet -Name ScriptFile.Import -Parameters @{
    Path = Join-Path -Path $PSModuleRoot -ChildPath functions
}

#endregion

$PSModule.OnRemove = {
}