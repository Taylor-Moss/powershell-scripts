<#
    .DESCRIPTION
    *YOU MUST KNOW THEIR CELL NUMBER/CARRIER BEFOREHAND, OR USE YOUR OWN TEMPORARILY*
    Creates an AD User in the OU you specify, with a randomly generated complex password
    Adds the user to the groups needed
    Syncs the user to 365 and Azure
    Adds user to group 1 and group 2
    Adds users 365/Azure License
    Sends a text with the users credentials to the users cell phone number based on what you specify
    Sends an email to italerts@example.com for the users info just created
#>

Write-Host "Enter your credentials"
$creds = Get-Credential
$session = New-PSSession -ComputerName Name -Credential $creds

#generate random complex password
$static = "!1".ToCharArray()
$pass = $static + ("ABCDEFGHJKLMNPRSTUVWXYZabcdefghjkmnoprstuvwxyz".tochararray() | Sort-Object { Get-Random })[1..10] -join '' 

#variables
$firstName = Read-Host "Input users first name"
$lastName = Read-Host "Input users last name"
$together = $firstName + "." + $lastName
$upn = $firstName + "." + $lastName + "@example.com"
$usrpwd = ConvertTo-SecureString $pass -AsPlainText -Force

#invoke command on Name
Invoke-Command -Session $session -ArgumentList `
    $firstName,
    $lastName,
    $together,
    $upn,
    $usrpwd,
    $adgroups,
    $pass,
    $creds `
    -ScriptBlock {
    param (
        $firstName,
        $lastName,
        $together,
        $upn,
        $usrpwd,
        $adgroups,
        $pass,
        [PSCredential] $creds
    )
    "Credentials = {0}" -f $pass, $creds

    Import-Module ActiveDirectory
    Import-Module MSOnline
    Connect-MsolService -Credential (Get-Credential)

    $adgroups = @(
        "GROUP-NAME"
        "GROUP-NAME"    
        "GROUP-NAME"
        "GROUP-NAME"      
        "GROUP-NAME"
        "GROUP-NAME"   
        "GROUP-NAME"          
        "GROUP-NAME"  
        "GROUP-NAME"       
        "GROUP-NAME"         
        "GROUP-NAME"
        "GROUP-NAME"
        "GROUP-NAME"
        "GROUP-NAME"
        "GROUP-NAME"
        "GROUP-NAME"
        "GROUP-NAME"                
        "GROUP-NAME"     
        "GROUP-NAME"
        "GROUP-NAME"
    )    

    $hash = @{
        GROUPNAME1  = 1;
        GROUPNAME2  = 2;
        GROUPNAME3  = 3;
        GROUPNAME4  = 4;
        GROUPNAME5  = 5;
        GROUPNAME6  = 6;
        GROUPNAME7  = 7;
        GROUPNAME8  = 8;
        GROUPNAME9  = 9;
        GROUPNAME10 = 10;
        GROUPNAME11 = 11;
        GROUPNAME12 = 12;
    }

    $hash.GetEnumerator() | Sort-Object -Property Value

    $path = Read-Host "Enter OU Path From the Choices Above Using The Value"

    #Switch for $path
    switch ($path) {
        '1' { Set-Variable -Name path -Value "OU=PATH" }
        '2' { Set-Variable -Name path -Value "OU=PATH" }
        '3' { Set-Variable -Name path -Value "OU=PATH" }
        '4' { Set-Variable -Name path -Value "OU=PATH" }
        '5' { Set-Variable -Name path -Value "OU=PATH" }
        '6' { Set-Variable -Name path -Value "OU=PATH" }
        '7' { Set-Variable -Name path -Value "OU=PATH" }
        '8' { Set-Variable -Name path -Value "OU=PATH" }
        '9' { Set-Variable -Name path -Value "OU=PATH" }
        '10' { Set-Variable -Name path -Value "OU=PATH" }
        '11' { Set-Variable -Name path -Value "OU=PATH" }
        '12' { Set-Variable -Name path -Value "OU=PATH" }
        Default { Set-Variable -Name path -Value "OU=PATH" }
    }

    #Create the User in AD
    Write-Host "Creating the AD user"
    New-ADUser `
        -Name ($firstName + " " + $lastName) `
        -GivenName $firstName `
        -Surname $lastName `
        -DisplayName ($firstName + " " + $lastName) `
        -SamAccountName $together `
        -UserPrincipalName $upn `
        -EmailAddress $upn `
        -Path $path `
        -AccountPassword $usrpwd `
        -Enabled $true `
        -ChangePasswordAtLogon $False

    #add user to DUO Users group
    Write-Host "Adding user to DUO Users group"
    Add-ADGroupMember `
        -Identity "DUO Users" `
        -Members $together

    #adding a group other than DUO Users
    $group = Read-Host 'Add user to an AD group other than DUO Users? y or n'
    if ($group -eq 'y') {
        $groupyes = (Read-Host "Enter group, Choices: $adgroups")
        Add-ADGroupMember `
            -Identity $groupyes `
            -Members $together
    }

    while ($group1 = 'y') {
        $group1 = Read-Host 'Add another group? y or n'
        if ($group1 -eq 'y') {
            $groupyes1 = (Read-Host "Input users' AD group")
            Add-AdGroupMember `
                -Identity $groupyes1 `
                -Members $together
        }
        elseif ($group1 -ne 'y') {
            #########
            break
            #########
        }
    }

    #Sync to 365
    Write-Host 'Syncing to 365 now...'

    try {
        Start-ADSyncSyncCycle -PolicyType Delta -ErrorAction Stop
    }
    catch {
        $adsync = Read-Host "Sync Failed, try again? y or n"
        Write-Host "Waiting 10 seconds for next sync attempt"
        Start-Sleep 10
        if ($adsync -eq "y") {
            Start-ADSyncSyncCycle -PolicyType Delta
        }
    }

    Write-Host "Waiting 60 seconds for sync..."
    Start-Sleep 60

    #License for Azure/365
    Write-Host "Licensing User for M365"
    Set-MsolUser -UserPrincipalName $upn -UsageLocation US
    #Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses "example0:AAD_PREMIUM"
    Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses "example0:SPE_E5"

    #Add to Intune Group
    Write-Host "Adding user to the Intune Security Group (Azure)"
    $user = Get-MsolUser -UserPrincipalName $upn
    Add-MsolGroupMember `
        -GroupObjectId ID-HERE `
        -GroupMemberType User `
        -GroupMemberObjectId $user.ObjectId.Guid

    #####################SMS - CREDS TO EMPLOYEE#####################
    $smstext = Read-Host "Do you know the user's cell number yet? y or n"
    if ($smstext -eq "y") {
        $Username = "italerts@example.com";
        $Password = "example";
        $number = Read-Host "Enter The Users' Cell Number"
        $ext = Read-Host "Enter The Users' Cell Carrier"

        switch ($ext) {
            'Verizon' { Set-Variable -Name ext -Value "@vtext.com" }
            'ATT' { Set-Variable -Name ext -Value "@txt.att.net" }
            Default { Set-Variable -Name ext -Value "@txt.att.net" }
        }
        
        $email = $number.replace("-", "") + $ext

        $body = @"


Dear $firstName,

PC/Email/iCloud:

User: $together
Password: $pass
Cell: $number
org
     - COMPANY IT Team
"@
        $message = new-object Net.Mail.MailMessage;
        $message.From = "COMPANY IT <italerts@example.com>";
        $message.To.Add($email);
        $message.Subject = "Welcome to COMPANY!";
        $message.Body = $body
        $message.IsBodyHtml = $false
   
        $smtp = new-object Net.Mail.SmtpClient("example-net.mail.eo.outlook.com", "25");
        $smtp.EnableSSL = $true;
        $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
        $smtp.send($message);
        Write-Host "Text Sent" ; 
        $smtp.Dispose()
    }

    #####################EMAIL - NOTE TO IT DEPT#####################
    $email = "italerts@example.com"
    $date = Get-Date -Format "dddd MM/dd/yyyy"
    $body = @"
COMPANY IT,

New Hire Information, Provisioned: $date

User: $together
Password: $pass
Cell Number: $number

     - COMPANY IT Alerts
"@
    $message = new-object Net.Mail.MailMessage;
    $message.From = "COMPANY IT <italerts@example.com>";
    $message.To.Add($email);
    $message.Subject = "New Hire Info $together";
    $message.Body = $body

    $smtp = new-object Net.Mail.SmtpClient("example-net.mail.eo.outlook.com", "25");
    $smtp.EnableSSL = $true;
    $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
    $smtp.send($message);
    Write-Host "Mail Sent" ;
    $smtp.Dispose()


} #scriptblock

Remove-PSSession $session

############################

#Add Groups to the Cloud User
Import-Module MSOnline
Import-Module ExchangeOnlineManagement
$onlinecreds = Get-Credential
Connect-MsolService -Credential $onlinecreds
Connect-ExchangeOnline -Credential $onlinecreds

$hash = @{
    GROUPNAME1      = 1;
    GROUPNAME2 = 2;
    GROUPNAME3    = 3;
    GROUPNAME4    = 4;
    GROUPNAME5   = 5;
    GROUPNAME6 = 6;
    GROUPNAME7        = 7;
    GROUPNAME8          = 8;
    GROUPNAME9                  = 9;
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
    -Member $upn

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
            -Member $upn
    }
    elseif ($group1 -ne 'y') {
        break
    }
}

$appraiser = Read-Host "Is this user an appraiser? y or n"
if ($appraiser -eq 'y') {
    Write-Host "Adding StopQualityUpdates Group to AAD User"
    Add-MsolGroupMember `
        -GroupObjectId ID-HERE `
        -GroupMemberType User `
        -GroupMemberObjectId $user.ObjectId.Guid
}

Disconnect-ExchangeOnline -Verbose -Confirm:$false

Write-Host 'End of script'
Read-Host -Prompt "Press Enter to Continue..."