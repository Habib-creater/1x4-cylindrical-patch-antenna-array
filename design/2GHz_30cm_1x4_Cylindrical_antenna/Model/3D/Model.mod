'# MWS Version: Version 2025.0 - Aug 30 2024 - ACIS 34.0.1 -

'# length = mm
'# frequency = GHz
'# time = ns
'# frequency range: fmin = 1 fmax = 3
'# created = '[VERSION]2025.0|34.0.1|20240830[/VERSION]


'@ use template: Antenna - Planar_7.cfg

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
'set the units
With Units
    .SetUnit "Length", "mm"
    .SetUnit "Frequency", "GHz"
    .SetUnit "Voltage", "V"
    .SetUnit "Resistance", "Ohm"
    .SetUnit "Inductance", "nH"
    .SetUnit "Temperature",  "degC"
    .SetUnit "Time", "ns"
    .SetUnit "Current", "A"
    .SetUnit "Conductance", "S"
    .SetUnit "Capacitance", "pF"
End With

ThermalSolver.AmbientTemperature "0"

'----------------------------------------------------------------------------

'set the frequency range
Solver.FrequencyRange "1.8", "2.2"

'----------------------------------------------------------------------------

Plot.DrawBox True

With Background
     .Type "Normal"
     .Epsilon "1.0"
     .Mu "1.0"
     .XminSpace "0.0"
     .XmaxSpace "0.0"
     .YminSpace "0.0"
     .YmaxSpace "0.0"
     .ZminSpace "0.0"
     .ZmaxSpace "0.0"
End With

With Boundary
     .Xmin "expanded open"
     .Xmax "expanded open"
     .Ymin "expanded open"
     .Ymax "expanded open"
     .Zmin "expanded open"
     .Zmax "expanded open"
     .Xsymmetry "none"
     .Ysymmetry "none"
     .Zsymmetry "none"
End With

' optimize mesh settings for planar structures

With Mesh
     .MergeThinPECLayerFixpoints "True"
     .RatioLimit "20"
     .AutomeshRefineAtPecLines "True", "6"
     .FPBAAvoidNonRegUnite "True"
     .ConsiderSpaceForLowerMeshLimit "False"
     .MinimumStepNumber "5"
     .AnisotropicCurvatureRefinement "True"
     .AnisotropicCurvatureRefinementFSM "True"
End With

With MeshSettings
     .SetMeshType "Hex"
     .Set "RatioLimitGeometry", "20"
     .Set "EdgeRefinementOn", "1"
     .Set "EdgeRefinementRatio", "6"
End With

With MeshSettings
     .SetMeshType "HexTLM"
     .Set "RatioLimitGeometry", "20"
End With

With MeshSettings
     .SetMeshType "Tet"
     .Set "VolMeshGradation", "1.5"
     .Set "SrfMeshGradation", "1.5"
End With

' change mesh adaption scheme to energy
' 		(planar structures tend to store high energy
'     	 locally at edges rather than globally in volume)

MeshAdaption3D.SetAdaptionStrategy "Energy"

' switch on FD-TET setting for accurate farfields

FDSolver.ExtrudeOpenBC "True"

PostProcess1D.ActivateOperation "vswr", "true"
PostProcess1D.ActivateOperation "yz-matrices", "true"

With FarfieldPlot
	.ClearCuts ' lateral=phi, polar=theta
	.AddCut "lateral", "0", "1"
	.AddCut "lateral", "90", "1"
	.AddCut "polar", "90", "1"
End With

'----------------------------------------------------------------------------

Dim sDefineAt As String
sDefineAt = "2"
Dim sDefineAtName As String
sDefineAtName = "2"
Dim sDefineAtToken As String
sDefineAtToken = "f="
Dim aFreq() As String
aFreq = Split(sDefineAt, ";")
Dim aNames() As String
aNames = Split(sDefineAtName, ";")

Dim nIndex As Integer
For nIndex = LBound(aFreq) To UBound(aFreq)

Dim zz_val As String
zz_val = aFreq (nIndex)
Dim zz_name As String
zz_name = sDefineAtToken & aNames (nIndex)

' Define E-Field Monitors
With Monitor
    .Reset
    .Name "e-field ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Efield"
    .MonitorValue  zz_val
    .Create
End With

