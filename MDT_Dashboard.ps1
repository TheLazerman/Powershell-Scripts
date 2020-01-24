import-Module UniversalDashboard
Get-UDDashboard | Stop-UDDashboard

$Theme = @{
    BackgroundColor = "#444444"
	FontColor = "#FFFFFF"
}

$H1 = @{
	BackgroundColor = "#333333"
	FontColor = "#FFFFFF"
}

#URL to MDT Data
$URL = "http://SSHOMDT:9801/MDTMonitorData/Computers"

#Grab the Data as an XML Element
[xml]$MDTData = (Invoke-webrequest -URI $Url).content

#Parse the XML Data
function ParseMDTData {

	foreach($property in ($MDTData.feed.entry.content.properties) ) {
		
		if($Property.EndTime.null){
			New-Object PSObject -Property @{		
				Name = $($property.Name);
				PercentComplete = $($property.PercentComplete.'#text');
				Warnings = $($property.Warnings.'#text');
				Errors = $($property.Errors.'#text');
				StepName = $($property.StepName.'##text');
				DeploymentStatus = $(
					Switch ($property.DeploymentStatus.'#text') {
						1 { "Active/Running" }
						2 { "Failed" }
						3 { "Completed Successfully" }
						4 { "Unresponsive" }
						Default { "Unknown" }
					}
				);

                DeploymentType = $(
                    if (($property.TotalSteps.'#text' -le 50)) {
                        "New Install"
                    }else{
                        if($property.TotalSteps.'#text' -ge 99){
                            "Upgrade"
                        }else{
                            "Unknown"
                        } 
                    }                                       
                );

				StartTime = $($property.StartTime.'#text') -replace "T"," ";
				LastTime = $($property.LastTime.'#text') -replace "T"," ";
				RunTime = (NEW-TIMESPAN -Start (($property.StartTime.'#text') -replace "T", " ") -End (((Get-Date).AddHours(6)) | Get-Date -uFormat "%H:%m:%S")).ToString("h'h 'm'm 's's'")
			
			}
		}
		else{
			New-Object PSObject -Property @{		
				Name = $($property.Name);
				PercentComplete = $($property.PercentComplete.'#text');
				Warnings = $($property.Warnings.'#text');
				Errors = $($property.Errors.'#text');
				StepName = $($property.StepName.'##text');
				DeploymentStatus = $(
					Switch ($property.DeploymentStatus.'#text') {
						1 {"Active/Running"}
						2 {"Failed"}
						3 {"Completed Successfully"}
						4 {"Unresponsive"}
						Default {"Unknown"}
					}
				);
				DeploymentType = $(
                    if (($property.TotalSteps.'#text' -le 50)) {
                        "New Install"
                    }else{
                        if($property.TotalSteps.'#text' -ge 99){
                            "Upgrade"
                        }else{
                            "Unknown"
                        } 
                    }                                       
                );
				StartTime = $($property.StartTime.'#text') -replace "T"," ";
				EndTime = $($property.EndTime.'#text') -replace "T"," ";
				LastTime = $($property.LastTime.'#text') -replace "T"," ";				
				RunTime = (NEW-TIMESPAN -Start (($property.StartTime.'#text') -replace "T", " ") -End (($property.EndTime.'#text') -replace "T", " ")).ToString("h'h 'm'm 's's'")
			
			}
		}
	}
}

#Store the parsed XML Data in a variable
$Cache:properties = ParseMDTData

$Schedule = New-UdEndpointSchedule -Every 5 -Minute

$EveryFive = New-UDEndpoint -Schedule $Schedule -Endpoint {
    $Cache:properties = ParseMDTData
}


#GetTodays date 
$Today = Get-Date -uFormat "%Y-%m-%d"

