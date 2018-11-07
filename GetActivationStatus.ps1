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

param([Parameter(Mandatory=$true)][string] $hostname)

function Get-ActivationStatus {
[CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DNSHostName = $hostname
    )
    process {
        try {
            $wpa = Get-WmiObject SoftwareLicensingProduct -ComputerName $DNSHostName `
            -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" `
            -Property LicenseStatus -ErrorAction Stop
        } catch {
            $status = New-Object ComponentModel.Win32Exception ($_.Exception.ErrorCode)
            $wpa = $null    
        }
        $out = New-Object psobject -Property @{
            ComputerName = $DNSHostName;
            Status = [string]::Empty;
        }
        if ($wpa) {
            :outer foreach($item in $wpa) {
                switch ($item.LicenseStatus) {
                    0 {$out.Status = "Unlicensed"}
                    1 {$out.Status = "Licensed"; break outer}
                    2 {$out.Status = "Out-Of-Box Grace Period"; break outer}
                    3 {$out.Status = "Out-Of-Tolerance Grace Period"; break outer}
                    4 {$out.Status = "Non-Genuine Grace Period"; break outer}
                    5 {$out.Status = "Notification"; break outer}
                    6 {$out.Status = "Extended Grace"; break outer}
                    default {$out.Status = "Unknown value"}
                }
            }
        } else {$out.Status = $status.Message}
        $out
    }
}

Get-ActivationStatus