' Define H-Field Monitors
With Monitor
    .Reset
    .Name "h-field ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Hfield"
    .MonitorValue  zz_val
    .Create
End With

' Define Farfield Monitors
With Monitor
    .Reset
    .Name "farfield ("& zz_name &")"
    .Domain "Frequency"
    .FieldType "Farfield"
    .MonitorValue  zz_val
    .ExportFarfieldSource "False"
    .Create
End With

Next

'----------------------------------------------------------------------------

With MeshSettings
     .SetMeshType "Hex"
     .Set "Version", 1%
End With

With Mesh
     .MeshType "PBA"
End With

'set the solver type
ChangeSolverType("HF Time Domain")

'----------------------------------------------------------------------------

'@ define material: FR-4 (lossy)

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Material
     .Reset
     .Name "FR-4 (lossy)"
     .Folder ""
     .FrqType "all"
     .Type "Normal"
     .SetMaterialUnit "GHz", "mm"
     .Epsilon "4.3"
     .Mu "1.0"
     .Kappa "0.0"
     .TanD "0.025"
     .TanDFreq "10.0"
     .TanDGiven "True"
     .TanDModel "ConstTanD"
     .KappaM "0.0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstKappa"
     .DispModelEps "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "General 1st"
     .DispersiveFittingSchemeMu "General 1st"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .Rho "0.0"
     .ThermalType "Normal"
     .ThermalConductivity "0.3"
     .SetActiveMaterial "all"
     .Colour "0.94", "0.82", "0.76"
     .Wireframe "False"
     .Transparency "0"
     .Create
End With

'@ new component: component1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Component.New "component1"

'@ define brick: component1:Substrate

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Brick
     .Reset 
     .Name "Substrate" 
     .Component "component1" 
     .Material "FR-4 (lossy)" 
     .Xrange "-w_sub/2", "w_sub/2" 
     .Yrange "-l_sub/2", "l_sub/2" 
     .Zrange "0", "h" 
     .Create
End With

'@ define material: Copper (annealed)

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Material
     .Reset
     .Name "Copper (annealed)"
     .Folder ""
     .FrqType "static"
     .Type "Normal"
     .SetMaterialUnit "Hz", "mm"
     .Epsilon "1"
     .Mu "1.0"
     .Kappa "5.8e+007"
     .TanD "0.0"
     .TanDFreq "0.0"
     .TanDGiven "False"
     .TanDModel "ConstTanD"
     .KappaM "0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstTanD"
     .DispModelEps "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "Nth Order"
     .DispersiveFittingSchemeMu "Nth Order"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .FrqType "all"
     .Type "Lossy metal"
     .SetMaterialUnit "GHz", "mm"
     .Mu "1.0"
     .Kappa "5.8e+007"
     .Rho "8930.0"
     .ThermalType "Normal"
     .ThermalConductivity "401.0"
     .SpecificHeat "390", "J/K/kg"
     .MetabolicRate "0"
     .BloodFlow "0"
     .VoxelConvection "0"
     .MechanicsType "Isotropic"
     .YoungsModulus "120"
     .PoissonsRatio "0.33"
     .ThermalExpansionRate "17"
     .Colour "1", "1", "0"
     .Wireframe "False"
     .Reflection "False"
     .Allowoutline "True"
     .Transparentoutline "False"
     .Transparency "0"
     .Create
End With

'@ define brick: component1:Ground

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Brick
     .Reset 
     .Name "Ground" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Xrange "-w_sub/2", "w_sub/2" 
     .Yrange "-l_sub/2", "l_sub/2" 
     .Zrange "-t", "0" 
     .Create
End With

'@ define brick: component1:Patch_main

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Brick
     .Reset 
     .Name "Patch_main" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Xrange "-w_p/2", "w_p/2" 
     .Yrange "-l_p/2", "l_p/2" 
     .Zrange "h", "h+t" 
     .Create
End With

'@ define brick: component1:Cut_block

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Brick
     .Reset 
     .Name "Cut_block" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Xrange "-(w_f/2+g_p)", "(w_f/2+g_p)" 
     .Yrange "-l_p/2", "-l_p/2+r_x" 
     .Zrange "h", "h+t" 
     .Create
End With