#Get Each day of the week by name
#This method is kinda gross but it works
$Yesterday = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
$n = 0
do {
    $Date = (date -Hour 0 -Minute 0 -Second 0).AddDays(-$n)
    $n++
}
Until ( $Date.DayOfWeek -eq "Monday" )
$Monday = ($Date).ToString('yyyy-MM-dd')
$n = 0
do {
    $Date = (date -Hour 0 -Minute 0 -Second 0).AddDays(-$n)
    $n++
}
Until ( $Date.DayOfWeek -eq "Tuesday" )
$Tuesday = ($Date).ToString('yyyy-MM-dd')
$n = 0
do {
    $Date = (date -Hour 0 -Minute 0 -Second 0).AddDays(-$n)
    $n++
}
Until ( $Date.DayOfWeek -eq "Wednesday" )
$Wednesday = ($Date).ToString('yyyy-MM-dd')
$n = 0
do {
    $Date = (date -Hour 0 -Minute 0 -Second 0).AddDays(-$n)
    $n++
}
Until ( $Date.DayOfWeek -eq "Thursday" )
$Thursday = ($Date).ToString('yyyy-MM-dd')
$n = 0
do {
    $Date = (date -Hour 0 -Minute 0 -Second 0).AddDays(-$n)
    $n++
}
Until ( $Date.DayOfWeek -eq "Friday" )
$Friday = ($Date).ToString('yyyy-MM-dd')


#Parse the data further, broken down by date and status, ect
#There HAS to be a better way to do this, but it works ¯\_(ツ)_/¯
$CompleteToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND $_.DeploymentStatus -match 'Completed Successfully'} ).count
$CompleteTotal = @($Cache:properties | ? {$_.DeploymentStatus -match 'Completed Successfully'} ).count
$Running = @($Cache:properties | ? {$_.DeploymentStatus -match 'Active/Running'} ).count
$FailedToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND $_.DeploymentStatus -match 'Failed'} ).count
$FailedTotal = @($Cache:properties | ? {$_.DeploymentStatus -match 'Failed' -OR $_.DeploymentStatus -match 'Unresponsive'} ).count
$UnresponsiveToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND $_.DeploymentStatus -match 'Unresponsive'}).count
$UnresponsiveTotal = @($Cache:properties | ? {$_.DeploymentStatus -match 'Unresponsive'} ).count
$UpgradeToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND $_.DeploymentType -match 'Upgrade'} ).count
$InstallToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND $_.DeploymentType -match 'New Install'} ).count
$UpgradeTotal = @($Cache:properties | ? {$_.DeploymentType -match 'Upgrade'} ).count
$InstallTotal = @($Cache:properties | ? {$_.DeploymentType -match 'New Install'} ).count
$SSWFI = @($Cache:properties | ? { $_.Name -match 'SSWFI'} ).count
$SSHO = @($Cache:properties | ? { $_.Name -match 'SSHO'} ).count
$SSMO = @($Cache:properties | ? { $_.Name -match 'SSMO'} ).count
$SSH = @($Cache:properties | ? { $_.Name -match 'SSHW'} ).count
$SS2 = @($Cache:properties | ? { $_.Name -match 'SS2'} ).count
$SPT = @($Cache:properties | ? { $_.Name -match 'SPT'} ).count
$SSW = @($Cache:properties | ? { $_.Name -match 'SSW'} ).count
$SSBO = @($Cache:properties | ? { $_.Name -match 'SSBO'} ).count
$TOR = @($Cache:properties | ? { $_.Name -match 'TOR'} ).count
$PENN = @($Cache:properties | ? { $_.Name -match 'PEN'} ).count
$VB = @($Cache:properties | ? { $_.Name -match 'VB'} ).count
$SWC = @($Cache:properties | ? { $_.Name -match 'SWC'} ).count
$DCA = @($Cache:properties | ? { $_.Name -match 'DCA'} ).count
$EMP = @($Cache:properties | ? { $_.Name -match 'EMP'} ).count
$BGV = @($Cache:properties | ? {$_.Name -match 'BGV'} ).count
$QKR = @($Cache:properties | ? {$_.Name -match 'QKR'} ).count
$MIL = @($Cache:properties | ? {$_.Name -match 'MIL'} ).count
$DNP = @($Cache:properties | ? {$_.Name -match 'DNP'} ).count
$DSP = @($Cache:properties | ? {$_.Name -match 'DSP'} ).count
$OTHER = @($Cache:properties | ? { $_.Name -match '%ComputerType%'} ).count
$BGVToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND $_.Name -match 'BGV'} ).count
$QKRToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND $_.Name -match 'QKR'} ).count
$MILToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND $_.Name -match 'MIL'} ).count
$DNPToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND $_.Name -match 'DNP'} ).count
$DSPToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND $_.Name -match 'DSP'} ).count
$SSWFIToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'SSWFI'} ).count
$SSHOToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'SSHO'} ).count
$SSMOToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'SSMO'} ).count
$SSHToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'SSHW'} ).count
$SS2Today = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'SS2'} ).count
$SPTToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'SPT'} ).count
$SSWToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'SSW'} ).count
$SSBOToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'SSBO'} ).count
$TORToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'TOR'} ).count
$PENNToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'PEN'} ).count
$VBToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'VB'} ).count
$SWCToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'SWC'} ).count
$DCAToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'DCA'} ).count
$EMPToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match 'EMP'} ).count
$OTHERToday = @($Cache:properties | ? {$_.StartTime -match $Today -AND  $_.Name -match '%ComputerType%'} ).count




