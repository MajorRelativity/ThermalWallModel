%% ThermalWallModel Version R0.09
% Updated on June 9 2022
% Code take from MatLab demonstration on how to model a wall with a crack
% in it.

%% User Edited Section:

% Shape of Wall:
FoamThickness = 1.6 * 10^-2; %m
FoamLength = 45.6 * 10^-2; %m
WallThickness = 5.1 * 10^-2; %m
WallLength = 126 * 10^-2; %m 

% Wall Thermal Properties:
ThermalConductivity = .03; % Thermal Conductivity for the Wall W/(m*K)
MassDensity = 24; % Mass Density for the Wall kg/m^3
SpecificHeat = 1500; % Specific Heat for the Wall J / kg * K

% Heat Flux (if Applicable):
HFo = (1.82)*1055/((60*60)*(.305^2)); %Heat Flux Outdoor

% Indoor Boundary Conditions (BC stays constant in time):
TempwI = 303; %Interior Wall Temperature K

% Outdoor Initial Conditions (IC are flexable with time):
TempwO = 297; %Outdoor Wall Temperature K
Tempi = 300; %Interior Temperature K

%Time Conditions:
timeE = 86400; %End Time s
timeStep = 5; %The step between when the model calculates s

%Plot Conditions:
timeStepP = 120; %The step in between plots s
PauseP = .1; %The time in between frames during plot s
qPF = 2; % 1 = display in seconds, 2 = display in minutes, 3 = display in hours
%% Initialization
close
tf = FoamThickness;
lf = FoamLength;
Tw = WallThickness;
Lw = WallLength;
wallGeometry(Lw,Tw,lf,tf)

%% Creating Model
thermalmodel = createpde('thermal','transient');

%% Importing and Ploting Geometry
geometryFromEdges(thermalmodel,@modelshapew);
figure(1)
axis equal
pdegplot(thermalmodel,'EdgeLabels','on')

%% Thermal Properties:

%Wall
TCw = ThermalConductivity; 
TMw = MassDensity; 
TSw = SpecificHeat;

thermalProperties(thermalmodel,'ThermalConductivity',TCw,...
                               'MassDensity',TMw,...
                               'SpecificHeat',TSw);

% Boundary and Initial Conditions:

thermalBC(thermalmodel,'Edge',1,'Temperature',TempwI);

%thermalBC(thermalmodel,'Edge',[3,5,7],'HeatFlux',-HFo);

thermalIC(thermalmodel, TempwO,'Edge',[3,5,7])
thermalIC(thermalmodel,Tempi);

%% Generate Mesh

generateMesh(thermalmodel,'Hmin',.001,'Hmax',.01);
figure(2)
pdemesh(thermalmodel)
title('Mesh with Quadratic Triangular Elements')


%% Set Times and Solve the Model:

tlist = 0:5:timeE; %24 hours
thermalresults = solve(thermalmodel,tlist)
[qx,qy] = evaluateHeatFlux(thermalresults);

%% Plot Temperature and Heat Flux:

pause(1)
close(2)
pause(1)
close(1)

%Initial Setup:
M = timeStepP/timeStep; %Time Skip
P = PauseP;

%Plot Animation
for n = M*(0:(size(tlist,2)/M))+1
    
    %Figure Name (seconds, minutes, or hours)
    if qPF == 2
        F = [num2str(tlist(n)/60),' minutes in'];
    elseif qPF == 3
        F = [num2str(tlist(n)/(60*60)),' hours in'];
    else
        F = [num2str(tlist(n)),' seconds in'];
    end

    %Plot Figure:
    figure('Name',F)
    pdeplot(thermalmodel,'XYData',thermalresults.Temperature(:,n), ...
                     'Contour','on',...
                     'FlowData',[qx(:,n),qy(:,n)], ...
                     'ColorMap','hot')
    pause(P)

    %Close Previous Figure
    if n>1
        close('Name',Fprev)
    end
    Fprev = F;
end