'@ boolean subtract shapes: component1:Patch_main, component1:Cut_block

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Solid.Subtract "component1:Patch_main", "component1:Cut_block"

'@ define brick: component1:Feed_line

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Brick
     .Reset 
     .Name "Feed_line" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Xrange "-w_f/2", "w_f/2" 
     .Yrange "-l_sub/2", "-l_p/2+r_x" 
     .Zrange "h", "h+t" 
     .Create
End With

'@ boolean add shapes: component1:Patch_main, component1:Feed_line

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Solid.Add "component1:Patch_main", "component1:Feed_line"

'@ pick mid point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickMidpointFromId "component1:Patch_main", "4"

'@ pick mid point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickMidpointFromId "component1:Ground", "6"

'@ define discrete port: 1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With DiscretePort 
     .Reset 
     .PortNumber "1" 
     .Type "SParameter"
     .Label ""
     .Folder ""
     .Impedance "50.0"
     .Voltage "1.0"
     .Current "1.0"
     .Monitor "True"
     .Radius "0.0"
     .SetP1 "True", "0", "-28", "1.635"
     .SetP2 "True", "0", "-28", "-0.035"
     .InvertDirection "False"
     .LocalCoordinates "False"
     .Wire ""
     .Position "end1"
     .Create 
End With

'@ define time domain solver parameters

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "False"
     .AutoNormImpedance "False"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ define frequency range

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Solver.FrequencyRange "1", "5"

'@ transform: translate component1:Patch_main

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main" 
     .Vector "-1.5*d", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform port: translate port1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "port1" 
     .Vector "-1.5*d", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Transform "Port", "Translate" 
End With

'@ transform: translate component1:Patch_main

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main" 
     .Vector "d", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "3" 
     .MultipleSelection "False" 
     .Destination "" 
     .Material "" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform port: translate port1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "port1" 
     .Vector "d", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "3" 
     .MultipleSelection "False" 
     .Transform "Port", "Translate" 
End With

'@ farfield plot options

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With FarfieldPlot 
     .Plottype "Polar" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "-1" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .AspectRatio "Free" 
     .ShowGridlines "True" 
     .InvertAxes "False", "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .IncludeUnitCellSidewalls "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .SetMaxReferenceMode "abs" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1.0" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  

     .StoreSettings
End With

'@ define solver excitation modes

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Solver 
     .ResetExcitationList 
     .ExcitationSelectionShowAdditionalSettings "False" 
     .SetExcitation "portmode", "1", "1", "default", "default", "default", "True" 
     .SetExcitation "portmode", "2", "1", "default", "default", "default", "True" 
     .SetExcitation "portmode", "3", "1", "default", "default", "default", "True" 
     .SetExcitation "portmode", "4", "1", "default", "default", "default", "True" 
End With

'@ define time domain solver parameters

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "List"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "False"
     .AutoNormImpedance "False"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ farfield plot options

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With FarfieldPlot 
     .Plottype "Polar" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "-1" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .AspectRatio "Free" 
     .ShowGridlines "True" 
     .InvertAxes "False", "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .IncludeUnitCellSidewalls "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .SetMaxReferenceMode "abs" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1.0" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  

     .StoreSettings
End With

'@ activate local coordinates

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
WCS.ActivateWCS "local"

'@ define frequency range

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Solver.FrequencyRange "1", "3"

'@ farfield plot options

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With FarfieldPlot 
     .Plottype "3D" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "5" 
     .Step2 "5" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "-1" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "True" 
     .ShowStructureProfile "True" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .AspectRatio "Free" 
     .ShowGridlines "True" 
     .InvertAxes "False", "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .IncludeUnitCellSidewalls "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .SetMaxReferenceMode "abs" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1.0" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  

     .StoreSettings
End With

'@ pick end point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickEndpointFromId "component1:Substrate", "8"

'@ pick end point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickEndpointFromId "component1:Substrate", "5"

'@ transform: translate component1:Ground

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Ground" 
     .Vector "300", "0", "0" 
     .UsePickedPoints "True" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Patch_main

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main" 
     .Vector "300", "0", "0" 
     .UsePickedPoints "True" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Patch_main_1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main_1" 
     .Vector "300", "0", "0" 
     .UsePickedPoints "True" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Patch_main_2

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main_2" 
     .Vector "300", "0", "0" 
     .UsePickedPoints "True" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Patch_main_3

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main_3" 
     .Vector "300", "0", "0" 
     .UsePickedPoints "True" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Substrate

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Substrate" 
     .Vector "300", "0", "0" 
     .UsePickedPoints "True" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ clear picks

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.ClearAllPicks

