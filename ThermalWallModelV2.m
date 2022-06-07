%% Geomertry
clf
thermalmodel = createpde('thermal','transient');
geometryFromEdges(thermalmodel,@modelshapew);
pdegplot(thermalmodel,'EdgeLabels','on')
ylim([-10,10])
axis equal

%% Manual Thermal Property Settings:
%Foam:
TCf = 5;
TMf = 5;
TSf = 5;

%Wall
TCw = 10;
TMw = 10;
TSw = 10;


%% Thermal Properties of the Material:

global Tw
C = @(location,state) (location.x>=Tw).*5 + (location.x<Tw).*10;
M = @(location,state) (location.x>=Tw).*5 + (location.x<Tw).*10;
S = @(location,state) (location.x>=Tw).*5 + (location.x<Tw).*10;

thermalProperties(thermalmodel,'ThermalConductivity',C,...
                               'MassDensity',M,...
                               'SpecificHeat',S);

%% Thermal Initial Conditions (must be edited manually):

thermalBC(thermalmodel,'Edge',1,'Temperature',100);
thermalBC(thermalmodel,'Edge',5,'HeatFlux',-10);
thermalBC(thermalmodel,'Edge',3,'HeatFlux',-10);
thermalBC(thermalmodel,'Edge',7,'HeatFlux',-10);
thermalIC(thermalmodel,0);

%% Generating The Mesh
generateMesh(thermalmodel);
figure
pdemesh(thermalmodel)
title('Mesh with Quadratic Triangular Elements')
tlist = 0:0.5:10;
thermalresults = solve(thermalmodel,tlist)
[qx,qy] = evaluateHeatFlux(thermalresults);
pdeplot(thermalmodel,'XYData',thermalresults.Temperature(:,end), ...
                     'Contour','on',...
                     'FlowData',[qx(:,end),qy(:,end)], ...
                     'ColorMap','hot')
                 
