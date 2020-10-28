#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//To be used to extract minis from pClamp acquired data based on a wave with event peak times (times_name).
//Note that the event peak times in one cell could be used to extract correlated currents in a simultaneously recorded second cell.
//Function extracts events from waves with the basename/episode name combination. 
//Creates a folder to put the extracted events.
//The inputs are designed to match with tarotools which is used to detect the events. 
//Both event peak times and episode are created in the form of waves by Tarotools.

function extractMinis(basename, times_name, [episodeNames])

string times_name, basename, episodeNames

string foldername
 foldername = "root:"+basename

print foldername
Newdatafolder/O/S $foldername

string graphname = basename+"_plot"
display /N = $graphname
wave event_times =  $("root:"+times_name)

variable i = 0, delta = 0

if(Paramisdefault(episodeNames) == 0)
	wave sourceEpi = $("root:"+episodeNames)
else
	//EpisodeWaveCreator("root:"+times_name)
	wave sourceEpi

endif



variable startEvent = 0
//event_times = event_times*10 //conversion to number of points based on 10KHz acquisition

variable no_events = numpnts(event_times)
print no_events
//variable psc_length = 10 // event length in ms
//psc_length = psc_length*50 // convert to no. of pts.

string event_name
variable strtpt, endpt
wave trace = $("root:"+basename+"_"+num2str(sourceEpi[0]+1))

variable xdelta = deltax(trace)
print xdelta

for (i = startEvent; i < startEvent+no_events; i+=1)
	wave trace = $("root:"+basename+"_"+num2str(sourceEpi[i]+1))
	if(waveexists(trace)==0)
		//print "root:"+basename+"_"+num2str(sourceEpi[i]+1)+" does not exist"
	endif
	event_name = basename+"_event"+num2str(i+1)
	//strtpt = event_times(i)
	strtpt = event_times(i-startEvent) - 40 //start point is 40 ms before the peak
	//endpt = strtpt+psc_length
	endpt = event_times(i-startEvent)+60 //end point is 60 ms after peak
	duplicate/O/R = (strtpt,endpt) trace, $event_name
	SetScale/P x, -40,xdelta, $event_name
	appendtograph /W = $graphname $event_name
endfor

end

