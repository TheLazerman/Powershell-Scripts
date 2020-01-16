
$paths = @("C:\Program Files\Microsoft Office\Office14\OSPP.VBS", "C:\Program Files (x86)\Microsoft Office\Office14\OSPP.VBS", "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS", "C:\Program Files\Microsoft Office\Office16\OSPP.VBS")

foreach ($file in $paths){
	if([System.IO.File]::Exists($file)){
	$OSPP = $file
	}
}

cscript.exe $OSPP "/sethst:KMS-SERVER"
cscript.exe $OSPP "/act"
