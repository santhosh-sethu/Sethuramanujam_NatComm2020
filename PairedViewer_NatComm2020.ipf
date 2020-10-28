#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Used to view, and calculate paramaters of correlated currents/events in 2 cells.
// IndexWaveName - the wave containing indices of selected events which is created by displayGoodEvents.
// Extracts the peak, baseline noise, decay constant, rise time and time to 50% of peak (relative to the peak) of events.

function PairedViewer(wavestring, IndexWaveName)

string wavestring, IndexWaveName

Newdatafolder/O/S root:PairedAnalysis

string/G Gwavestring1 = wavestring+"_1" //Channel1 wavelist
string/G Gwavestring2 = wavestring+"_2" //Channel2 wavelist
string/G GIndexWaveName = IndexWaveName
string/G GFolderPath1 = "root:"+Gwavestring1+":"
string/G GFolderPath2 = "root:"+Gwavestring2+":"

dowindow PairedViewer // Creating the window PairedViewer
if(V_flag)
	DoWindow /F PairedViewer
else
	display /N = PairedViewer
endif
make/o /n = 1 eventno

ShowInfo
ControlBar 100

string tracename
variable wave_no = 0
variable inward = 1
prompt inward, "outward?"
DoPrompt " outward = 0 and inward = 1", inward //EPSCs = 1
make/o/n =1 orientation
orientation = inward

string/G Gwavenames1, Gwavenames2
setdatafolder GfolderPath1
Gwavenames1 = wavelist(Gwavestring1+"*",";","")
setdatafolder GfolderPath2
Gwavenames2 = wavelist(Gwavestring2+"*",";","")
setdatafolder root:PairedAnalysis
wave_no = itemsinlist(Gwavenames1)
print wave_no


MakeParamWaves(Gwavestring1,wave_no)
MakeParamWaves(Gwavestring2,wave_no)

//Controls for pairedViewer
DoWindow /F PairedViewer
Button buttonUpdate proc=PairedTraceUpdate
Button buttonUpdate title="update"
SetVariable setvarPair title="event no",proc = PairedTraceUpdate, value=eventno[0], size={90,16},limits={1,10000,1}
Button buttonD proc=decayP_buttonProc
Button buttonD title="decaytau"
Button buttonR proc=riseP_buttonProc
Button buttonR title="risetime, peak, noise"
Button button4 title = "ALL", proc = AllParamP
button buttonSync title = "RiseDelta", proc = RiseDelta

end

