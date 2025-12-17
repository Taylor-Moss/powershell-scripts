$creds = Get-Credential email@example.com

Import-Module ActiveDirectory
Import-Module MSOnline
Connect-MsolService -Credential $creds -Verbose

###ON-PREM CMDS###

$computers = Get-ADComputer -Filter {(Enabled -eq $True)} |
Where-Object {$_.DistinguishedName -like "*OU=Active Workstations,OU=Workstations,DC=example,DC=example"}|
Select-Object Name |
Sort-Object name

$computers
$computers.Count

#make results all uppercase
$array = 
"@

@"

$upperarray = $array.toupper()

$upperarray

###MSOL CMDS###

#all hybrid joined devices (exclude pending)
$hybrid = Get-MsolDevice `
-All `
-IncludeSystemManagedDevices | 
Where-Object {($_.DeviceTrustType -eq 'Domain Joined') `
-and (([string]($_.AlternativeSecurityIds)).StartsWith("X509:"))} |
Select-Object DisplayName | Sort-Object DisplayName
$hybrid
$hybrid.Count

#pending hybrid joined devices
$pending = Get-MsolDevice -All -IncludeSystemManagedDevices | 
Where-Object {($_.DeviceTrustType -eq 'Domain Joined') `
-and (-not([string]($_.AlternativeSecurityIds)).StartsWith("X509:"))} |
Select-Object DisplayName | Sort-Object DisplayName
$pending
$pending.count