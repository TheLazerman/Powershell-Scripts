$DaysInactive = 60

$time = (Get-Date).Adddays(-($DaysInactive))

Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -ResultPageSize 2000 -resultSetSize $null -Properties Name, OperatingSystem, SamAccountName, DistinguishedName, LastLogonDate| Export-CSV “\\vm-pdq\Report\StaleComps_60day.CSV” –NoTypeInformation