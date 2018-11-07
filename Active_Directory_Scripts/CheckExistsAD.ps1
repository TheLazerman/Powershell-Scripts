<#
.SYNOPSIS
    Reads a list of Hostnames from a .txt or .csv and queries Active Directory to verify if they exist in the domain. 
	If a system does exist in AD, it's hostname will be added to "ExistsInAD.txt".
	Otherwise, it's hostname will be added to "NotInAD.txt".
	Both of these files are placed wherever the script is located when it is ran. 
.DESCRIPTION
    Verify a hostname exists in Active Directory. 
.PARAMETER hostname
    The hostname of a system you wish to verify is in Active Directory. 
.EXAMPLE
    C:\PS> .\CheckExistsAD.ps1 -hostname SS2MSP2587
    C:\PS> .\CheckExistsAD.ps1 
.EXAMPLE
	C:\PS> .\CheckExistsAD.ps1
	Leave blank and press return, a dialog box will open asking for a .csv or .txt file.
.NOTES
    Author: Gabriel Coones
    Date:   December 21, 2017    
#>

param([Switch] $hostname)

Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv|TXT (*.txt)| *.txt"
    $OpenFileDialog.ShowDialog() | Out-Null
	$OpenFileDialog.filename
	$OpenFileDialog.ShowHelp = $true
}


if (!$hostname){
	Write-Host "Please enter the path to a txt or csv with the hostnames you would like to search"
	$inputfile = Get-FileName "C:\"
	$hostnames = get-content $inputfile
}else
{
$hostnames = $hostname
}

foreach ($server in $hostnames) {
	try {
    if (@(Get-ADComputer $server -ErrorAction SilentlyContinue).Count) {
        Write-Host $server "IS in AD"
		$server >> 'ExsitsInAD.txt'  
    }
	}catch{
		Write-Host $server "Is NOT in AD" -foregroundcolor "red"
		$server >> 'NotInAD.txt'
	}
}

