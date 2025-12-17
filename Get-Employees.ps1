Import-Module ActiveDirectory

#get all active employees and count them > send to csv file
$emp = Get-AdUser -Filter {(Enabled -eq $True)} |
Where-Object {$_.DistinguishedName -like "*OU=Active Employees,OU=Corporate Employees,DC=example,DC=example"} |
Select-Object UserPrincipalName | 
Where-Object `
{$_.UserPrincipalName -notlike 'value*' `
-and $_.UserPrincipalName -notlike 'value*' `
-and $_.UserPrincipalName -notlike 'value*' `
-and $_.UserPrincipalName -notlike '*value*' `
-and $_.UserPrincipalName -notlike '*value*' `
-and $_.UserPrincipalName -notlike '*value*'} |
Sort-Object UserPrincipalName
$emp
$emp.Count
$emp | Export-Csv C:\IT\Employees.csv