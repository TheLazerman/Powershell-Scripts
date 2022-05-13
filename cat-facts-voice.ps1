[void][System.Reflection.Assembly]::LoadWithPartialName("System.Speech");
function CatFact {
	    $CatFact = (Invoke-WebRequest -Uri 'https://us-central1-cat-api-fb6de.cloudfunctions.net/fact')
    #$SpeechSynth.SelectVoice('Microsoft Zira Desktop')
    $speaker.SelectVoice('Microsoft David Desktop')
    $speaker.Speak("Did you know, "+$CatFact.Content)
}


##Setup the speaker, this allows the computer to talk
$speaker = [System.Speech.Synthesis.SpeechSynthesizer]::new();
$speaker.SelectVoice("Microsoft Zira Desktop");
##Setup the Speech Recognition Engine, this allows the computer to listen
$speechRecogEng = [System.Speech.Recognition.SpeechRecognitionEngine]::new();
## Setup Keywords for voice commands
$keywords = @("cat fact")
## Load keywords into grammerBuilder

write-host "Loading commands..." -foreground "white"

$ii=0;
foreach($key in $keywords) {
  $i = [System.Speech.Recognition.GrammarBuilder]::new();
  $i.Append($key);
  $speechRecogEng.LoadGrammar($i);
  $i = $ii + 1
}

## Setup Listener
$speechRecogEng.InitialSilenceTimeout = 0 # Time delay for listening
$speechRecogEng.SetInputToDefaultAudioDevice();
$cmdBoolean = $false;
write-host "Enabling listen mode..." -foreground "yellow"


## Do something with the command found

while (!$cmdBoolean) {
  $speechRecognize = $speechRecogEng.Recognize();
  $conf = $speechRecognize.Confidence;
  $myWords = $speechRecognize.text;
  if ($myWords -match "cat fact" -and [double]$conf -gt 0.85) {
    catfact
  }
}
