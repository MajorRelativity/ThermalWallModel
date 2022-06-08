%% ThermalWallModel Version R0.03
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

%Wall
TCw = .03; % Thermal Conductivity for the Wall W/(m*K)
TMw = .96 * ((100^3)/(10^3)); % Mass Density for the Wall kg/m^3
TSw = 1100 * (10^3); % Specific Heat for the Wall J / kg * K

thermalProperties(thermalmodel,'ThermalConductivity',TCw,...
                               'MassDensity',TMw,...
                               'SpecificHeat',TSw);

HF = (1.82)*1055/((60*60)*(.305^2))

thermalBC(thermalmodel,'Edge',1,'Temperature',303);
thermalBC(thermalmodel,'Edge',5,'HeatFlux',HF);

thermalIC(thermalmodel,0);

%% Generate Mesh

generateMesh(thermalmodel);
figure
pdemesh(thermalmodel)
title('Mesh with Quadratic Triangular Elements')


%% Set Times and Solve the Model:

tlist = 0:50:10^7;
thermalresults = solve(thermalmodel,tlist)
[qx,qy] = evaluateHeatFlux(thermalresults);

%% Plot Temperature and Heat Flux:

pdeplot(thermalmodel,'XYData',thermalresults.Temperature(:,end), ...
                     'Contour','on',...
                     'FlowData',[qx(:,end),qy(:,end)], ...
                     'ColorMap','hot')







