$IsWired = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter "IPEnabled='TRUE'" | ?{($_.Description -notlike "*VMware*") -and ($_.Description -notlike "*Wireless*") -and ($_.Description -notlike "*Hyper-V*")}
if ($IsWired){
	echo "Wired Network Detected"
}else{
	echo "No Wired Network Detected"
}