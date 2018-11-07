<#
.SYNOPSIS
    Returns the current user of a remote system using a WMIObject.
.DESCRIPTION
    Returns the current user of a remote system.
.PARAMETER hostname
    The hostname of a system you wish to retrieve the current user for. 
.EXAMPLE
    C:\PS> .\getRemoteUser.ps1 -hostname SS2MSP2587
    C:\PS> .\getRemoteUser.ps1 
	Leaving blank will prompt for a hostname
.NOTES
    Author: Gabriel Coones
	Date: 12/28/17
#>

param([Parameter(Mandatory=$true)][string] $hostname)
Get-WMIObject -class Win32_ComputerSystem -ComputerName $hostName | select username