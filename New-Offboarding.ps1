<#
    .DESCRIPTION
    Changes User Password and Marks Inactive
    Moves AD User to Offboarded Users OU
    Blocks sign in for 365/Azure
    Removes All Distribution Groups
    Converts Mailbox to Shared
    Removes All Licenses from 365/Azure
    Sends Confirmation Email to it@example.com of the Offboarding
#>
Write-Host "Enter your credentials"
$creds = Get-Credential
$session = New-PSSession -ComputerName Name -Credential $creds
Import-Module MSOnline
Import-Module ExchangeOnlineManagement
Write-Host "Enter your ExchangeOnline creds"
$onlinecreds = Get-Credential
Connect-MsolService -Credential $onlinecreds
Connect-ExchangeOnline -Credential $onlinecreds

Add-Type -AssemblyName 'System.Web'
$usrpwd = [System.Web.Security.Membership]::GeneratePassword(12, 1)

$firstName = Read-Host "Enter Users' First Name"
$lastName = Read-Host "Enter Users' Last Name"
$mfname = Read-Host "Enter their managers' First Name"
$mlname = Read-Host "Enter their managers' Last Name"
$manager = $mfname + "." + $mlname
$upn = $firstName + "." + $lastName + "@example.com"
$together = $firstName + "." + $lastName
$pass = ConvertTo-SecureString $usrpwd -AsPlainText -Force

Invoke-Command `
    -Session $session `
    -ArgumentList $usrpwd, $creds, $firstName, $lastName, $upn, $together, $pass, $mfname, $mlname, $manager `
    -ScriptBlock {
    param (
        $usrpwd,
        [PSCredential] $creds,
        $firstName,
        $lastName,
        $upn,
        $together,
        $pass,
        $mfname,
        $mlname,
        $manager
    )
    "Credentials = {0}" -f $usrpwd, $creds, $firstName, $lastName, $upn, $together, $pass

    Import-Module ActiveDirectory

    Write-Host "Resetting AD Password"
    Set-ADAccountPassword `
        -Identity $together `
        -Reset `
        -NewPassword $pass

    Write-Host "Disabling AD Account"
    Disable-ADAccount `
        -Identity $together

    Write-Host "Moving to Offboarded Users OU"
    Get-ADUser $together | Move-AdObject `
        -TargetPath "OU=Path" `
        -Confirm:$false
} #scriptblock

Remove-PSSession $session

#Block 365 sign in
Write-Host "Blocking 365 Sign in"
Set-MsolUser `
    -UserPrincipalName $upn `
    -BlockCredential $true

#Remove All Distribution Groups
Write-Host "Removing All Distribution Groups..."
$mailbox = Get-Mailbox -Identity "$upn"
$DN = $mailbox.DistinguishedName
$filter = "Members -like ""$DN"""
$groups = Get-DistributionGroup -ResultSize Unlimited -Filter $filter

foreach ($group in $groups) {
    Remove-DistributionGroupMember `
        -Identity $group.DisplayName `
        -Member $upn `
        -Confirm:$false `
        -Verbose
}

#remove group 1 if associated
Write-Host "Removing Group 1 if Associated"
$userguid = Get-MsolUser -UserPrincipalName $upn
Remove-MsolGroupMember `
    -GroupObjectId "ID1" `
    -GroupMemberType User `
    -GroupMemberObjectId $userguid.ObjectId `
    -Confirm:$false `
    -ErrorAction:SilentlyContinue

#remove group 2 if associated
Write-Host "Removing Group 2 if Associated"
Remove-MsolGroupMember `
    -GroupObjectId "ID2" `
    -GroupMemberType User `
    -GroupMemberObjectId $userguid.ObjectId `
    -Confirm:$false `
    -ErrorAction:SilentlyContinue

#remove group 3 if associated
Write-Host "Removing Group 3 if Associated"
Remove-MsolGroupMember `
    -GroupObjectId "ID3" `
    -GroupMemberType User `
    -GroupMemberObjectId $userguid.ObjectId `
    -Confirm:$false `
    -ErrorAction:SilentlyContinue

#remove group 4 if associated
Write-Host "Removing Group 4 if Associated"
Remove-UnifiedGroupLinks `
    -Identity "ID4" `
    -LinkType Members `
    -Links $userguid.ObjectId.Guid `
    -Confirm:$false `
    -ErrorAction:SilentlyContinue

Write-Host "Waiting 30 Seconds for Group Removal..."
Start-Sleep 30

#Convert to Shared Mailbox
Write-Host "Converting to Shared Mailbox..."
Set-Mailbox $together -Type Shared -Confirm:$false
Write-Host "Waiting 60 Seconds to Update to Shared Mailbox..."
Start-Sleep 60

#Remove 365 Licenses
Write-Host "Removing Licenses"
Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses "LICENSE-ID-HERE" -ErrorAction:SilentlyContinue
Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses "LICENSE-ID-HERE" -ErrorAction:SilentlyContinue
Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses "LICENSE-ID-HERE" -ErrorAction:SilentlyContinue
Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses "LICENSE-ID-HERE" -ErrorAction:SilentlyContinue

#Add manager to shared mailbox
Write-Host "Adding Manager to Shared Mailbox"
Add-MailboxPermission `
    -Identity $upn `
    -AccessRights FullAccess `
    -InheritanceType All `
    -AutoMapping:$true `
    -User $manager

#####################EMAIL - NOTE TO IT#####################
Write-Host "Sending Email Notification of Offboarding to IT..."
$Username = "companyit@example.com";
$Password = "password-here";
$email = "it@example.com"
$date = Get-Date -Format "dddd MM/dd/yyyy"
$body = @"
Company IT,

Offboarding Info: $date

User: $together

     - Company IT Alerts
"@
$message = new-object Net.Mail.MailMessage;
$message.From = "Company IT <companyit@example.com>";
$message.To.Add($email);
$message.Subject = "Offboarding Info $date";
$message.Body = $body
   
$smtp = new-object Net.Mail.SmtpClient("SMTP-SERVER", "25");
$smtp.EnableSSL = $true;
$smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
$smtp.send($message);
Write-Host "Mail Sent" ;
$smtp.Dispose()

Write-Host 'End of script'
Read-Host -Prompt "Press Enter to Continue..."