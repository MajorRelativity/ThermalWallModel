%% ThermalWallModel Version R0.02
% Updated on June 8 2022
% Code take from MatLab demonstration on how to model a wall with a crack
% in it.

%% Creating Model
thermalmodel = createpde('thermal','transient');

%% Importing and Ploting Geometry
geometryFromEdges(thermalmodel,@modelshapew);
pdegplot(thermalmodel,'EdgeLabels','on')
ylim([-10,10])
axis equal

%% Thermal Properties:

thermalProperties(thermalmodel,'ThermalConductivity',1,...
                               'MassDensity',1,...
                               'SpecificHeat',1);

thermalBC(thermalmodel,'Edge',1,'Temperature',100);
thermalBC(thermalmodel,'Edge',5,'HeatFlux',-10);

thermalIC(thermalmodel,0);

%% Generate Mesh

generateMesh(thermalmodel);
figure
pdemesh(thermalmodel)
title('Mesh with Quadratic Triangular Elements')


%% Set Times and Solve the Model:

tlist = 0:0.5:5;
thermalresults = solve(thermalmodel,tlist)
[qx,qy] = evaluateHeatFlux(thermalresults);

%% Plot Temperature and Heat Flux:

pdeplot(thermalmodel,'XYData',thermalresults.Temperature(:,end), ...
                     'Contour','on',...
                     'FlowData',[qx(:,end),qy(:,end)], ...
                     'ColorMap','hot')