'@ transform: translate component1:Ground

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Ground" 
     .Vector "-150", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Patch_main

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main" 
     .Vector "-150", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Patch_main_1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main_1" 
     .Vector "-150", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Patch_main_2

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main_2" 
     .Vector "-150", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Patch_main_3

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main_3" 
     .Vector "-150", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Substrate

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Substrate" 
     .Vector "-150", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Ground

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Ground" 
     .Vector "-300/2", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Patch_main

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main" 
     .Vector "-300/2", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Patch_main_1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main_1" 
     .Vector "-300/2", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Patch_main_2

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main_2" 
     .Vector "-300/2", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Patch_main_3

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Patch_main_3" 
     .Vector "-300/2", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:Substrate

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:Substrate" 
     .Vector "-300/2", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ clear picks

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.ClearAllPicks

'@ farfield plot options

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With FarfieldPlot 
     .Plottype "Polar" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "-1" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "True" 
     .ShowStructureProfile "True" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .AspectRatio "Free" 
     .ShowGridlines "True" 
     .InvertAxes "False", "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .IncludeUnitCellSidewalls "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .SetMaxReferenceMode "abs" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1.0" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  

     .StoreSettings
End With

'@ define cylinder: component1:solid1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Cylinder 
     .Reset 
     .Name "solid1" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .OuterRadius "300" 
     .InnerRadius "0.0" 
     .Axis "y" 
     .Yrange "-56", "56" 
     .Xcenter "0" 
     .Zcenter "0" 
     .Segments "0" 
     .Create 
End With

'@ transform: translate component1:solid1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1:solid1" 
     .Vector "0", "0", "-300" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ bend: selected sheets, component1:solid1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Bending 
	.Reset 
	.Version "10" 
	.Sheet "component1:Ground" 
	.Solid "component1:solid1" 
	.Faces "2" 
	.Bend 
End With

'@ delete shape: component1:solid1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Solid.Delete "component1:solid1"

'@ bend: selected sheets, component1:Ground

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Bending 
	.Reset 
	.Version "10" 
	.Sheet "component1:Substrate" 
	.Solid "component1:Ground" 
	.Faces "1,1" 
	.Bend 
End With

'@ pick mid point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickMidpointFromId "component1:Patch_main_1", "29"

'@ pick mid point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickMidpointFromId "component1:Patch_main_2", "31"

'@ define brick: component1:solid1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Brick
     .Reset 
     .Name "solid1" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Xrange "-14.465", "14.465" 
     .Yrange "-10", "10" 
     .Zrange "1.6", "1.6" 
     .Create
End With

'@ bend: selected sheets, component1:Substrate

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Bending 
	.Reset 
	.Version "10" 
	.Sheet "component1:Patch_main" 
	.Sheet "component1:Patch_main_1" 
	.Sheet "component1:Patch_main_2" 
	.Sheet "component1:Patch_main_3" 
	.Sheet "component1:solid1" 
	.Solid "component1:Substrate" 
	.Faces "7,7" 
	.Bend 
End With

'@ delete shape: component1:solid1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Solid.Delete "component1:solid1"

