Get-ADGroupMember -identity "domain users" -Recursive |
Get-ADUser -Property DisplayName | select UserPrincipalName, DistinguishedName | export-csv .\allusers.csv
get-content .\allusers.csv | 
Where-Object { $_ -notmatch '^"\w*\.\w*\@simfoods\.com"'} > .\users.csv