If (!(Test-Path HKCR:)) 
{ 
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT 
} 
$searchScopes = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings","HKLM:\Software\Microsoft\Windows\CurrentVersion\explorer\Browser Helper Objects" 
$searchScopes | Get-ChildItem -Recurse | Select -ExpandProperty PSChildName |  
ForEach-Object { 
 If (Test-Path "HKCR:\CLSID\$_") { 
    Get-ItemProperty -Path "HKCR:\CLSID\$_" | Select-Object @{n="Name";e="(default)"} 
 } 
} | 
Sort-Object -Unique -Property Name | Export-Csv "C:\IEAdd-Ons.csv" -NoTypeInformation 