'@ paste structure data: 1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Material 
     .Reset 
     .Name "Dielectric_1" 
     .Folder "" 
     .Rho "0.0"
     .ThermalType "Normal"
     .ThermalConductivity "0"
     .SpecificHeat "0", "J/K/kg"
     .DynamicViscosity "0"
     .UseEmissivity "True"
     .Emissivity "0"
     .MetabolicRate "0.0"
     .VoxelConvection "0.0"
     .BloodFlow "0"
     .MechanicsType "Unused"
     .SolarRadiationAbsorptionType "Opaque"
     .Absorptance "0.0"
     .UseSemiTransparencyCalculator "False"
     .SolarRadTransmittance "0.0"
     .SolarRadReflectance "0.0"
     .SolarRadSpecimenThickness "0.0"
     .SolarRadRefractiveIndex "1.0"
     .SolarRadAbsorptionCoefficient "0.0"
     .IntrinsicCarrierDensityModel "none"
     .FrqType "all"
     .Type "Normal"
     .MaterialUnit "Time", "s"
     .Epsilon "2.1000000000000001"
     .Mu "1"
     .Sigma "0"
     .TanD "0.0"
     .TanDFreq "0.0"
     .TanDGiven "False"
     .TanDModel "ConstSigma"
     .SetConstTanDStrategyEps "AutomaticOrder"
     .ConstTanDModelOrderEps "1"
     .DjordjevicSarkarUpperFreqEps "0"
     .SetElParametricConductivity "False"
     .ReferenceCoordSystem "Global"
     .CoordSystemType "Cartesian"
     .SigmaM "0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstSigma"
     .SetConstTanDStrategyMu "AutomaticOrder"
     .ConstTanDModelOrderMu "1"
     .DjordjevicSarkarUpperFreqMu "0"
     .SetMagParametricConductivity "False"
     .DispModelEps  "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "Nth Order"
     .MaximalOrderNthModelFitEps "10"
     .ErrorLimitNthModelFitEps "0.1"
     .UseOnlyDataInSimFreqRangeNthModelEps "False"
     .DispersiveFittingSchemeMu "Nth Order"
     .MaximalOrderNthModelFitMu "10"
     .ErrorLimitNthModelFitMu "0.1"
     .UseOnlyDataInSimFreqRangeNthModelMu "False"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .NLAnisotropy "False"
     .NLAStackingFactor "1"
     .NLADirectionX "1"
     .NLADirectionY "0"
     .NLADirectionZ "0"
     .Colour "0", "1", "1" 
     .Wireframe "False" 
     .Reflection "False" 
     .Allowoutline "True" 
     .Transparentoutline "False" 
     .Transparency "0" 
     .Create
End With 

With SAT 
     .Reset 
     .FileName "*1.cby" 
     .SubProjectScaleFactor "0.001" 
     .ImportToActiveCoordinateSystem "True" 
     .ScaleToUnit "True" 
     .Curves "False" 
     .Read 
End With 

With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax:InnerConductor")
          .SetMeshType "All" 
          .Set "Transform", "6.12323e-17", "0", "1", "0", "1", "0", "-1", "0", "6.12323e-17" 
     End With
End With
With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax:Dielectric")
          .SetMeshType "All" 
          .Set "Transform", "6.12323e-17", "0", "1", "0", "1", "0", "-1", "0", "6.12323e-17" 
     End With
End With
With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax:OuterConductor")
          .SetMeshType "All" 
          .Set "Transform", "6.12323e-17", "0", "1", "0", "1", "0", "-1", "0", "6.12323e-17" 
     End With
End With

'@ transform: rotate component1/Coax

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1/Coax" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .Angle "0", "0", "90" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Rotate" 
End With

'@ pick end point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickEndpointFromId "component1/Coax:Dielectric", "4"

'@ pick mid point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickMidpointFromId "component1:Patch_main", "62"

'@ transform: translate component1/Coax

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1/Coax" 
     .Vector "-109.92202669308", "-17", "-19.81209999595" 
     .UsePickedPoints "True" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ pick face

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickFaceFromId "component1/Coax:Dielectric", "1"

'@ delete ports

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Port.Delete "1" 
Port.Delete "2" 
Port.Delete "3" 
Port.Delete "4"

'@ define port: 1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Port 
     .Reset 
     .PortNumber "1" 
     .Label ""
     .Folder ""
     .NumberOfModes "1"
     .AdjustPolarization "False"
     .PolarizationAngle "0.0"
     .ReferencePlaneDistance "0"
     .TextSize "50"
     .TextMaxLimit "0"
     .Coordinates "Picks"
     .Orientation "positive"
     .PortOnBound "False"
     .ClipPickedPortToBound "False"
     .Xrange "-112.09852669308", "-107.74552669308"
     .Yrange "-32.99999", "-32.99999"
     .Zrange "-20.63359999595", "-16.28059999595"
     .XrangeAdd "0.0", "0.0"
     .YrangeAdd "0.0", "0.0"
     .ZrangeAdd "0.0", "0.0"
     .SingleEnded "False"
     .WaveguideMonitor "False"
     .Create 
End With

