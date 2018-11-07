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

pushd \\simfoods.com\deploymentshare$\
foreach ($server in $hostnames) {
	echo $server
	xcopy "\\simfoods.com\deploymentshare$\Scripts\LiteTouch.vbs" "\\$server\c$\Users\Public\Desktop"
	
}