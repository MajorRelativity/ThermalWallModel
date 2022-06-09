%% ThermalWallModel Version R0.13
% Updated on June 9 2022
% Code take from MatLab demonstration on how to model a wall with a crack
% in it.

%% Initialization and Preferences:

clear

%Preferences:
qSM = 1; %Show Mesh and Geometry (1 = yes, 0 = no)
qSMpm = 20; %Mesh Pause Duration (s)
qSMpw = 1; %Wall Pause Duration (s)
qPss = 0; %Plot Steady State Animation (1 = yes, 0 = no)

%% User Edited Section:

% Shape of Wall:
FoamThickness = 2.54 * 10^-2; %m
FoamLength = 45.6 * 10^-2; %m
WallThickness = 5.08 * 10^-2; %m
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
timeE = 60*60; %End Time s
timeStep = 60; %The step between when the model calculates s

%Plot Conditions:
timeStepP = 60; %The step in between plots s
qPF = 1; % 1 = display in seconds, 2 = display in minutes, 3 = display in hours

%Mesh Specifications:
Hmin = .0001; %Minimum Mesh Length
Hmax = .001; %Maximum Mesh Length

%% Initialization
close
tf = FoamThickness;
lf = FoamLength;
Tw = WallThickness;
Lw = WallLength;
wallGeometry(Lw,Tw,lf,tf);

%% Creating Model
thermalmodel = createpde('thermal','transient');

%% Importing and Ploting Geometry
disp('[$] Importing Geomerty and Applying Conditions')
geometryFromEdges(thermalmodel,@modelshapew);
Fwg = figure('Name','Wall Geometry');
Fwg.Visible = "off";
pdegplot(thermalmodel,'EdgeLabels','on')
xaxis = [0,Tw+tf+Tw];
yaxis = [-3*Lw/4,3*Lw/4];
axis([xaxis,yaxis])
hold on
axis square
hold off

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

disp('[+] Geomerty Imported and Conditions Applied')
%% Generate Mesh
disp('[$] Generating Mesh')
Mesh = generateMesh(thermalmodel,'Hmin',Hmin,'Hmax',Hmax);
Fmg = figure('Name','Mesh Geomerty');
Fmg.Visible = "off";
pdemesh(thermalmodel)
title('Mesh with Quadratic Triangular Elements')
disp('[+] Mesh Generated')

%% Set Times and Solve the Model:
tlist = 0:timeStep:timeE; %24 hours
disp('[$] Solving Thermal Model')
thermalresults = solve(thermalmodel,tlist);
[qx,qy] = evaluateHeatFlux(thermalresults);
disp('[+] Thermal Model Solved')

%% Plot Temperature and Heat Flux:

% Show Mesh and Geometry
if qSM == 1
    Fwg.Visible = "on";
    Fmg.Visible = "on";
    disp(['[@] Displaying Mesh Geometry for ',num2str(qSMpm),' second(s):'])
    pause(qSMpm)
    close(Fmg)
    disp(['[@] Displaying Wall Geometry for ',num2str(qSMpw),' second(s):'])
    pause(qSMpw)
    close(Fwg)
else
    close(Fmg)
    close(Fwg)
end

%Initial Setup:
if qPss == 1
    M = timeStepP/timeStep; %Time Skip
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
        xaxis = [0,Tw+tf+Tw];
        yaxis = [-3*Lw/4,3*Lw/4];
        axis([xaxis,yaxis])
        title(Fname)
        xlabel('Meters')
        ylabel('Meters')
    
        %Store Figure:
        Fssp(cM) = getframe(F); %Fssp = Stores Progression to Steady State
    
        % Inform User and Repeat:
        cM = cM + 1;
        FsspProgress = num2str((tlist(n)/tlist(end))*100); %Creates a Progress Bar
        disp(['[*] Building Steady State Creation Animation: ',FsspProgress,'% Complete'])
    end
    
    disp('[+] Steady State Creation Animation Completed')
    
    % Return figure visibility and play movie:
    close(F)
    figure('Name','Steady State Creation Animation')
    disp('[@] Playing "Steady State Creation Animation" (Fssp)')
    movie(gcf,Fssp,2,5)
end

%% Find Temperature at Point Between Foam Using interpolateTemperature:
disp('[$] Finding Temperatures in Between the Foam and Wall')
Y = linspace(-lf/2,lf/2,11);
cI = 1;
for n = Y
TempAtIntersect(cI) = interpolateTemperature(thermalresults,Tw,n,...
    size(tlist,2)); %interpolates temperature at (Tw,Y)
cI = cI+1;
end

FI = [Y(2:end-1)',TempAtIntersect(2:end-1)']; %Returns array with first column being y values and second column being temperature values
FITable = array2table(FI);
FITable.Properties.VariableNames(1:2) = {'Y-Value','Temperature'};

disp('[+] Temperatures Have Been Found and Stored in Array "FI" and Table "FITable"')

