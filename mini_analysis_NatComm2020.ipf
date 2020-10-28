#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//This function will create a window to show events with the name wavestring+*, one-by-one. 
//This function also creates controls which can be used to detect the rise-time, decay constant and peak amplitude of each event.

function event_viewer(wavestring,[IndexWaveName])

string wavestring //wavestring = "EventCutOut_" for tarotools
string IndexWaveName //optional wave. eg. {1,10,21}. if present, the viewer window will show only the events indexed in this wave.
string/G Gwavestring = wavestring
variable/G IndexPresent = 0

if(ParamIsDefault(IndexWaveName)==0)
	DUplicate/O  $IndexWaveName, IndexWave
	IndexPresent = 1
	print IndexPresent
endif
	
//Create viewer window.
dowindow EventViewer
if(V_flag)
	DoWindow /F EventViewer
else
	display /N = EventViewer
endif
make/o /n = 1 eventno
//ShowTools/A arrow
ShowInfo
ControlBar 100
string/G Gwavenames
string tracename
variable wave_no = 0
variable inward = 1
prompt inward, "outward?"
DoPrompt " outward = 0 and inward = 1", inward //user input to determine whether currents are inward or outward.
make/o/n =1 orientation
orientation = inward

//wavenames = wavelist("event*filt",";","")
Gwavenames = wavelist(wavestring+"*",";","")
wave_no = itemsinlist(Gwavenames)
print wave_no

wave amplitude
if (!WaveExists(amplitude))
	make/n = (wave_no) amplitude
else	
endif

wave decaytau //decay constants in ms are saved in this wave
if (!WaveExists(decaytau))
	make/n = (wave_no) decaytau
else	
endif

wave risetimeX //20-80% rise times in ms are saved in this wave
if (!WaveExists(risetimeX))
	make/n = (wave_no) risetimeX
else	
endif

wave noise_amp //baseline noise amplitudes in pA are saved in this wave
if (!WaveExists(noise_amp))
	make/n = (wave_no) noise_amp
else	
endif

wave AreaOfCurve //Area under the curve (pA.ms) are saved in this wave
if (!WaveExists(AreaOfCurve))
	make/n = (wave_no) AreaOfCurve
else	
endif

make/n = (wave_no) xx
make/n = 2 strttime, endtime, yptsA, yptsB
DoWindow ParamValues //the parameters created above will be appended to this table
if(V_Flag)
	dowindow /F ParamValues
else
	edit /N = ParamValues amplitude, decaytau, risetimeX, noise_amp,  AreaOfCurve
endif
DoWindow /F EventViewer
//populating the viewer window with controls
Button button0 proc=traceupdate
Button button0 title="update"
SetVariable setvar0 title="event no",proc = traceupdate, value=eventno[0], size={90,16},limits={1,10000,1}
Button button1 proc=decayconstant_buttonProc
Button button1 title="decaytau"
Button button2 proc=rise_time_buttonProc
Button button2 title="risetime, peak, noise"
Button button3 proc=Curve_area
Button button3 title="Curve Area"
Button button4 title = "All", proc = Allparam
end