//////////////////////////////////////////////event update//////////////////////////////////////////////////////////////////////////////////////
//function which updates the viewer window to show event pairs.
Function PairedTraceUpdate(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	SVAR Gwavenames1, Gwavenames2
	SVAR Gwavestring1, Gwavestring2
	SVAR GIndexWaveName
	string wavenames,tracename
	wavenames = TraceNameList("",";",1) // the names of all the waves in the window
	variable wave_no = 0, i, j, no_pts, baseline
	string wavestring
	wave_no = itemsinlist(wavenames)

	for (i = 0;i <wave_no;i+=1) // remove all the waves in the window
		tracename = StringFromList(i,wavenames)
		RemoveFromGraph $tracename
	endfor
		
	wave eventno, IndexWave = $GIndexWaveName
	string eventname1, eventname2
	//selecting the new waves to be displayed
	eventname1 = "root:"+Gwavestring1+":"+stringfromlist(IndexWave[eventno[0]-1],Gwavenames1)
	eventname2 = "root:"+Gwavestring2+":"+stringfromlist(IndexWave[eventno[0]-1],Gwavenames2)
	//eventname = "event"+eventname+"filt"
	
	print eventname1
	print eventname2
	wave source1 = $eventname1
	wave source2 = $eventname2
	appendtograph source1, source2 
	ModifyGraph rgb($stringfromlist(IndexWave[eventno[0]-1],Gwavenames1))=(0,15872,65280)
End


/////////////////////////////////////////risetime///////////////////////////////////////////////////////////////////////////
Function riseP_buttonProc(ctrlName) : ButtonControl
	String ctrlName
	RisetimesP()
End


//////////////////////////////////////////decaytime///////////////////////////////////////////////////////////////////////
Function decayP_buttonProc(ctrlName) : ButtonControl
	String ctrlName
	decayconstantP()
End

///////////////////////////////////////////////////delete event by making its parameters zero////////////////////////////
Function AllParamP(ctrlName) : ButtonControl

string ctrlName
wave eventno, amplitude, risetimeX, decaytau, noise_amp, AreaOfCurve

	RisetimesP()
	decayconstantP()
//amplitude[eventno[0]-1] = 0
//risetimeX[eventno[0]-1] = 0
//decaytau[eventno[0]-1] = 0
//noise_amp[eventno[0]-1] =0
//AreaOfCurve[eventno[0]-1] = 0

end
/////////////////////////////////time difference between events///////////////////////////////////
Function RiseDelta(ctrlName) : ButtonControl

string ctrlName
wave eventno, amplitude, risetimeX, decaytau, noise_amp, AreaOfCurve

	EventDiff()

end

//////////////////////////////////////////////////////Decay constant//////////////////////////////////////////////////////////////////

Function decayconstantP()

	string wavenames
	string tracename
	wave orientation
	SVAR GIndexWaveName
	wave IndexWave = $(GIndexWaveName)
	
	string AmpName, RiseName, DecayName, NoiseName 
	
	wavenames = TraceNameList("",";",1)
	variable i
	SVAR gwavestring1, gwavestring2

	
	for(i = 0; i < 2; i+=1) // selecting the parameter waves to be updated.
	if(i==0)
		AmpName = gwavestring1+"_Amp"
		RiseName = gwavestring1+"_Rise"
		DecayName = gwavestring1+"_Decay"
		NoiseName = gwavestring1+"_Noise"
	else
		AmpName = gwavestring2+"_Amp"
		RiseName = gwavestring2+"_Rise"
		DecayName = gwavestring2+"_Decay"
		NoiseName = gwavestring2+"_Noise"
	endif

	wave eventno, decaytau = $DecayName
	tracename = StringFromList(i,wavenames)
	print tracename

	wave source = TraceNameToWaveRef("",tracename)
	string testname = "coeff_wave"
	wave w = $testname
	variable startpt, endpt
	

	
	if (cmpstr(csrwave(A),tracename)==0)//if cursors are present use them to fit the exponential
		startpt = pcsr(A)
		endpt = pcsr(B)
	else 
		//WaveStats/Q source
		WaveStats/Q/R = (-5,10) source // else fit between the peak and end point
		if (orientation[0] ==1)
			startpt = V_minRowLoc
		else
			startpt = V_maxRowLoc
		endif	
		
		//endpt = V_endRow+150
		endpt = V_endRow+150
	endif 

	if (!WaveExists(w))
		make/n = 3 coeff_wave
	else	
	endif
	testname = "T_Constraints"
	wave w = $testname
	if (!WaveExists(w))
		Make/O/T/N=2 T_Constraints
	else	
	endif

	T_Constraints[0] = {"K0 > -20","K0 < 50"}
	//T_Constraints[1] = {"K1>0"}
	//print T_Constraints
	CurveFit/Q/NTHR=0 exp_XOffset, kwcwave = coeff_wave, source[startpt,endpt] /C=T_Constraints /D   
	
	decaytau[IndexWave[eventno[0]-1]] = coeff_wave[2]
	endfor
end

///////////////////////////////Rise Time, Amplitude, baseline noise////////////////////////////////////////////////////////

Function RiseTimesP()

	string wavenames
	string tracename
	wave eventno, amplitude, IndexWave
	SVAR GIndexWaveName
	wave IndexWave = $(GIndexWaveName)
	
	string AmpName, RiseName, DecayName, NoiseName 
	
	wavenames = TraceNameList("",";",1)
	variable i
	SVAR gwavestring1, gwavestring2
	

	variable peak, noise
	wave orientation
	
	for(i = 0; i < 2; i+=1)
	
	if(i==0)
		AmpName = gwavestring1+"_Amp"
		RiseName = gwavestring1+"_Rise"
		DecayName = gwavestring1+"_Decay"
		NoiseName = gwavestring1+"_Noise"
	else
		AmpName = gwavestring2+"_Amp"
		RiseName = gwavestring2+"_Rise"
		DecayName = gwavestring2+"_Decay"
		NoiseName = gwavestring2+"_Noise"
	endif
	
	
	wave eventno, amplitude = $AmpName, noise_amp = $NoiseName, risetimeX = $RiseName
	tracename = StringFromList(i,wavenames)
	print tracename

	wave source = TraceNameToWaveRef("",tracename)
	
	
	if (orientation[0] ==1) // find peak amplitude
		//peak = wavemin(source,0,10)
		peak = wavemin(source,-5,10)
	else
		//peak = wavemax(source,0,10)
		peak = wavemax(source,-5,10)
	endif
	print peak
	
	amplitude[IndexWave[eventno[0]-1]] = abs(peak)

	
	
	if (orientation[0] ==1) // find peak of the baseline (noise value).
		//wavestats/Q/R = (-400,-200) source
		// noise = V_sdev
		 noise = wavemin(source,-40,-20)
	else
		//noise = wavemax(source,0,2)
		noise = wavemax(source,-40,-20)
	endif	
	

	noise_amp[IndexWave[eventno[0]-1]] = noise

	print "noise:"+ num2str(noise)
	
	
	variable V_value, V_LevelX
	findvalue /V = (peak) /T = .05 /S = 350 source
	print V_value
	//findlevel/Q /R=(V_value/10,0) source, peak*.1
	findlevel/Q /R=[V_value,300] source, peak*.2 //find the time point before the peak that is 20% of the peak.
	print V_LevelX
	variable strtpt = V_LevelX	
	
	//findlevel/Q /R=(0, V_value/10) source, peak*.85
	findlevel/Q /R=[350, V_value] source, peak*.8 //find the time point before the peak that is 80% of the peak.
	print V_LevelX
	variable endpt = V_LevelX
	

	risetimeX[IndexWave[eventno[0]-1]] = endpt-strtpt //calculate the time between 20-80% of peak

	
	 
	make/O/N = 2 $("startTime"+num2str(i+1)), $("EndTime"+num2str(i+1))
	wave strttime = $("startTime"+num2str(i+1))
	wave endtime = $("EndTime"+num2str(i+1))
	strttime[0] = strtpt
	strttime[1] = strtpt

	endtime[0] =endpt
	endtime[1] = endpt
	string yptsAname = "yptsA"+num2str(i+1)
	string yptsBname = "yptsB"+num2str(i+1)
	make/O/N = 2 $("yptsA"+num2str(i+1)), $("yptsB"+num2str(i+1))
	
	wave yptsA = $("yptsA"+num2str(i+1))
	wave yptsB = $("yptsB"+num2str(i+1))


	if (orientation[0] ==1)
		yptsA[0] = wavemax(source)
	else
		yptsA[0] = wavemin(source)
	endif
	yptsA[1] = peak	
	duplicate/o yptsA yptsB
	//print yptsA
	appendtograph yptsA vs strttime // draw a line at the time point of 20% of the peak
	appendtograph yptsB vs endtime	// draw a line at the time point of 80% of the peak
	wave yptsA = tracenametowaveref("",yptsAname)
	wave yptsB = tracenametowaveref("",yptsBname)
	ModifyGraph mode=0,lsize($yptsAname)=1,lsize($yptsBname)=1;DelayUpdate
	if(i==0)
	ModifyGraph rgb($yptsAname)=(0,15872,65280)
	ModifyGraph rgb($yptsBname)=(0,15872,65280)
	else
	ModifyGraph rgb($yptsAname)=(65280,0,0)
	ModifyGraph rgb($yptsBname)=(65280,0,0)
	endif
	ModifyGraph lstyle($yptsAname)=3,lstyle($yptsBname)=3
	

	endfor
end
///////////////////////////////////////////////////////////
function EventDiff()

	string wavenames
	string tracename
	wave eventno, amplitude, IndexWave
	SVAR GIndexWaveName
	wave IndexWave = $(GIndexWaveName)
	
	string RiseDeltaName
	
	wavenames = TraceNameList("",";",1)
	variable i
	SVAR gwavestring1, gwavestring2
	

	variable peak, noise
	wave orientation
	
	for(i = 0; i < 2; i+=1)
	
	if(i==0) // select the parameter wave to be updated
		RiseDeltaName = gwavestring1+"_RiseDelta"
	else
		RiseDeltaName = gwavestring2+"_RiseDelta"
	endif
	
	print risedeltaname
	wave eventno, RiseDeltaWave = $RiseDeltaName
	tracename = StringFromList(i,wavenames)
	print tracename

	wave source = TraceNameToWaveRef("",tracename)
	
	
	if (orientation[0] ==1) // find peak
		//peak = wavemin(source,0,10)
		peak = wavemin(source,-5,10)
	else
		//peak = wavemax(source,0,10)
		peak = wavemax(source,-5,10)
	endif

	variable V_value, V_LevelX
	findvalue /V = (peak) /T = .05 /S = 350 source // find time point of peak
	print V_value
	//findlevel/Q /R=(V_value/10,0) source, peak*.1
	findlevel/Q /R=[V_value,300] source, peak*.5 // find the time point of 50% of peak.
	print V_LevelX
	variable XhalfMax = V_LevelX	

	 
	make/O/N = 2 $("XhalfMax"+num2str(i+1))
	wave strttime = $("XhalfMax"+num2str(i+1))

	strttime[0] = XhalfMax
	strttime[1] = XhalfMax
	RiseDeltaWave[IndexWave[eventno[0]-1]] = XhalfMax
	
	string yptsAname = "YhalfMax"+num2str(i+1)
	make/O/N = 2 $("YhalfMax"+num2str(i+1))
	
	wave yptsA = $("YhalfMax"+num2str(i+1))



	if (orientation[0] ==1)
		yptsA[0] = wavemax(source)
	else
		yptsA[0] = wavemin(source)
	endif
	yptsA[1] = peak	
	
	//print yptsA
	appendtograph yptsA vs strttime//display a line at the time of 50% to peak

	wave yptsA = tracenametowaveref("",yptsAname)

	ModifyGraph mode=0,lsize($yptsAname)=1;DelayUpdate
	if(i==0)
	ModifyGraph rgb($yptsAname)=(0,15872,65280)
	else
	ModifyGraph rgb($yptsAname)=(65280,0,0)
	endif
	ModifyGraph lstyle($yptsAname)=3
	

	endfor
end
//////////////////////////////////////////////////////////////
function MakeParamWaves(wavestring, wave_no)

string wavestring
variable wave_no
string AmpName = wavestring+"_Amp"
string RiseName = wavestring+"_Rise"
string DecayName = wavestring+"_Decay"
string NoiseName = wavestring+"_Noise"
string RiseDeltaName = wavestring+"_RiseDelta"

if (!WaveExists($AmpName))
	make/n = (wave_no) $AmpName
else	
endif

if (!WaveExists($DecayName))
	make/n = (wave_no) $DecayName
else	
endif

if (!WaveExists($RiseName))
	make/n = (wave_no) $RiseName
else	
endif

if (!WaveExists($NoiseName))
	make/n = (wave_no) $NoiseName
else	
endif

if (!WaveExists($RiseDeltaName))
	make/n = (wave_no) $RiseDeltaName
else	
endif

DoWindow PairedParamValues
if(V_Flag)
	dowindow /F  PairedParamValues
else
	edit /N =  PairedParamValues $NoiseName,$RiseName,$DecayName,$AmpName,$RiseDeltaName
endif


end


function ReplaceZerosP(TableName)

string TableName

string wavenames = wavelist("*",";","WIN:"+TableName)
print wavenames


variable i, j
for(j = 0; j < itemsinlist(wavenames);j+=1)
	wave Source = $(stringfromlist(j,wavenames))
for (i = 0; i <numpnts(Source); i=i+1)
	if (Source[i] ==0)
		Source[i] = NaN
	endif
endfor
endfor
end