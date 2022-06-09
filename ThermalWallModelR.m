%% ThermalWallModel Version R0.10
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
timeE = 100000; %End Time s
timeStep = 100000; %The step between when the model calculates s

%Plot Conditions:
timeStepP = 100000; %The step in between plots s
PauseP = .1; %The time in between frames during plot s
qPF = 1; % 1 = display in seconds, 2 = display in minutes, 3 = display in hours
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

thermalBC(thermalmodel,'Edge',[3,5,7],'Temperature',TempwO);

%thermalIC(thermalmodel, TempwO,'Edge',[3,5,7])
thermalIC(thermalmodel,Tempi);
%% Generate Mesh

Mesh = generateMesh(thermalmodel,'Hmin',.001,'Hmax',.01);
figure(2)
pdemesh(thermalmodel)
title('Mesh with Quadratic Triangular Elements')


%% Set Times and Solve the Model:

tlist = 0:timeStep:timeE; %24 hours
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
cM = 1;

F = figure;
F.Visible = "off";
n = M*(0:((size(tlist,2)-1)/M))+1;
Fssp(size(n,2)) = struct('cdata',[],'colormap',[]);

%Plot Animation
for n = n
    
    %Figure Name (seconds, minutes, or hours)
    if qPF == 2
        Fname = [num2str(tlist(n)/60),' minutes in'];
    elseif qPF == 3
        Fname = [num2str(tlist(n)/(60*60)),' hours in'];
    else
        Fname = [num2str(tlist(n)),' seconds in'];
    end

    %Plot Figure:
    F.Name = Fname;
    pdeplot(thermalmodel,'XYData',thermalresults.Temperature(:,n), ...
                     'Contour','on',...
                     'FlowData',[qx(:,n),qy(:,n)], ...
                     'ColorMap','hot')
    title(Fname)

    %Store Figure:
    ax = gca; %axis
    ax.Units = 'pixels';
    axpos = ax.Position;
    marg1 = -30;
    marg2 = -20;
    marg3 = 100;
    marg4 = 100;
    %rect = [axpos(1)+marg1, axpos(2)+marg2, axpos(3)+marg3, axpos(4)+marg4];
    Fssp(cM) = getframe(F); %Fssp = Stores Progression to Steady State
    ax.Units = 'normalized';



    %Repeat:
    cM = cM + 1;
end

% Return figure visibility and play movie:
F.Visible = "on";
figure(2)
movie(gcf,Fssp)

%% Find Temperature at Point Between Foam:

Y = linspace(-lf/2,lf/2,11);
cI = 1;
for n = Y
TempIntersect(cI) = interpolateTemperature(thermalresults,Tw,n,...
    2) %interpolates temperature at (Tw,Y)
cI = cI+1
end


