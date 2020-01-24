#This script will create launch ClamAV to do a secondary scan on the infected Host.

#Parameters for input field set in EPO>Automatic Responses>Actions>Arguments
#Arguments in EPO = C:\EPO_ClamAv_Scan.ps1 {setOfSourceHostName} {setOfSourceIPV4} {setOfSourceMAC} {setOfTargetProcessName} {setOfTargetUserName} {setOfThreatActionTaken} {setOfThreatName} {setOfThreatType}
#Parameters below should match order of EPO Arguments


#testing Variables
$setOfSourceHostName = "SILOF1WL0FL721"

#Parameters from McAfee EPO Server.
Param(
   [Parameter(Position=1)]
   [string]$setOfSourceHostName,
  
   [Parameter(Position=2)]
   [string]$setOfSourceIPV4,
  
   [Parameter(Position=3)]
   [string]$setOfTargetUserName,
 
   [Parameter(Position=4)]
   [string]$setOfThreatActionTaken,

   [Parameter(Position=5)]
   [string]$setOfThreatName,
  
   [Parameter(Position=6)]
   [string]$setOfThreatType,

   [Parameter(Position=7)]
   [string]$setOfTargetFileName
)
$setOfTargetFileName = "C:\Users\eddie.collins\downloads"

#Do the thing
Invoke-Command -ComputerName $setOfSourceHostName ClamAV.ps1 -ArgumentList $setOfTargetFileName