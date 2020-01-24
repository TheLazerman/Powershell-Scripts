Add-Type -AssemblyName System.Speech
    $SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $CatFact = (Invoke-WebRequest -Uri 'https://us-central1-cat-api-fb6de.cloudfunctions.net/fact')
    #$SpeechSynth.SelectVoice('Microsoft Zira Desktop')
    $SpeechSynth.SelectVoice('Microsoft David Desktop')
    $SpeechSynth.Speak("Did you know, "+$CatFact.Content)