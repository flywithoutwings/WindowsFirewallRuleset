
<#
MIT License

Copyright (c) 2019 metablaster zebal@protonmail.ch

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

# Includes
. $PSScriptRoot\..\DirectionSetup.ps1
. $PSScriptRoot\..\..\IPSetup.ps1
Import-Module -Name $PSScriptRoot\..\..\..\FirewallModule

#
# Setup local variables:
#
$Group = "Software - Nvidia"
$Profile = "Private, Public"

# Ask user if he wants to load these rules
Update-Context $IPVersion $Direction $Group
if (!(Approve-Execute)) { exit }

#
# Nvidia installation directories
#
$NvidiaRoot64 = "%ProgramFiles%\NVIDIA Corporation"
$NvidiaRoot86 = "%ProgramFiles(x86)%\NVIDIA Corporation"

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction SilentlyContinue

#
# Rules for Nvidia 64bit executables
#

# Test if installation exists on system
$Nvidia64Status = Test-Installation "Nvidia64" ([ref] $NvidiaRoot64) $false

if ($Nvidia64Status -ne $null)
{
    $global:InstallationStatus = $Nvidia64Status

    $program = "$NvidiaRoot64\NvContainer\nvcontainer.exe"
    Test-File $program
    New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
    -DisplayName "Nvidia Container x64" -Service Any -Program $Program `
    -PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
    -Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
    -LocalUser $UserAccountsSDDL `
    -Description ""

    $program = "$NvidiaRoot64\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe"
    Test-File $program
    New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
    -DisplayName "Nvidia GeForce Experience x64" -Service Any -Program $Program `
    -PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
    -Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
    -LocalUser $UserAccountsSDDL `
    -Description ""

    $program = "$NvidiaRoot64\Display.NvContainer\NVDisplay.Container.exe"
    Test-File $program
    New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
    -DisplayName "Nvidia NVDisplay Container x64" -Service Any -Program $Program `
    -PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
    -Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
    -LocalUser $UserAccountsSDDL `
    -Description ""

    $program = "$NvidiaRoot64\Update Core\NvProfileUpdater64.exe"
    Test-File $program
    New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
    -DisplayName "Nvidia Profile Updater" -Service Any -Program $Program `
    -PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
    -Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
    -LocalUser $UserAccountsSDDL `
    -Description ""
}

#
# Rules for Nvidia 32bit executables
#

# Test if installation exists on system
$Nvidia86Status = Test-Installation "Nvidia86" ([ref] $NvidiaRoot86) $false

if ($Nvidia86Status -ne $null)
{
    $global:InstallationStatus = $Nvidia86Status

    $program = "$NvidiaRoot86\NvContainer\nvcontainer.exe"
    Test-File $program
    New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
    -DisplayName "Nvidia Container x86" -Service Any -Program $Program `
    -PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
    -Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
    -LocalUser $UserAccountsSDDL `
    -Description ""

    $program = "$NvidiaRoot86\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe"
    Test-File $program
    New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
    -DisplayName "Nvidia GeForce Experience x86" -Service Any -Program $Program `
    -PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
    -Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
    -LocalUser $UserAccountsSDDL `
    -Description ""

    $program = "$NvidiaRoot86\NvTelemetry\NvTelemetryContainer.exe"
    Test-File $program
    New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
    -DisplayName "Nvidia Telemetry Container" -Service Any -Program $Program `
    -PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
    -Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
    -LocalUser $UserAccountsSDDL `
    -Description ""

    $program = "$NvidiaRoot86\NvNode\NVIDIA Web Helper.exe"
    Test-File $program
    New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
    -DisplayName "Nvidia WebHelper TCP" -Service Any -Program $Program `
    -PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
    -Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
    -LocalUser $UserAccountsSDDL `
    -Description ""
}
