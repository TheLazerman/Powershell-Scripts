#Import the Active Directory Module
import-module activedirectory

ipconfig /flushdns
Start-Sleep 3

#Define an empty array to store computers with duplicate IP address registrations in DNS
$duplicate_comp = @()
$csvFileName = "C:\DNSDuplicates.csv"
#Get all computers in the current Active Directory domain along with the IPv4 address
#The IPv4 address is not a property on the computer account so a DNS lookup is performed
#The list of computers is sorted based on IPv4 address and assigned to the variable $comp
$comp = get-adcomputer -filter * -properties ipv4address | sort-object -property ipv4address

#For each computer object returned, assign just a sorted list of all 
#of the IPv4 addresses for each computer to $sorted_ipv4
$sorted_ipv4 = $comp | foreach {$_.ipv4address} | sort-object

#For each computer object returned, assign just a sorted, unique list 
#of all of the IPv4 addresses for each computer to $unique_ipv4
$unique_ipv4 = $comp | foreach {$_.ipv4address} | sort-object | get-unique

#compare $unique_ipv4 to $sorted_ipv4 and assign just the additional 
#IPv4 addresses in $sorted_ipv4 to $duplicate_ipv4
$duplicate_ipv4 = Compare-object -referenceobject $unique_ipv4 -differenceobject $sorted_ipv4 | foreach {$_.inputobject} | Where-Object {$_ -notmatch "10.17.95" } | Where-Object {$_ -notmatch "10.2.95" } | Where-Object {$_ -notmatch "10.20.13.121" }

#For each instance in $duplicate_ipv4 and for each instance 
#in $comp, compare $duplicate_ipv4 to $comp If they are equal, assign
#the computer object to array $duplicate_comp
foreach ($duplicate_inst in $duplicate_ipv4)
{
    foreach ($comp_inst in $comp)
    {
        if (!($duplicate_inst.compareto($comp_inst.ipv4address)))
        {
            $duplicate_comp = $duplicate_comp + $comp_inst
        }
    }
}

#Pipe all of the duplicate computers to a formatted table and a csv file
$duplicate_comp | ft name,ipv4address -a
$duplicate_comp | Export-CSV $csvFileName -NoTypeInformation
#write-host This list can be found at $csvFileName //No one is going to see this...

$Server = "smtp.simfoods.com"
$Port = 443
$FromEmail = "noreply@simfoods.com"
$ToEmail = "gabriel.coones@simfoods.com"
$attachmentpath = $csvFileName
$message = New-Object System.Net.Mail.MailMessage $FromEmail, $ToEmail
$message.Subject = "DNS Duplicates Report"
$message.IsBodyHTML = $true

$items = New-Object System.Collections.Generic.List[System.Object]
foreach ($log in $duplicate_comp) {
$items.Add($log.name + " " + $log.ipv4address) 
}

if ($items.count -gt 0){
	foreach ($line in $items)
	{
		$message.Body = $message.Body + $line + "`r `n"
	}
$attachment = New-Object Net.Mail.Attachment($attachmentpath)
$message.Attachments.Add($attachment)
}
else{
write-host "No duplicates found in DNS"
$message.Body = "No duplicates found in DNS"
}


$smtp = New-Object System.Net.Mail.SmtpClient($Server, $Port); #Create SMTPClient and connect to Email Server
$smtp.EnableSSL = $true     #Set SSL as enabled
$smtp.Credentials = New-Object System.Net.NetworkCredential($FromEmail);  #Log in to the email server

$smtp.Send($message)  #Send Message
$message.Dispose()  #Destroy Message

