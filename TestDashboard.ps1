Get-UDDashboard | Stop-UDDashboard

Import-Module UniversalDashboard

$Schedule = New-UDEndpointSchedule -Every 10 -Minute
$Endpoint = New-UDEndpoint -Schedule $Schedule -Endpoint{
$ForcastURL = 'http://api.openweathermap.org/data/2.5/forecast?id=4110486&APPID=82af95393ed7574bd212dc7fc6ee115f'
$CurrentURL = 'http://api.openweathermap.org/data/2.5/weather?id=4110486&APPID=82af95393ed7574bd212dc7fc6ee115f'
$Cache:Forcast = (Invoke-WebRequest -URI $ForcastURL)
$Cache:Current = (Invoke-WebRequest -URI $CurrentURL)
$Forcast = ConvertFrom-Json -Inputobject $Cache:Forcast
$Current = ConvertFrom-Json -Inputobject $Cache:Current
}


#Setup Page 1 on our dashboard
$Page1 = New-UDPage -Name "home" -Icon home -Content{
	New-UDCard  -Title "At A Glance" -Content { 
		#Row 1
		New-UDRow {	
			#Coloumn 1
			New-UDColumn -Size 2 {
				New-UDCounter -Title "Current Temp" -Format "00.0" -AutoRefresh -RefreshInterval 600 -Endpoint{
                        (($Current.main.temp - 273.15) * (9/5) + 32)
                 }
			}
			
			#Coloumn 2
			New-UDColumn -Size 2 {
				New-UDParagraph -Title ($Current.main.humidity) -AutoRefresh -RefreshInterval 600 -Endpoint{
                        'Humidity'
                   }
			}
		}
    }
}

$Dashboard = New-UDDashboard -Title "Test Dashboard" -Pages @($Page1)

Start-UDDashboard -Dashboard $Dashboard -Endpoint $Endpoint -Port 80