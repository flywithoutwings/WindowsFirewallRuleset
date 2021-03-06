
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

<#
http://www.iana.org/assignments/ipv6-multicast-addresses/ipv6-multicast-addresses.xhtml
https://www.ronaldschlager.com/2014/ipv6-addresses-scopes-zones/

IPv6 multicast addresses are distinguished from unicast addresses by the value of the high-order octet of the addresses:
a value of 0xFF (binary 11111111) identifies an address as a multicast address;
any other value identifies an address as a unicast address.

ff00::/16 	Reserved
ff01::/16	Interface-Local scope
ff02::/16	Link-Local scope
ff03::/16	Realm-Local scope
ff04::/16	Admin-Local scope
ff05::/16   Site-Local scope
ff06::/16	Unassigned
ff07::/16	Unassigned
ff08::/16	Organization-Local scope
ff09::/16 - ff0D/16	Unassigned	
ff0e::/16	Global scope
ff0f::/16  	Reserved

Interface-local scope:
IPv6 addresses of interface-local scope are mainly used for loopback tests.

Link-local scope:
IPv6 addresses of link-local scope have the same scope as link-lokal unicast addresses
(limited to one link, one physical network and one layer 2 broadcast domain).

Realm-local scope:
the zone of Realm-local scope must fall within zones of larger scope.

Admin-local scope:
the scope of IPv6 addresses of admin-local scope must be configured by the address administrator,
it is not automatically derived from any configuration data.

Site-local scope:
an IPv6 address of site-local scope span the same topological region as its communicating partners.

Organization-local scope:
an IPv6 address of organization-local scope is valid at all locations of the same organization or corporation.

Global scope:
these IPv6 addresses are valid globally and are globally routable.
#>

# TODO: local address should be known for outbound, for inbound rules remote should be known

# Includes
. $PSScriptRoot\DirectionSetup.ps1
. $PSScriptRoot\..\IPSetup.ps1
Import-Module -Name $PSScriptRoot\..\..\FirewallModule

#
# Setup local variables:
#
$Group = "Multicast IPv6"
$Profile = "Private, Domain"
$Description = "http://www.iana.org/assignments/ipv6-multicast-addresses/ipv6-multicast-addresses.xhtml"
$MulticastUsers = Get-AccountSDDL @("NT AUTHORITY\NETWORK SERVICE", "NT AUTHORITY\LOCAL SERVICE")
# NOTE: we need Any to include IPv6 loopback interface because IPv6 loopback rule does not work on boot, (neither ::1 address nor interface alias)
$MulticastInterface = "Any"

# Ask user if he wants to load these rules
Update-Context $IPVersion $Direction $Group
if (!(Approve-Execute)) { exit }

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction SilentlyContinue

#
# Interface-Local Multicast filtering (All destinations)
#

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Interface-Local Multicast" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile Any -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff01::/16 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

#
# Interface-Local Multicast filtering (Individual destinations)
#

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Interface-Local Multicast - All Nodes" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Any -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff01::1 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Interface-Local Multicast - All Routers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Any -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff01::2 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Interface-Local Multicast - mDNSv6" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Any -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff01::fb -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description


#
# Link-Local Multicast filtering (All destinations)
#

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Block -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::/16 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

#
# Link-Local Multicast filtering (Individual destinations)
#

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - All Nodes" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::1 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - All Routers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::2 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - DVMRP Routers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::4 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - OSPFIGP" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::5 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - OSPFIGP Designated Routers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::6 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - ST Routers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::7 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - ST Hosts" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::8 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - RIP Routers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::9 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - EIGRP Routers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::a -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - Mobile-Agents" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::b -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - SSDP" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::c -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - All PIM Routers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::d -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - RSVP-ENCAPSULATION" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::e -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - UPnP" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::f -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - All-BBF-Access-Nodes" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::10 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - VRRP" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::12 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - All MLDv2-capable routers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::16 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - all-RPL-nodes" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::1a -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - All-Snoopers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::6a -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - PTP-pdelay" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::6b -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - Saratoga" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::6c -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - LL-MANET-Routers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::6d -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - IGRS" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::6e -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - iADT Discovery" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::6f -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - mDNSv6" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::fb -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - Link Name" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::1:1 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - All-dhcp-agents" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::1:2 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - Link-local Multicast Name Resolution" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::1:3 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - DTCP Announcement" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::1:4 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - afore_vdp" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::1:5 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - Babel" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::1:6 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - Solicited-Node Address" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff02::1:ff00:0000/104 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Link-Local Multicast - Node Information Queries" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress FF02:0:0:0:0:2:FF00::/104 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

#
# Site-Local Multicast filtering (All destinations)
#

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Site-Local Multicast - All Routers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Block -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff05::/16 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

#
# Site-Local Multicast filtering (Individual destinations)
#

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Site-Local Multicast - All Routers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff05::2 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Site-Local Multicast - mDNSv6" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff05::fb -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Site-Local Multicast - All-dhcp-servers" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff05::1:3 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Site-Local Multicast - SL-MANET-ROUTERS" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff05::1:5 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

#
# Realm-Local Multicast filtering (All destinations)
#

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Realm-Local Multicast" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Block -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff03::/16 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

#
# Admin-Local Multicast filtering (All destinations)
#

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Admin-Local Multicast" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Block -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff04::/16 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

#
# Organization-Local Multicast filtering (All destinations)
#

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Organization-Local Multicast" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Block -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff08::/16 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description

#
# Global scope Multicast filtering (All destinations)
#

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Global scope Multicast" -Service Any -Program Any `
-PolicyStore $PolicyStore -Enabled False -Action Block -Group $Group -Profile $Profile -InterfaceType $MulticastInterface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress ff0e::/16 -LocalPort Any -RemotePort Any `
-LocalUser $MulticastUsers -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description $Description