#Setup Page 1 on our dashboard
$Page1 = New-UDPage -Name "Home" -Icon home -Content {
	New-UDCard  -Title "At A Glance" @H1 -Content { 
		#Row 1
		New-UDRow {	
			#Coloumn 1
			New-UDColumn -Size 2 {
				New-UDCounter -Title "Total Today" -RefreshInterval 60  @Theme -Endpoint {
					@($Cache:properties | ? {$_.StartTime -match $Today} ).count | ConvertTo-Json
				}
			}
			
			#Coloumn 2
			New-UDColumn -Size 2 {
				New-UDCounter -Title "Completed Today" -RefreshInterval 60  @Theme -Endpoint {
					$CompleteToday | ConvertTo-Json
				}
			}
			
			#Coloumn 3
			New-UDColumn -Size 2 {
				New-UDCounter -Title "Upgrades Today" -RefreshInterval 60  @Theme -Endpoint {
					$UpgradeToday | ConvertTo-Json
				}
			}
			
			#Coloumn 4
			New-UDColumn -Size 2 {
				New-UDCounter -Title "New Installs Today" -RefreshInterval 60  @Theme -Endpoint {
					$InstallToday | ConvertTo-Json
				}
			}
			
			#Coloumn 5
			New-UDColumn -Size 2 {
				New-UDCounter -Title "Total Yesterday" -RefreshInterval 60  @Theme -Endpoint {
					@($Cache:properties | ? {$_.StartTime -match $Yesterday} ).count | ConvertTo-Json
				}
			}
			
			#Coloumn 6
			New-UDColumn -Size 2 {
				New-UDCounter -Title "Last 7 days" -RefreshInterval 60  @Theme -Endpoint {
					@($Cache:properties | ? {$_.Name -ne "null"} ).count | ConvertTo-Json
				}
			}
		}
		
		#Row 2
		New-UDRow {			
			$TodaysTypeData = @(
				@{DeployType="Upgrade";Count=$UpgradeToday}
				@{DeployType="Install";Count=$InstallToday}			
			)
			
			$TodaysStatusData = @(
				@{Status="Running";Count=$Running}
				@{Status="Complete";Count=$CompleteToday}
				@{Status="Failed";Count=$FailedToday}
				@{Status="Unresponsive";Count=$UnresponsiveToday}
			)
			
			$TodayLocationData = @(
				@{Location="SSHO";Count=$SSHOToday}
				@{Location="SSMO";Count=$SSMOToday}
				@{Location="SSH";Count=$SSHToday}
				@{Location="SS2";Count=$SS2Today}
				@{Location="SPT";Count=$SPTToday}
				@{Location="SSWFI";Count=$SSWFIToday}
				@{Location="SSW";Count=$SSWToday}
				@{Location="SSBO";Count=$SSBOToday}
				@{Location="SSFIO";Count=$SSFIOToday}
				@{Location="VB";Count=$VBToday}
				@{Location="DCA";Count=$DCAToday}
				@{Location="DNP";Count=$DNPToday}
				@{Location="DSP";Count=$DSPToday}
				@{Location="TOR";Count=$TORToday}
				@{Location="PENN";Count=$PENNToday}
				@{Location="SWC";Count=$SWCToday}
				@{Location="EMP";Count=$EMPToday}
				@{Location="MIL";Count=$MILToday}
				@{Location="QKR";Count=$QKRToday}
				@{Location="BGV";Count=$BGVToday}
				@{Location="Unknown";Count=$OTHERToday}				
			)
			
			#Coloumn 1
			New-UDColumn -Size 4 {
				New-UDChart -Title "Deployments Today - By Status" -Type "Doughnut"  @Theme -Endpoint {				
					$TodaysStatusData | Out-UDChartData -LabelProperty "Status"  -Dataset @(
					New-UDChartDataset -Label "Status" -DataProperty Count -BackgroundColor @("#FF6739b7", "#FF439F46", "#FFC8102E", "#FFFDC928") -BorderColor @("#000000", "#000000", "#000000", "#000000") -BorderWidth 1
					)
				} -Options @{cutoutPercentage = 0}
			}
			
			#Coloumn 2
			New-UDColumn -Size 4 {
				New-UDChart -Title "Deployments Today - By Type" -Type "Doughnut"  @Theme -Endpoint {				
					$TodaysTypeData | Out-UDChartData -LabelProperty "DeployType"  -Dataset @(
					New-UDChartDataset -Label "DeployType" -DataProperty Count -BackgroundColor @("#FF004C97", "#FFED8B00") -BorderColor @("#000000", "#000000") -BorderWidth 1
					)
				} -Options @{cutoutPercentage = 0}
			}
			
			#Coloumn 3
			New-UDColumn -Size 4 {
				New-UDChart -Title "Total Deployments - By Location" -Type "pie" @Theme -Endpoint {				
					$TodayLocationData | Out-UDChartData -LabelProperty "Location"  -Dataset @(
					New-UDChartDataset -Label "Location" -DataProperty Count -BackgroundColor @("#FF004C97", "#FFC8102E", "#FF439F46", "#FFFDC928", "#FFED8B00", "#FF6739b7", "#FF63A46C", "#FF59C3C3", "#FFE8DB7D", "#FF558C8C", "#FFCF5C36", "#FFEFF7FF", "#FF35FF69", "#FFE94F37", "#FF41EAD4", "#FF81F0E5", "#FFFCF6B1", "#FFA499B3", "#FFD33F49", "#FF3772FF", "#FFC17767", "#FF9DB4C0", "#FFAA4465", "#FFC43532", "#FFEBD23F", "#FF6B0504") -BorderColor @("#000000", "#000000", "#000000","#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000") -HoverBackgroundColor "#80FFFFFF" -HoverBorderColor "#80FFFFFF" -BorderWidth 1
					)
				} -Options @{cutoutPercentage = 0}
			}
			
		}
		
		
		#Row 3
		New-UDRow {
			#Coloumn 1
			New-UDColumn -Size 4 {
				$Failures = $FailedToday + $UnresponsiveToday
                New-UDGrid -Title "Failed Deployments - $Failures Today" -Headers @("Name", "Deployment Type", "RunTime", "Percent Complete") -Properties @("Name", "DeploymentType", "RunTime", "PercentComplete") -RefreshInterval 60   @Theme -Endpoint {
                    $Cache:properties | ? {$_.StartTime -match $Today -AND ($_.DeploymentStatus -match 'Failed' -OR $_.DeploymentStatus -match 'Unresponsive')}  | Out-UDGridData
                }
            }			
			
			#Coloumn 2
            New-UDColumn -size 4 {
				New-UDGrid -Title "Completed Deployments - $CompleteToday Today " -Headers @("Name", "Deployment Type", "RunTime", "Percent Complete") -Properties @("Name", "DeploymentType", "RunTime", "PercentComplete") -RefreshInterval 60  @Theme -Endpoint {
				  $Cache:properties | ? {$_.StartTime -match $Today -AND $_.DeploymentStatus -match 'Completed Successfully'}  | Out-UDGridData
                }                
            }
			
			#Coloumn 3			
			New-UDColumn -Size 4 {
                New-UDGrid -Title "Running Deployments - $Running" -Headers @("Name", "Deployment Type", "RunTime", "Percent Complete") -Properties @("Name", "DeploymentType", "RunTime",  "PercentComplete") -RefreshInterval 60  @Theme -Endpoint {
                  $Cache:properties | ? {$_.DeploymentStatus -match 'Active/Running'}  | Out-UDGridData
                }
            }
        }
		
	}
}

