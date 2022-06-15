%% ThermalWallModel3D v 3D0.05


clear

%% Preferences:
qF = 1; % Perform Foam analysis?

%% Model Specifications:

% Model Type ("transient", "steadystate")
modelType = "steadystate";

% Shape of Wall:
FoamThickness = 2.54 * 10^-2; %m
FoamLength = 45.6 * 10^-2; %m
FoamHeight = FoamLength; 
WallThickness = 5.08 * 10^-2; %m
WallLength = 126 * 10^-2; %m 
WallHeight = WallLength;

% Wall Thermal Properties:
ThermalConductivity = .03; % Thermal Conductivity for the Wall W/(m*K)
MassDensity = 24; % Mass Density for the Wall kg/m^3
SpecificHeat = 1500; % Specific Heat for the Wall J / kg * K

% Wall and Foam R Values. Foam Adjustment Settings:
Rw = 10; 
Rf = 5;
FMas = .01; % How much the foam size is decreased on each wraparound

% Indoor Boundary Conditions (BC stays constant in time):
TempwI = 303; %Interior Wall Temperature K

% Outdoor Initial Conditions (IC are flexable with time):
TempwO = 297; %Outdoor Wall Temperature K
Tempi = 300; %Interior Temperature K

%Time Conditions:
timeE = 60*30; %End Time s
timeStep = 60; %The step between when the model calculates s

%Plot Conditions:
timeStepP = 60; %The step in between plots s
qPF = 1; % 1 = display in seconds, 2 = display in minutes, 3 = display in hours

%Initial Mesh Specifications:
%Hmax = .001; %Minimum Mesh Length Guess
%HdeltaP = .50; % The Percentage of Hmax you want the difference between
                  %the two to be. Given in # between 0 and 1, NOT percent.

Hmax = 7.62*10^-2; % Second Setting
HdeltaP = .90; % Second Setting
Hmin = Hmax*HdeltaP;

% Foam Modification Settings:
FstepT = .005; % Step size between foam trials for thickness
FstepH = .05;% Step size between foam trials for thickness
FstepL = .05; % Step size between foam trials for length

% Save Settings:
save ModelSpecification.mat

%% Foam Modification Matrix:

Tf = FoamThickness;
Lf = FoamLength;
Hf = FoamHeight;
Tw = WallThickness;
Lw = WallLength;
Hw = WallHeight;

if qF == 1
    Tfm = 0:FstepT:Tf;
    Lfm = 0:FstepL:Lf;
    Hfm = 0:FstepH:Hf;
    [Tfm, Lfm, Hfm] = meshgrid(Tfm,Lfm,Hfm);
    
    Logic = Tfm > 0 & Lfm > 0 &  Hfm > 0;
    Tfm = Tfm(Logic);
    Lfm = Lfm(Logic);
    Hfm = Hfm(Logic);
    
    Foam = [Tfm, Lfm, Hfm];
elseif qF == 0
    Foam = [Tf,Lf,Hf];
end
%% Execute Model:

% Create Paralell Pool:
F = gcp;

% Find Size of Pool:
if isempty(F)
    Fsize = 0;
else
    Fsize = F.NumWorkers;
end

% Solve Models:

parfor (i = 1:size(Foam,1),Fsize)
    
    timeri = datetime('now')
    disp(['[&] Starting Process ',num2str(i),' on ',datestr(timeri)])

    Tf = Foam(i,1);
    Lf = Foam(i,2);
    Hf = Foam(i,3);
    [pErrorT,RwM,IntersectTemp] =  ThermalWallModel3DExecute(i,Tw,Lw,Hw,Tf,Lf,Hf)
    
    timerf = datetime('now')
    duration = timerf - timeri
    
    FAResults(i,:) = [i,duration,Tf,Lf,Hf,pErrorT,RwM,IntersectTemp]
    FAResultsD(i,:) = [i,0,Tf,Lf,Hf,pErrorT,RwM,IntersectTemp]


    disp(['[&] Process ',num2str(i),' has finished over duration: ',datestr(duration)])
end
