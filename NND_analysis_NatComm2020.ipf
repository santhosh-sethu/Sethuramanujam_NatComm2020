#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//CreateTreeFromROI		: appends the selected ROI to a dendritic skeleton.
//deleteSegment			: deletes the segment between cursors A and B.
//ROItomask				: converts the dendritic skeleton to a mask 
//CalcNearestNeighbor	: creates a dendritic map of the nearest neighbor distances of a reference cell when compared to an adjacent cell. 

/////////////////stitches ROIs to create a dendritic skeleton//////////////////////////////

// ROIs are created using twoP_examine toolbox
// roiname	: name of the ROI to be appended
// treename	: name of the skeleton wave
function CreateTreeFromROI(roiname,treename)

string roiname
string treename
if(waveexists($(treename+"X"))==1)
else
	make/n = 0 $(treename+"X"), $(treename+"Y")
endif
wave treeX = $(treename+"X")
wave treeY = $(treename+"Y")

concatenate/NP {$("root:twoP_ROIS:"+roiname+"_x")}, TreeX
concatenate/NP {$("root:twoP_ROIS:"+roiname+"_y")}, TreeY

variable pts = numpnts(TreeX)
Insertpoints pts,1, TreeX, TreeY
TreeX[pts] = NaN
TreeY[pts] = NaN

end

////////////////////////////Remove a segment from the tree between cursors A and B//////////////////////////////
function deleteSegment(basename)
string basename
wave sourceX = $(basename+"X")
wave sourceY = $(basename+"Y")
variable cursorA = pcsr(A)
variable cursorB = pcsr(B)
variable startpt, endpt
if (pcsr(A) > pcsr(B))
	startpt = pcsr(B)
	endpt = pcsr(A)
else
	startpt = pcsr(A)
	endpt = pcsr(B)
endif
variable NoPts = endpt-startpt+1

deletepoints startpt, NoPts, sourceX, sourceY

end



////////////////////////////Make a mask from X and Y waves//////////////////////////////

//basename	: names of the waves with the X and Y coordinates of the skeleton.
//scalingWaveName : name of the original stack on which the dendritic skeleton was drawn. 

function ROItomask(basename,ScalingWaveName)

string basename, ScalingWaveName

wave WaveForScaling = $("root:twoP_Scans:"+ScalingWaveName+":"+ScalingWaveName+"_Ch1")
wave SourceX = $(basename+"TreeX")
wave SourceY = $(basename+"TreeY")

variable rows = dimsize(WaveForScaling,0)
variable columns = dimsize(WaveForScaling,1)

imageboundarytomask width = rows, height = columns, xwave = SourceX, ywave = SourceY, scalingwave = WaveForScaling
wave M_ROIMask
Duplicate/O M_ROIMask, $(basename+"Mask")
killwaves M_ROIMask

string NameOfTheWave = basename+"Mask"
variable scalingfactor = 1/dimdelta(WaveForScaling,0)/10^6
print scalingfactor
resize(NameOfTheWave,scalingfactor)



end

//////////////////////Scale down the image size/////////////////////////////

// function used to resize the image. called by ROItoMask function

function resize(wavestring,ScaleDownFactor)

string wavestring
variable ScaleDownFactor
wave SOURCE = $wavestring
variable rows = dimsize(SOURCE,0)
variable columns = dimsize(SOURCE,1)


make/O/N = (rows/ScaleDownFactor, columns/ScaleDownFactor) ReducedWave
make/o/N = (ScaleDownFactor,ScaleDownFactor) TempMatrix

variable i, j



	MatrixOP/O TempLayer = SOURCE
	
	for(i = 0; i < rows/ScaleDownFactor; i+=1)
		for(j = 0; j < columns/ScaleDownFactor; j+=1)
		MatrixOP/O TempMatrix = subrange(TempLayer,i*ScaleDownFactor,i*ScaleDownFactor+ScaleDownFactor-1, j*ScaleDownFactor,j*ScaleDownFactor+ScaleDownFactor-1)
		wavestats/Q TempMatrix
		ReducedWave[i][j] = V_max

		endfor
	endfor


Duplicate/O ReducedWave, $(wavestring+"_Reduced")
killwaves ReducedWave, TempLayer, TempMatrix

end

/////////////////calculate the nearest neighbour pixel in cell2 for each pixel in cell1//////////////////////////////

function CalcNearestNeighbor(RefWaveString,CompWaveString)

string RefWaveString, CompWaveString

wave SourceR = $RefWaveString
wave SourceG = $CompWaveString

variable rows = dimsize(SourceR,0)
variable columns = dimsize(SourceR,1)
variable layers = 1
print rows, columns
variable pts = 0
make/O/N = (rows,columns) DistMap
//layers = 14
variable i, j ,k
make/O/N = 0 distwave
for(k = 0; k < layers; k+=1)
	MatrixOP/O TempLayerR = SourceR
	MatrixOP/O xposR = const(rows,columns,NaN)
	MatrixOP/O yposR = const(rows,columns,NaN)
	MatrixOP/O xposG = const(rows,columns,NaN)
	MatrixOP/O yposG = const(rows,columns,NaN)
	MatrixOP/O TempLayerG = SourceG
	
	for(i = 0; i < rows; i+=1)
		for(j = 0; j < columns; j+=1)
			if(TempLayerR[i][j] > 0)
				XposR [i][j] =  i
				YposR [i][j] =  j
			endif
			if(TempLayerG[i][j] >0)
				XposG [i][j] =  i
				YposG [i][j] =  j
			endif
		
		endfor
	endfor
	
	for(i = 0; i < rows; i+=1)
		for(j = 0; j < columns; j+=1)
			if(TempLayerR[i][j] > 0)
				MatrixOP/O DistMatrix = sqrt((XposG-i)*(XposG-i)+(YposG-j)*(YposG-j))
				
				InsertPoints pts,1, Distwave
				pts = pts+1
				wavestats/Q DistMatrix
				Distwave[pts-1] = V_min
				DistMap[i][j] = V_min
			else
				DistMap[i][j] = NaN
			endif
		
		endfor
	endfor
	
	print "+++++++++++++++layer:"+num2str(k)+"++++++++++++++++++++++"
	
	
	
endfor


print pts



end