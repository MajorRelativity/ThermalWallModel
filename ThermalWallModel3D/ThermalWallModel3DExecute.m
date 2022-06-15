function [pErrorT,RwM,IntersectTemp] = ThermalWallModel3DExecute(i,Tw,Lw,Hw,Tf,Lf,Hf)
% Note: i refers to the process # (to support paralell computing)

%% Turn Of Warnings:
w = warning ('off','all');

%% Load Settings:

load('ModelSpecification.mat','')

%% Thermal Model:

thermalmodel = createpde('thermal',modelType);

%% Thermal Geometry:
gm = modelshapew3D(thermalmodel,Lw,Hw,Tw,Lf,Hf,Tf);
thermalmodel.Geometry = gm;
pdegplot(thermalmodel,'FaceLabels','on','FaceAlpha',.5)
disp(['[Process ',num2str(i),'] [+] Geometry Created'])

%% Initial Conditions:

if all(modelType=="transient")
    TCw = ThermalConductivity; 
    TMw = MassDensity; 
    TSw = SpecificHeat;
    
    thermalProperties(thermalmodel,'ThermalConductivity',TCw,...
                                   'MassDensity',TMw,...
                                   'SpecificHeat',TSw);
    disp(['[Process ',num2str(i),'] [~] Model Type = Transient'])

elseif all(modelType=="steadystate")
    TCw = ThermalConductivity; 
    thermalProperties(thermalmodel,'ThermalConductivity',TCw);
    disp(['[Process ',num2str(i),'] [~] Model Type = Steady State'])
end

%boundary Conditions:
thermalBC(thermalmodel,'Face',1,'Temperature',TempwI);

thermalBC(thermalmodel,'Face',[2,4],'Temperature',TempwO);

thermalIC(thermalmodel,Tempi);

%% Generate Mesh:

generateMesh(thermalmodel,'Hmin',Hmin,'Hmax',Hmax);
disp(['[Process ',num2str(i),'] [+] Mesh Generated'])

%% Solve Model:
if all(modelType=="transient")
tlist = 0:timeStep:timeE;
thermalresults = solve(thermalmodel,tlist);
else
    thermalresults = solve(thermalmodel);
end

disp(['[Process ',num2str(i),'] [+] Model Solved'])

%[qx,qy,qz] = evaluateHeatFlux(thermalresults);
%pdeplot3D(thermalmodel,"ColorMapData",thermalresults.Temperature)
%pdeplot3D(thermalmodel,"FlowData",[qx qy qz])

%% Predict R Value:

% Find Temperature at Intersection
IntersectTemp = interpolateTemperature(thermalresults,Tw,0,0);

% Find R Value:
dTempRatio = ((TempwI-TempwO)/(IntersectTemp-TempwO)); %Whole Wall dT / Foam dT
RwM = Rf * dTempRatio;
RwM = RwM - Rf;
pErrorT = abs((RwM - Rw)/Rw) * 100; %Percent Error

% Reenable Warnings:
w = warning ('on','all');