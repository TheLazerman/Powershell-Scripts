$Path = Get-ChildItem "C:\Users" -Force -Directory
$DirectoryToCopy = "RFgen5"
Foreach ($User in $Path)
	{
		$FullPath = "C:\Users\" + $User + "\AppData\Roaming\"
		write-host "Copying " $DirectoryToCopy " To " $FullPath
		Copy-Item -Path $DirectoryToCopy -Destination $FullPath -Recurse -Force
	}	