'@ paste structure data: 2

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With SAT 
     .Reset 
     .FileName "*2.cby" 
     .SubProjectScaleFactor "0.001" 
     .SubProjectLocalWCS "0", "0", "0", "0", "0", "1", "1", "0", "0" 
     .ImportToActiveCoordinateSystem "True" 
     .ScaleToUnit "True" 
     .Curves "False" 
     .Read 
End With 

With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax_1:InnerConductor")
          .SetMeshType "All" 
          .Set "Transform", "3.7494e-33", "-1", "6.12323e-17", "6.12323e-17", "6.12323e-17", "1", "-1", "0", "6.12323e-17" 
     End With
End With
With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax_1:Dielectric")
          .SetMeshType "All" 
          .Set "Transform", "3.7494e-33", "-1", "6.12323e-17", "6.12323e-17", "6.12323e-17", "1", "-1", "0", "6.12323e-17" 
     End With
End With
With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax_1:OuterConductor")
          .SetMeshType "All" 
          .Set "Transform", "3.7494e-33", "-1", "6.12323e-17", "6.12323e-17", "6.12323e-17", "1", "-1", "0", "6.12323e-17" 
     End With
End With

'@ delete component: component1/Coax_1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Component.Delete "component1/Coax_1"

'@ paste structure data: 3

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With SAT 
     .Reset 
     .FileName "*3.cby" 
     .SubProjectScaleFactor "0.001" 
     .ImportToActiveCoordinateSystem "True" 
     .ScaleToUnit "True" 
     .Curves "False" 
     .Read 
End With 

With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax_1:InnerConductor")
          .SetMeshType "All" 
          .Set "Transform", "6.12323e-17", "0", "1", "0", "1", "0", "-1", "0", "6.12323e-17" 
     End With
End With
With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax_1:Dielectric")
          .SetMeshType "All" 
          .Set "Transform", "6.12323e-17", "0", "1", "0", "1", "0", "-1", "0", "6.12323e-17" 
     End With
End With
With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax_1:OuterConductor")
          .SetMeshType "All" 
          .Set "Transform", "6.12323e-17", "0", "1", "0", "1", "0", "-1", "0", "6.12323e-17" 
     End With
End With

'@ transform: rotate component1/Coax_1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1/Coax_1" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .Angle "0", "0", "90" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Rotate" 
End With

'@ pick end point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickEndpointFromId "component1/Coax_1:Dielectric", "4"

'@ pick mid point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickMidpointFromId "component1:Patch_main_1", "52"

'@ transform: translate component1/Coax_1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1/Coax_1" 
     .Vector "-37.407792388778", "-17", "-1.3985846100219" 
     .UsePickedPoints "True" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ pick face

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickFaceFromId "component1/Coax_1:Dielectric", "1"

'@ define port: 2

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Port 
     .Reset 
     .PortNumber "2" 
     .Label ""
     .Folder ""
     .NumberOfModes "1"
     .AdjustPolarization "False"
     .PolarizationAngle "0.0"
     .ReferencePlaneDistance "0"
     .TextSize "50"
     .TextMaxLimit "0"
     .Coordinates "Picks"
     .Orientation "positive"
     .PortOnBound "False"
     .ClipPickedPortToBound "False"
     .Xrange "-39.584292388778", "-35.231292388778"
     .Yrange "-32.99999", "-32.99999"
     .Zrange "-2.2200846100219", "2.1329153899781"
     .XrangeAdd "0.0", "0.0"
     .YrangeAdd "0.0", "0.0"
     .ZrangeAdd "0.0", "0.0"
     .SingleEnded "False"
     .WaveguideMonitor "False"
     .Create 
End With

'@ paste structure data: 4

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With SAT 
     .Reset 
     .FileName "*4.cby" 
     .SubProjectScaleFactor "0.001" 
     .ImportToActiveCoordinateSystem "True" 
     .ScaleToUnit "True" 
     .Curves "False" 
     .Read 
End With 

With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax_2:InnerConductor")
          .SetMeshType "All" 
          .Set "Transform", "6.12323e-17", "0", "1", "0", "1", "0", "-1", "0", "6.12323e-17" 
     End With
