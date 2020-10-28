# mini-analysis

Event_Viewer_NatComm2020.ipf 
- To be used to manually check, and calculate parameters of events detected using tarotools.

DisplayGoodEvents_NatComm2020.ipf
- Used to display a subset of events filtered based on event amplitude/ rise time/ decay constant.
- Also creates a wave with the indices of the selected events which is used by Event_Viewer and PairedViewer files.

ExtractEvents_NatComm2020.ipf
- To be used to extract currents based on event times (which are detected using tarotools).
- Specifically used to extract correlated events in a second cell based on the events in the first cell.


