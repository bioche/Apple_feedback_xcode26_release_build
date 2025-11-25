To reproduce compiler issue, build GSMODApplianceSelectionView in release mode on main branch. Compilation takes ~ 20 mins on an M1 pro. There's no issue on Debug mode.

A fix is published on fix_by_commenting_alertStates branch --> The issue seems to be triggered by properties of type AlertState when its generic is complex. 