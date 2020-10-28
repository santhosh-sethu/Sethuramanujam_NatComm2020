# mini analysis

Event_Viewer_NatComm2020.ipf 
- To be used to manually check, and calculate parameters of events detected using tarotools.

DisplayGoodEvents_NatComm2020.ipf
- Used to display a subset of events filtered based on event amplitude/ rise time/ decay constant.
- Also creates a wave with the indices of the selected events which is used by Event_Viewer and PairedViewer files.

ExtractEvents_NatComm2020.ipf
- To be used to extract currents based on event times (which are detected using tarotools).
- Specifically used to extract correlated events in a second cell based on the events in the first cell.

PairedViewer_NatComm2020.ipf
- Used to view, and calculate parameters of correlated events in neuronal pairs.

Sample_mini_analysis_NatComm2020.pxp
- a typical dataset on which the above analysis code can be used.

# Nearest neighbor distances (NND) analysis

NND_analysis_NatComm2020.ipf
This file has the following functions;
- CreateTreeFromROI: This function appends the selected ROI to a wave which represents the dendritic skeleton.
- ROItomask: creates an image of the dendritic tree on the scale of the original image stack
- CalcNearestNeighbor: creates a dendritic map of the NNDs of a reference cell when compared to an adjacent cell. Also creates a wave of all the NNDs used for creating cumulating distribution functions. 


