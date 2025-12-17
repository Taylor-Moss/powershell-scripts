##########EMAIL#############
$firstName = Read-Host "Enter the Users' First Name"
$lastName = Read-Host "Enter the Users' Last Name"
$together = $firstName + "." + $lastName
$pass = Read-Host "Enter their password"
$number = Read-Host "Enter The Users' Cell Number"

$Username = "it@example.com";
$Password = "password-here";
$email = "it@example.com"
$date = Get-Date -Format "dddd MM/dd/yyyy"
$body = @"
Company IT,

New Hire Information $date

User: $together
Password: $pass
Number: $number

     - Company IT Alerts
"@
$message = new-object Net.Mail.MailMessage;
$message.From = "IT <it@example.com>";
$message.To.Add($email);
$message.Subject = "New Hire Info $date";
$message.Body = $body
   
$smtp = new-object Net.Mail.SmtpClient("domain.xxxx.xx.outlook.com", "25");
$smtp.EnableSSL = $true;
$smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
$smtp.send($message);
write-host "Mail Sent" ; 
$smtp.Dispose()

##########SMS#############
$Username = "it@example.com";
$Password = "password-here";
$ext = Read-Host "Enter The Users' Cell Carrier"

switch ($ext) {
    'Verizon' { Set-Variable -Name ext -Value "@vtext.com" }
    'ATT' { Set-Variable -Name ext -Value "@txt.att.net" }
}
        
$email = $number.replace("-", "") + $ext

$body = @"

Dear $firstName,

PC/Email/iCloud:

User: $together
Password: $pass
Number: $number

     - Company IT Team
"@
$message = new-object Net.Mail.MailMessage;
$message.From = "Company IT <it@example.com>";
$message.To.Add($email);
$message.Subject = "Welcome to Company!";
$message.Body = $body
$message.IsBodyHtml = $false
   
$smtp = new-object Net.Mail.SmtpClient("domain.xxxx.xx.outlook.com", "25");
$smtp.EnableSSL = $true;
$smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
$smtp.send($message);
Write-Host "Text Sent" ; 
$smtp.Dispose()