$Page2 = New-UDPage -Name "Overview" -Icon binoculars -Content {
	New-UDCard  -Title "Overview - Day By Day" @H1 -Content {
			
			$DeploymentsByDayData = @(
				@{DeploymentsByDayData="Monday";Count=@($Cache:properties | ? {$_.StartTime -match $Monday} ).count}
				@{DeploymentsByDayData="Tuesday";Count=@($Cache:properties | ? {$_.StartTime -match $Tuesday} ).count}
				@{DeploymentsByDayData="Wednesday";Count=@($Cache:properties | ? {$_.StartTime -match $Wednesday} ).count}
				@{DeploymentsByDayData="Thursday";Count=@($Cache:properties | ? {$_.StartTime -match $Thursday} ).count}
				@{DeploymentsByDayData="Friday";Count=@($Cache:properties | ? {$_.StartTime -match $Friday} ).count}
			)
			
			$UpgradesByDayData = @(
				@{UpgradesByDayData="Monday";Count=@($Cache:properties | ? {$_.StartTime -match $Monday -AND $_.DeploymentType -match "Upgrade"} ).count}
				@{UpgradesByDayData="Tuesday";Count=@($Cache:properties | ? {$_.StartTime -match $Tuesday -AND $_.DeploymentType -match "Upgrade"} ).count}
				@{UpgradesByDayData="Wednesday";Count=@($Cache:properties | ? {$_.StartTime -match $Wednesday -AND $_.DeploymentType -match "Upgrade"} ).count}
				@{UpgradesByDayData="Thursday";Count=@($Cache:properties | ? {$_.StartTime -match $Thursday -AND $_.DeploymentType -match "Upgrade"} ).count}
				@{UpgradesByDayData="Friday";Count=@($Cache:properties | ? {$_.StartTime -match $Friday -AND $_.DeploymentType -match "Upgrade"} ).count}
			)

			$FailuresByDayData = @(
				@{FailuresByDayData="Monday";Count=@($Cache:properties | ? {$_.StartTime -match $Monday -AND $_.DeploymentStatus -match "Failed" -OR $_.StartTime -match $Monday -AND $_.DeploymentStatus -match "Unresponsive"} ).count}
				@{FailuresByDayData="Tuesday";Count=@($Cache:properties | ? {$_.StartTime -match $Tuesday -AND $_.DeploymentStatus -match "Failed" -OR $_.StartTime -match $Tuesday -AND $_.DeploymentStatus -match "Unresponsive"} ).count}
				@{FailuresByDayData="Wednesday";Count=@($Cache:properties | ? {$_.StartTime -match $Wednesday -AND $_.DeploymentStatus -match "Failed" -OR $_.StartTime -match $Wednesday -AND $_.DeploymentStatus -match "Unresponsive"} ).count}
				@{FailuresByDayData="Thursday";Count=@($Cache:properties | ? {$_.StartTime -match $Thursday -AND $_.DeploymentStatus -match "Failed" -OR $_.StartTime -match $Thursday -AND $_.DeploymentStatus -match "Unresponsive"} ).count}
				@{FailuresByDayData="Friday";Count=@($Cache:properties | ? {$_.StartTime -match $Friday -AND $_.DeploymentStatus -match "Failed" -OR $_.StartTime -match $Friday -AND $_.DeploymentStatus -match "Unresponsive"} ).count}
			)
			
			$NewByDayData = @(
				@{NewByDayData="Monday";Count=@($Cache:properties | ? {$_.StartTime -match $Monday -AND $_.DeploymentType -match "New Install"} ).count}
				@{NewByDayData="Tuesday";Count=@($Cache:properties | ? {$_.StartTime -match $Tuesday -AND $_.DeploymentType -match "New Install"} ).count}
				@{NewByDayData="Wednesday";Count=@($Cache:properties | ? {$_.StartTime -match $Wednesday -AND $_.DeploymentType -match "New Install"} ).count}
				@{NewByDayData="Thursday";Count=@($Cache:properties | ? {$_.StartTime -match $Thursday -AND $_.DeploymentType -match "New Install"} ).count}
				@{NewByDayData="Friday";Count=@($Cache:properties | ? {$_.StartTime -match $Friday -AND $_.DeploymentType -match "New Install"} ).count}
			)
			
			$LocationData = @(
				@{Location="SSHO";Count=$SSHO}
				@{Location="SSMO";Count=$SSMO}
				@{Location="SSH";Count=$SSH}
				@{Location="SS2";Count=$SS2}
				@{Location="SPT";Count=$SPT}
				@{Location="SSWFI";Count=$SSWFI}
				@{Location="SSW";Count=$SSW}
				@{Location="SSBO";Count=$SSBO}
				@{Location="SSFIO";Count=$SSFIO}
				@{Location="VB";Count=$VB}
				@{Location="DCA";Count=$DCA}
				@{Location="DNP";Count=$DNP}
				@{Location="DSP";Count=$DSP}
				@{Location="TOR";Count=$TOR}
				@{Location="PENN";Count=$PENN}
				@{Location="SWC";Count=$SWC}
				@{Location="EMP";Count=$EMP}
				@{Location="MIL";Count=$MIL}
				@{Location="QKR";Count=$QKR}
				@{Location="BGV";Count=$BGV}
				@{Location="Unknown";Count=$OTHER}				
			)
	
		New-UDRow {
		
			New-UDColumn -Size 4 {
				New-UDChart -Title "Upgrades - By Day" -Type "Line" @Theme -Endpoint {
					$UpgradesByDayData | Out-UDChartData -LabelProperty "UpgradesByDayData" -DataProperty "Count" -DatasetLabel "Count" -BackgroundColor @("#FF004C97", "#FF6739b7", "#FF439F46", "#FFFDC928", "#FF004C97") -BorderColor @("#000000", "#000000", "#000000", "#000000", "#000000")  -HoverBackgroundColor "#80FFFFFF" -HoverBorderColor "#80FFFFFF" 
				} -Options @{cutoutPercentage = 0}
			}
			
			New-UDColumn -Size 4 {
				New-UDChart -Title "New Deployments - By Day" -Type "Line" @Theme -Endpoint {
					$NewByDayData | Out-UDChartData -LabelProperty "NewByDayData" -DataProperty "Count" -DatasetLabel "Count" -BackgroundColor @("#FF439F46", "#FF6739b7", "#FF439F46", "#FFFDC928", "#FF004C97") -BorderColor @("#000000", "#000000", "#000000", "#000000", "#000000")  -HoverBackgroundColor "#80FFFFFF" -HoverBorderColor "#80FFFFFF" 
				} -Options @{cutoutPercentage = 0}
			}
			
			New-UDColumn -Size 4 {
				New-UDChart -Title "Failures - By Day" -Type "Line"  @Theme -Endpoint {				
					$FailuresByDayData | Out-UDChartData -LabelProperty "FailuresByDayData"  -Dataset @(
					New-UDChartDataset -Label "Count" -DataProperty Count -BackgroundColor @("#FFC8102E", "#FF6739b7", "#FF439F46", "#FFFDC928", "#FF004C97") -BorderColor @("#000000", "#000000", "#000000", "#000000", "#000000")  -HoverBackgroundColor "#80FFFFFF" -HoverBorderColor "#80FFFFFF" -BorderWidth 1
					)
				} -Options @{cutoutPercentage = 0}
			}			
		}
		
		New-UDRow{
			
			New-UDColumn -Size 6 {
				New-UDChart -Title "Total Deployments - By Day" -Type "bar" @Theme -Endpoint {
					$DeploymentsByDayData | Out-UDChartData -LabelProperty "DeploymentsByDayData" -DataProperty "Count" -DatasetLabel "Count" -BackgroundColor "#FFED8B00" -BorderColor "#000000" -HoverBackgroundColor "#80FFFFFF" -HoverBorderColor "#80FFFFFF"
				}
			}
						
			New-UDColumn -Size 6 {
				New-UDChart -Title "Total Deployments - By Location" -Type "pie" @Theme -Endpoint {				
					$LocationData | Out-UDChartData -LabelProperty "Location"  -Dataset @(
					New-UDChartDataset -Label "Location" -DataProperty Count -BackgroundColor @("#FF004C97", "#FFC8102E", "#FF439F46", "#FFFDC928", "#FFED8B00", "#FF6739b7", "#FF63A46C", "#FF59C3C3", "#FFE8DB7D", "#FF558C8C", "#FFCF5C36", "#FFEFF7FF", "#FF35FF69", "#FFE94F37", "#FF41EAD4", "#FF81F0E5", "#FFFCF6B1", "#FFA499B3", "#FFD33F49", "#FF3772FF", "#FFC17767", "#FF9DB4C0", "#FFAA4465", "#FFC43532", "#FFEBD23F", "#FF6B0504") -BorderColor @("#000000", "#000000", "#000000","#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000") -HoverBackgroundColor "#80FFFFFF" -HoverBorderColor "#80FFFFFF" -BorderWidth 1
					)
				} -Options @{cutoutPercentage = 0}
			}
		}
	}
}