//////////////////////////////////////////////event update//////////////////////////////////////////////////////////////////////////////////////
//function which updates the viewer window to show .
Function traceupdate(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	SVAR Gwavenames
	SVAR Gwavestring
	NVAR IndexPresent
	string wavenames,tracename
	wavenames = TraceNameList("",";",1)
	variable wave_no = 0, i, j, no_pts, baseline
	string wavestring
	wave_no = itemsinlist(wavenames)

	for (i = 0;i <wave_no;i+=1)
		tracename = StringFromList(i,wavenames)
		RemoveFromGraph $tracename
	endfor
		
	wave eventno, IndexWave
	string eventname
	if (IndexPresent == 1)
		eventname = stringfromlist(IndexWave[eventno[0]-1],Gwavenames)
	else
		eventname = stringfromlist(eventno[0]-1,Gwavenames)
	endif
	//eventname = "event"+eventname+"filt"
	
	print eventname
	wave source = $eventname
	appendtograph source
	
End

/////////////////////////////////////////risetime///////////////////////////////////////////////////////////////////////////
Function rise_time_buttonProc(ctrlName) : ButtonControl
	String ctrlName
	Risetimes()
End


//////////////////////////////////////////decaytime///////////////////////////////////////////////////////////////////////
Function decayconstant_buttonProc(ctrlName) : ButtonControl
	String ctrlName
	decayconstant()
End

///////////////////////////////////////////Area under the Curve///////////////////////////////////////////////////////////////////////

Function Curve_Area(ctrlName) : ButtonControl

String ctrlName
string wavenames
string tracename
wavenames = TraceNameList("",";",1)
tracename = StringFromList(0,wavenames)
print tracename
wave AreaOfCurve, eventno	
wave source = $tracename
wavestats/Q source
AreaOfCurve[eventno[0]-1] = V_avg   // in pA.ms



End
///////////////////////////////////////////////////detect all the parameters////////////////////////////
Function Allparam(ctrlName) : ButtonControl

string ctrlName
wave eventno, amplitude, risetimeX, decaytau, noise_amp, AreaOfCurve

	Risetimes()
	decayconstant()
//amplitude[eventno[0]-1] = 0
//risetimeX[eventno[0]-1] = 0
//decaytau[eventno[0]-1] = 0
//noise_amp[eventno[0]-1] =0
//AreaOfCurve[eventno[0]-1] = 0

end


//////////////////////////////////////////////////////Decay constant//////////////////////////////////////////////////////////////////

Function decayconstant()

	string wavenames
	string tracename
	wave orientation
	NVAR IndexPresent
	wave IndexWave
	wavenames = TraceNameList("",";",1)
	tracename = StringFromList(0,wavenames)
	print tracename
	wave eventno, decaytau
	wave source = $tracename
	string testname = "coeff_wave"
	wave w = $testname
	variable startpt, endpt
	if (strlen(csrinfo(A)) > 0)//if cursors are present use them to fit the exponential
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
	print T_Constraints
	CurveFit/Q/NTHR=0 exp_XOffset, kwcwave = coeff_wave, source[startpt,endpt] /C=T_Constraints /D   // fit with exponential.
	
	if (IndexPresent == 1)
		decaytau[IndexWave[eventno[0]-1]] = coeff_wave[2]
	else
		decaytau[eventno[0]-1] = coeff_wave[2]
	endif
	
end

///////////////////////////////Rise Time, Amplitude, baseline noise////////////////////////////////////////////////////////

Function RiseTimes()

	string wavenames
	string tracename
	wave eventno, amplitude, IndexWave
	NVAR IndexPresent
	wavenames = TraceNameList("",";",1)
	tracename = StringFromList(0,wavenames)
	wave source = $tracename
	variable peak, noise
	wave orientation
	print orientation
	if (orientation[0] ==1) // find peak amplitude
		//peak = wavemin(source,0,10)
		peak = wavemin(source,-5,10)
	else
		//peak = wavemax(source,0,10)
		peak = wavemax(source,-5,10)
	endif
	
	print abs(peak)
	
	if (IndexPresent == 1)
		amplitude[IndexWave[eventno[0]-1]] = abs(peak)
	else
		amplitude[eventno[0]-1] = abs(peak)
	endif
	
	
	
	wave noise_amp
	if (orientation[0] ==1) // find peak of the baseline (noise value).
		//wavestats/Q/R = (-400,-200) source
		// noise = V_sdev
		 noise = wavemin(source,-40,-20)
	else
		//noise = wavemax(source,0,2)
		noise = wavemax(source,-40,-20)
	endif	
	
	if (IndexPresent == 1)
		noise_amp[IndexWave[eventno[0]-1]] = noise
	else
		noise_amp[eventno[0]-1] = noise
	endif
	print "noise:"+ num2str(noise)
	
	
	variable V_value, V_LevelX
	wave risetimeX
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
	
	if (IndexPresent == 1)
		risetimeX[IndexWave[eventno[0]-1]] = endpt-strtpt //calculate the time between 20-80% of peak
	else
		risetimeX[eventno[0]-1] = endpt-strtpt
	endif
	
	 
	wave strttime 
	strttime[0] = strtpt
	strttime[1] = strtpt
	wave endtime 
	endtime[0] =endpt
	endtime[1] = endpt
	wave yptsA
	wave yptsB
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
	ModifyGraph mode=0,lsize(yptsA)=1,rgb(yptsA)=(0,0,0),lsize(yptsB)=1;DelayUpdate
	ModifyGraph rgb(yptsB)=(0,0,0)
	ModifyGraph lstyle(yptsA)=3,lstyle(yptsB)=3
	
end