End With
With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax_2:Dielectric")
          .SetMeshType "All" 
          .Set "Transform", "6.12323e-17", "0", "1", "0", "1", "0", "-1", "0", "6.12323e-17" 
     End With
End With
With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax_2:OuterConductor")
          .SetMeshType "All" 
          .Set "Transform", "6.12323e-17", "0", "1", "0", "1", "0", "-1", "0", "6.12323e-17" 
     End With
End With

'@ transform: rotate component1/Coax_2

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1/Coax_2" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .Angle "0", "0", "90" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Rotate" 
End With

'@ pick end point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickEndpointFromId "component1/Coax_2:Dielectric", "4"

'@ pick mid point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickMidpointFromId "component1:Patch_main_2", "62"

'@ transform: translate component1/Coax_2

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1/Coax_2" 
     .Vector "37.407792388778", "-17", "-1.398584610022" 
     .UsePickedPoints "True" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ pick face

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickFaceFromId "component1/Coax_2:Dielectric", "1"

'@ define port: 3

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Port 
     .Reset 
     .PortNumber "3" 
     .Label ""
     .Folder ""
     .NumberOfModes "1"
     .AdjustPolarization "False"
     .PolarizationAngle "0.0"
     .ReferencePlaneDistance "0"
     .TextSize "50"
     .TextMaxLimit "0"
     .Coordinates "Picks"
     .Orientation "positive"
     .PortOnBound "False"
     .ClipPickedPortToBound "False"
     .Xrange "35.231292388778", "39.584292388778"
     .Yrange "-32.99999", "-32.99999"
     .Zrange "-2.220084610022", "2.132915389978"
     .XrangeAdd "0.0", "0.0"
     .YrangeAdd "0.0", "0.0"
     .ZrangeAdd "0.0", "0.0"
     .SingleEnded "False"
     .WaveguideMonitor "False"
     .Create 
End With

'@ paste structure data: 5

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With SAT 
     .Reset 
     .FileName "*5.cby" 
     .SubProjectScaleFactor "0.001" 
     .ImportToActiveCoordinateSystem "True" 
     .ScaleToUnit "True" 
     .Curves "False" 
     .Read 
End With 

With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax_3:InnerConductor")
          .SetMeshType "All" 
          .Set "Transform", "6.12323e-17", "0", "1", "0", "1", "0", "-1", "0", "6.12323e-17" 
     End With
End With
With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax_3:Dielectric")
          .SetMeshType "All" 
          .Set "Transform", "6.12323e-17", "0", "1", "0", "1", "0", "-1", "0", "6.12323e-17" 
     End With
End With
With MeshSettings
     With .ItemMeshSettings ("solid$component1/Coax_3:OuterConductor")
          .SetMeshType "All" 
          .Set "Transform", "6.12323e-17", "0", "1", "0", "1", "0", "-1", "0", "6.12323e-17" 
     End With
End With

'@ transform: rotate component1/Coax_3

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1/Coax_3" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .Angle "0", "0", "90" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Rotate" 
End With

'@ pick end point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickEndpointFromId "component1/Coax_3:Dielectric", "4"

'@ pick mid point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickMidpointFromId "component1:Patch_main_3", "62"

'@ transform: translate component1/Coax_3

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1/Coax_3" 
     .Vector "109.92202669308", "-17", "-19.81209999595" 
     .UsePickedPoints "True" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ pick face

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickFaceFromId "component1/Coax_3:Dielectric", "1"

'@ define port: 4

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Port 
     .Reset 
     .PortNumber "4" 
     .Label ""
     .Folder ""
     .NumberOfModes "1"
     .AdjustPolarization "False"
     .PolarizationAngle "0.0"
     .ReferencePlaneDistance "0"
     .TextSize "50"
     .TextMaxLimit "0"
     .Coordinates "Picks"
     .Orientation "positive"
     .PortOnBound "False"
     .ClipPickedPortToBound "False"
     .Xrange "107.74552669308", "112.09852669308"
     .Yrange "-32.99999", "-32.99999"
     .Zrange "-20.63359999595", "-16.28059999595"
     .XrangeAdd "0.0", "0.0"
     .YrangeAdd "0.0", "0.0"
     .ZrangeAdd "0.0", "0.0"
     .SingleEnded "False"
     .WaveguideMonitor "False"
     .Create 
End With