$Page3 = New-UDPage -Name "All Deployments" -Icon calendar -Content {
	New-UDCard  -Title "All Deployments" @H1 -Content {
	
		New-UDColumn -Size 12{
				New-UDGrid -Title "All Recent Deployments" -Headers @("Name", "DeploymentStatus", "PercentComplete", "DeploymentType", "RunTime", "StepName", "StartTime", "EndTime") -Properties @("Name", 		"DeploymentStatus", "PercentComplete", "DeploymentType", "RunTime", "StepName", "StartTime", "EndTime") -RefreshInterval 60  @Theme -Endpoint {
					$Cache:properties | Out-UDGridData
				} -DateTimeFormat 'LLLL'
			}
		}
	}

$Dashboard = New-UDDashboard -Title "Simmons Windows Deployment Monitoring" -NavBarColor '#004C97' -NavBarFontColor "#000000"  @H1 -Pages @($Page1, $Page2, $Page3) -CyclePages -CyclePagesInterval 120
Start-UDDashboard -Dashboard $Dashboard -Port 80 -Endpoint @($EveryFive) -AutoReload


#Simmons Colors:
#Blue
#FF004C97

#Red
#FFC8102E

#White
#FFFFFFFF

#Gray
#FF444444

#Concrete
#FF999999

#Stainless Gray
#FFEEEEEE

#Fresh Green
#FF439F46

#Harvest Yellow
#FFFDC928

#Sunset Orange
#FFED8B00

#Bright Purple
#FF6739b7

#########
#FFE15554
#FFFFC857
#FFF5E663
#FFCAD178
#FFB0BEA9
#FF3E5C76
#FF87C38F
#FF41EAD4
#FF59C3C3
#FFE8DB7D
#FF558C8C
#FFCF5C36
#FFEFF7FF
#FF686868


