Const SAFT48kHz16BitStereo = 39
Const SSFMCreateForWrite = 3 

Dim oFileStream, oVoice

Set oFileStream = CreateObject("SAPI.SpFileStream")
oFileStream.Format.Type = SAFT48kHz16BitStereo
oFileStream.Open "./speak2.wav", SSFMCreateForWrite

Set oVoice = CreateObject("SAPI.SpVoice")
Set oVoice.AudioOutputStream = oFileStream

oVoice.Speak "Ask your doctor if zygardalveceptduradomide is right for you."

oFileStream.Close
