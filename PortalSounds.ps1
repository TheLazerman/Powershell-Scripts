$num = get-random -Maximum 50 -Minimum 1
$Core = Get-Random -Maximum 3 -Minimum 1
$url = "http://cdn.frustra.org/sounds/sound/vo/core0$Core/babble$num.mp3"
& 'C:\Program Files\VideoLAN\VLC\vlc.exe' --qt-start-minimized --play-and-exit --qt-notification=0 $url
#invoke-command -computername SSWL0B6YLT -ScriptBlock {Start-Process 'C:\Program Files\VideoLAN\VLC\vlc.exe' -Argumentlist '--qt-start-minimized --play-and-exit --qt-notification=0 http://cdn.frustra.org/sounds/sound/vo/core01/babble21.mp3'}
$url