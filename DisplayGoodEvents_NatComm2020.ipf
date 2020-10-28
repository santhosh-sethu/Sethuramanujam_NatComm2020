#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Displays only events within the set parameters (amplitude, decay, rise)
// Creates an indexWave which is used by pairedViewer/event_Viewer files.
function DisplayGoodEvents()

string wavenames, tracename
//KillWaves/A/Z
wave amplitude, decaytau, risetimeX
//wavenames = wavelist("EventCutOut_*",";","CMPLX:0")
wavenames = tracenamelist("",";",1)

variable i, j = 0, k


variable RiseStart, RiseEnd = 1000, DecayStart, DecayEnd = 1000, AndOr, lineUP
variable AmpStart = 0, AmpEnd = 1000

prompt AmpStart, "Amplitude start (ms):"
prompt AmpEnd, "Amplitude end (ms):"
prompt RiseStart, "Rise Time start (ms):"
prompt RiseEnd, "Rise Time end (ms):"
prompt DecayStart, "Decay Time start (ms):"
prompt DecayEnd, "Decay Time end (ms):"
prompt AndOr, "Both conditions required? (Yes = 1):"
DoPrompt "Cutoff criterion:", AmpStart, AmpEnd, RiseStart, RiseEnd, DecayStart, DecayEnd, AndOr
wave SOURCE
DoWindow good_events
if(V_Flag)
	DoWindow /k good_events
	display /N = good_events
else
	display /N = good_events
endif
variable V_minloc, V_min
string waveX
tracename = StringFromList(0,wavenames)
print tracename
duplicate/O $tracename, SOURCE
variable wavelength = numpnts(SOURCE)
Make/O/N = (wavelength) , SOURCE1

make/O/N = 0, WaveIndex

if (AndOr == 1)
	for (i = 0; i < numpnts(amplitude) ; i = i+1)
		if(abs(amplitude(i)) >AmpStart && abs(amplitude(i)) < AmpEnd)
			if (risetimeX(i) >RiseStart && risetimeX(i) < RiseEnd)
				if (decaytau(i) > DecayStart && decaytau(i) < Decayend)
					InsertPoints j,1, WaveIndex
					waveIndex[j] = i
					tracename = StringFromList(i,wavenames)
					print tracename
					Appendtograph/W = good_events $tracename
					j = j+1
				endif
			endif
		endif
	endfor
else
	for (i = 0; i < numpnts(amplitude) ; i = i+1)
			if(abs(amplitude(i)) >AmpStart && abs(amplitude(i)) < AmpEnd)
				InsertPoints j,1, WaveIndex
				waveIndex[j] = i
				tracename = StringFromList(i,wavenames)
				Appendtograph/W = good_events $tracename
				j = j+1
			elseif (risetimeX(i) >RiseStart && risetimeX(i) < RiseEnd)
				tracename = StringFromList(i,wavenames)
				Appendtograph/W = good_events $tracename
				j = j+1
			elseif (decaytau(i) > DecayStart && decaytau(i) < Decayend)
				tracename = StringFromList(i,wavenames)
				Appendtograph/W = good_events $tracename
				j = j+1
			endif
	endfor
endif


print j

end