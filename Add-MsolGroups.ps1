<#
    Adds user to a group in 365/Azure that you specify
    Adds user to the SelfServiceGroup
    *You need to know their first and last name*
#>

$creds = Get-Credential email@example.com

Import-Module MSOnline
Import-Module ExchangeOnlineManagement
Connect-MsolService -Credential $creds -Verbose
Connect-ExchangeOnline -Credential $creds -Verbose

$firstName = Read-Host "Enter Users' First Name"
$lastName = Read-Host "Enter Users' Last Name"
$upn = $firstName + "." + $lastName + "@example.com"

$hash = @{
    "Staff"      = 1;
    "AVP"        = 2;
    "Management" = 3;
    "Sales"      = 4;
    "Operations" = 5;
    "Corporate"  = 6;
    "Core"       = 7;
    "Testing"    = 8;
    "IT"         = 9;
}

$hash.GetEnumerator() | Sort-Object -Property Value

$grp = Read-Host "Enter Groups From The Choices Above Using The Value"

#Switch for $grp
switch ($grp) {
    '1' { Set-Variable -Name grp -Value "ID-HERE" }
    '2' { Set-Variable -Name grp -Value "ID-HERE" }
    '3' { Set-Variable -Name grp -Value "ID-HERE" }
    '4' { Set-Variable -Name grp -Value "ID-HERE" }
    '5' { Set-Variable -Name grp -Value "ID-HERE" }
    '6' { Set-Variable -Name grp -Value "ID-HERE" }
    '7' { Set-Variable -Name grp -Value "ID-HERE" }
    '8' { Set-Variable -Name grp -Value "ID-HERE" }
    '9' { Set-Variable -Name grp -Value "ID-HERE" }
    Default { Set-Variable -Name grp -Value $null }
}

#Add User to Groups
$user = Get-MsolUser -UserPrincipalName $upn

Add-DistributionGroupMember -Identity $grp `
    -Member $user.ObjectId.Guid

#Multiple Groups Loop
while ($group1 = 'y') {
    $group1 = Read-Host 'Add to Another Group? y or n'
    if ($group1 -eq 'y') {
        $hash.GetEnumerator() | Sort-Object -Property Value
        $grp = (Read-Host "Enter Groups From The Choices Above Using The Value")
        switch ($grp) {
            '1' { Set-Variable -Name grp -Value "ID-HERE" }
            '2' { Set-Variable -Name grp -Value "ID-HERE" }
            '3' { Set-Variable -Name grp -Value "ID-HERE" }
            '4' { Set-Variable -Name grp -Value "ID-HERE" }
            '5' { Set-Variable -Name grp -Value "ID-HERE" }
            '6' { Set-Variable -Name grp -Value "ID-HERE" }
            '7' { Set-Variable -Name grp -Value "ID-HERE" }
            '8' { Set-Variable -Name grp -Value "ID-HERE" }
            '9' { Set-Variable -Name grp -Value "ID-HERE" }
            Default { Set-Variable -Name grp -Value $null }
        }

        Add-DistributionGroupMember -Identity $grp `
            -Member $user.ObjectId.Guid
    }
    elseif ($group1 -ne 'y') {
        break
    }
}

#Add to SelfServiceGroup group
Add-UnifiedGroupLinks `
    -Identity "SelfServiceGroup" `
    -LinkType Members `
    -Links $user.ObjectId.Guid

Disconnect-ExchangeOnline -Verbose -Confirm:$false

Write-Host 'End of script'
Read-Host -Prompt "Press Enter to Continue..."