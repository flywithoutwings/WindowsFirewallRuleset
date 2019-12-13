
#setup variables:
$Platform = "10.0+" #Windows 10 and above
$Group = "Windows Services"
$Profile = "Private, Public"
$Interface = "Wired, Wireless"
$PolicyStore = "localhost"
$OnError = "Stop"
$ServiceHost = "%SystemRoot%\System32\svchost.exe"
$Deubg = $false

#First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction Outbound -ErrorAction SilentlyContinue
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction Inbound -ErrorAction SilentlyContinue

#
# Windows services rules
# Rules that apply to Windows services
#

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Background Intelligent Transfer Service" -Program $ServiceHost -Service BITS `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description "Used for background update,
note that BITS is used by many third-party tools to download their own updates like AcrobatReader.
Transfers files in the background using idle network bandwidth. If the service is disabled,
then any applications that depend on BITS, such as Windows Update or MSN Explorer,
will be unable to automatically download programs and other information."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Cryptographic Services" -Program $ServiceHost -Service CryptSvc `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description "Provides three management services:
Catalog Database Service, which confirms the signatures of Windows files and allows new programs to be installed;
Protected Root Service, which adds and removes Trusted Root Certification Authority certificates from this computer;
and Automatic Root Certificate Update Service, which retrieves root certificates from Windows Update and enable scenarios such as SSL."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Delivery Optimization" -Program $ServiceHost -Service DoSvc `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description "Service responsible for delivery optimization.
Windows Update Delivery Optimization works by letting you get Windows updates and Microsoft Store apps from sources in addition to Microsoft,
like other PCs on your local network, or PCs on the Internet that are downloading the same files.
Delivery Optimization also sends updates and apps from your PC to other PCs on your local network or PCs on the Internet, based on your settings."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows update service" -Program $ServiceHost -Service wuauserv `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 443 `
-Description "Enables the detection, download, and installation of updates for Windows and other programs.
If this service is disabled, users of this computer will not be able to use Windows Update or its automatic updating feature,
and programs will not be able to use the Windows Update Agent (WUA) API."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Modules Installer" -Program $ServiceHost -Service TrustedInstaller `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 443 `
-Description "Enables installation, modification, and removal of Windows updates and optional components.
If this service is disabled, install or uninstall of Windows updates might fail for this computer."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Microsoft Account Sign-in Assistant" -Program $ServiceHost -Service wlidsvc `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 443 `
-Description "Enables user sign-in through Microsoft account identity services.
If this service is stopped, users will not be able to logon to the computer with their Microsoft account."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Time (NTP/SNTP)" -Program $ServiceHost -Service W32Time `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol UDP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 123 `
-Description "Maintains date and time synchronization on all clients and servers in the network.
If this service is stopped, date and time synchronization will be unavailable.
If this service is disabled, any services that explicitly depend on it will fail to start."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Time (DayTime)" -Program $ServiceHost -Service W32Time `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 13 `
-Description "Maintains date and time synchronization on all clients and servers in the network.
If this service is stopped, date and time synchronization will be unavailable.
If this service is disabled, any services that explicitly depend on it will fail to start."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Time (DayTime)" -Program $ServiceHost -Service W32Time `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol UDP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 13 `
-Description "Maintains date and time synchronization on all clients and servers in the network.
If this service is stopped, date and time synchronization will be unavailable.
If this service is disabled, any services that explicitly depend on it will fail to start."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Time (TIME)" -Program $ServiceHost -Service W32Time `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 37 `
-Description "Maintains date and time synchronization on all clients and servers in the network.
If this service is stopped, date and time synchronization will be unavailable.
If this service is disabled, any services that explicitly depend on it will fail to start."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Time (TIME)" -Program $ServiceHost -Service W32Time `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol UDP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 37 `
-Description "Maintains date and time synchronization on all clients and servers in the network.
If this service is stopped, date and time synchronization will be unavailable.
If this service is disabled, any services that explicitly depend on it will fail to start."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Push Notifications System Service" -Program $ServiceHost -Service WpnService `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 443 `
-Description "This service runs in session 0 and hosts the notification platform and connection provider
which handles the connection between the device and WNS server."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Push Notifications User Service" -Program $ServiceHost -Service WpnUserService_e13583 `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description "This service hosts Windows notification platform which provides support for local and push notifications.
Supported notifications are tile, toast and raw."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Insider Service" -Program $ServiceHost -Service wisvc `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 443 `
-Description "Provides infrastructure support for the Windows Insider Program.
This service must remain enabled for the Windows Insider Program to work."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Group Policy Client" -Program $ServiceHost -Service gpsvc `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 443 `
-Description "The service is responsible for applying settings configured by administrators for the computer and users through the Group Policy component.
If the service is disabled, the settings will not be applied and applications and components will not be manageable through Group Policy.
Any components or applications that depend on the Group Policy component might not be functional if the service is disabled."