'@ change solver type

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
ChangeSolverType "HF Time Domain"

'@ define time domain solver parameters

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "False"
     .AutoNormImpedance "False"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ farfield plot options

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With FarfieldPlot 
     .Plottype "Polar" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "-1" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "True" 
     .ShowStructureProfile "True" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .AspectRatio "Free" 
     .ShowGridlines "True" 
     .InvertAxes "False", "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .IncludeUnitCellSidewalls "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .SetMaxReferenceMode "abs" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1.0" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  

     .StoreSettings
End With

'@ pick end point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickEndpointFromId "component1:Patch_main", "1"

'@ pick mid point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickMidpointFromId "component1:Patch_main", "52"

'@ transform: translate component1/Coax

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1/Coax" 
     .Vector "1.4421229054776", "-22.4", "0.56862454937318" 
     .UsePickedPoints "True" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ delete port: port1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Port.Delete "1"

'@ pick face

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickFaceFromId "component1/Coax:Dielectric", "1"

'@ define port: 1

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Port 
     .Reset 
     .PortNumber "1" 
     .Label ""
     .Folder ""
     .NumberOfModes "1"
     .AdjustPolarization "False"
     .PolarizationAngle "0.0"
     .ReferencePlaneDistance "0"
     .TextSize "50"
     .TextMaxLimit "0"
     .Coordinates "Picks"
     .Orientation "positive"
     .PortOnBound "False"
     .ClipPickedPortToBound "False"
     .Xrange "-112.56310201791", "-108.21010201791"
     .Yrange "-32.99999", "-32.99999"
     .Zrange "-20.818607394525", "-16.465607394525"
     .XrangeAdd "0.0", "0.0"
     .YrangeAdd "0.0", "0.0"
     .ZrangeAdd "0.0", "0.0"
     .SingleEnded "False"
     .WaveguideMonitor "False"
     .Create 
End With

'@ farfield plot options

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With FarfieldPlot 
     .Plottype "Polar" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "-1" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "True" 
     .ShowStructureProfile "True" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .AspectRatio "Free" 
     .ShowGridlines "True" 
     .InvertAxes "False", "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .IncludeUnitCellSidewalls "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .SetMaxReferenceMode "abs" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1.0" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  

     .StoreSettings
End With

'@ pick end point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickEndpointFromId "component1:Patch_main_3", "12"

'@ pick mid point

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickMidpointFromId "component1:Patch_main_3", "52"

'@ transform: translate component1/Coax_3

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Transform 
     .Reset 
     .Name "component1/Coax_3" 
     .Vector "2.3788239862797", "-21.8", "-0.91932963931291" 
     .UsePickedPoints "True" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .AutoDestination "True" 
     .Transform "Shape", "Translate" 
End With

'@ delete port: port4

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Port.Delete "4"

'@ pick face

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
Pick.PickFaceFromId "component1/Coax_3:Dielectric", "1"

'@ define port: 4

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With Port 
     .Reset 
     .PortNumber "4" 
     .Label ""
     .Folder ""
     .NumberOfModes "1"
     .AdjustPolarization "False"
     .PolarizationAngle "0.0"
     .ReferencePlaneDistance "0"
     .TextSize "50"
     .TextMaxLimit "1"
     .Coordinates "Picks"
     .Orientation "positive"
     .PortOnBound "False"
     .ClipPickedPortToBound "False"
     .Xrange "108.21257403505", "112.56557403505"
     .Yrange "-32.99999", "-32.99999"
     .Zrange "-20.812274981133", "-16.459274981133"
     .XrangeAdd "0.0", "0.0"
     .YrangeAdd "0.0", "0.0"
     .ZrangeAdd "0.0", "0.0"
     .SingleEnded "False"
     .WaveguideMonitor "False"
     .Create 
End With

'@ farfield plot options

'[VERSION]2025.0|34.0.1|20240830[/VERSION]
With FarfieldPlot 
     .Plottype "3D" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "5" 
     .Step2 "5" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "-1" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "True" 
     .ShowStructureProfile "True" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .AspectRatio "Free" 
     .ShowGridlines "True" 
     .InvertAxes "False", "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .IncludeUnitCellSidewalls "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .SetMaxReferenceMode "abs" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1.0" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  

     .StoreSettings
End With

