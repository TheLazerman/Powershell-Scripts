#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 

#requires -Version 2.0

<#
 	.SYNOPSIS
       This script can be check if Windows is activated.
    .DESCRIPTION
       This script can be check if Windows is activated.
    .PARAMETER  ComputerName
		Check if Windows is activated on the specified computers. The default is the local computer. 
	.EXAMPLE
        C:\PS> C:\Script\CheckIfWindowsIsActivated.ps1

        ApplicationID                          ComputerName                WindowsName                           LicenseStatus                        
        -------------                          ------------                -----------                           -------------                        
        55c92734-d682-4d71-983e-d6ec3f16059f   WIN-FJ67QS                  Windows(R), ServerDatacenter edition  Licensed   

		This example shows how to check if Windows is activated.
#>

Param
(
    [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
    [String[]]$ComputerName = $env:COMPUTERNAME
)

#defined initial data
$LicenseStatus = @("Unlicensed","Licensed","OOB Grace",
"OOT Grace","Non-Genuine Grace","Notification","Extended Grace")

Foreach($CN in $ComputerName)
{
    Get-CimInstance -ClassName SoftwareLicensingProduct -ComputerName $ComputerName |`
    Where{$_.PartialProductKey -and $_.Name -like "*Windows*"} | Select `
    @{Expression={$_.PSComputerName};Name="ComputerName"},`
    @{Expression={$_.Name};Name="WindowsName"} ,ApplicationID,`
    @{Expression={$LicenseStatus[$($_.LicenseStatus)]};Name="LicenseStatus"}
}