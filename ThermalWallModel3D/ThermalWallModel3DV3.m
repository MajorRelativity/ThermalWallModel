%% ThermalWallModel3D v 3D0.05


clear

%% Preferences:

qF = 0; % Perform Foam analysis?
qAT = input(['[?] What would you like to do?','\n    Run Model = 1','\n    Analyze Data = 2','\n    Quit = -1','\n    Input: ']);
qS = 1; % Save Data? (1 = yes, 0 = no)

if qAT == 1

%% Model Specifications (User Edited):

% Model Type ("transient", "steadystate")
modelType = "steadystate";

% Shape of Wall:
FoamThickness = 2.54 * 10^-2; %m
FoamLength = 45.6 * 10^-2; %m
FoamHeight = FoamLength; 
WallThickness = 5.08 * 10^-2; %m
WallLength = 94 * 10^-2; %m 
WallHeight = 180 * 10^-2; %m 

% Wall Thermal Properties:
ThermalConductivity = .03; % Thermal Conductivity for the Wall W/(m*K)
MassDensity = 24; % Mass Density for the Wall kg/m^3
SpecificHeat = 1500; % Specific Heat for the Wall J / kg * K

% Wall and Foam R Values. Foam Adjustment Settings:
Rw = 10; 
Rf = 5;

% Indoor Boundary Conditions (BC stays constant in time):
TempwI = 303; %Interior Wall Temperature K

% Outdoor Initial Conditions (IC are flexable with time):
TempwO = 297; %Outdoor Wall Temperature K
Tempi = 300; %Interior Temperature K

%Time Conditions:
timeE = 60*30; %End Time s
timeStep = 60; %The step between when the model calculates s

%Initial Mesh Specifications:
%Hmax = .001; %Minimum Mesh Length Guess
%HdeltaP = .50; % The Percentage of Hmax you want the difference between
                  %the two to be. Given in # between 0 and 1, NOT percent.

Hmax = .5*10^-1; % Second Setting
HdeltaP = .10; % Second Setting
Hmin = Hmax*HdeltaP;

% Foam Modification Settings:
FstepT = .01; % Step size between foam trials for thickness
FstepH = .1;% Step size between foam trials for thickness
FstepL = .1; % Step size between foam trials for length
qSF = 1; %Only analyze square foam sizes?

% Save Settings:
save ModelSpecification.mat

%% Non-User Edited Settings:
if qS == 1
    disp('[?] Choose the path you want to save to:')
    pathName = uigetdir(path,'[?] Choose the path you want to save to:');
    LogSavename = [pathName,'/3DLogData ',datestr(now,'yyyy-mm-dd HH:MM:ss'),'.mat'];
end

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

    if qSF == 1
        Logic = Hfm == Lfm;
        Tfm = Tfm(Logic);
        Lfm = Lfm(Logic);
        Hfm = Hfm(Logic);
    end
    
    Foam = [Tfm, Lfm, Hfm];
elseif qF == 0
    Foam = [Tf,Lf,Hf];
end

qP = input(['[?] There are currently ',num2str(size(Foam,1)),' processes queued up, would you like to proceed?','\n    1 = yes','\n    0 = no','\n    Input: ']);
if qP == 0
    disp('[-] Quitting Program')
    return
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

Allocation = Fsize;

%Solve Models:
parfor (i = 1:size(Foam,1),Allocation)
    
    timeri = datetime('now')
    disp(['[&] Starting Process ',num2str(i),' on ',datestr(timeri)])

    Tf = Foam(i,1);
    Lf = Foam(i,2);
    Hf = Foam(i,3);
    [pErrorT,RwM,IntersectTemp] =  ThermalWallModel3DExecute(i,Tw,Lw,Hw,Tf,Lf,Hf)
    
    timerf = datetime('now')
    duration = timerf - timeri
    
    FAResults(i,:) = [i,time2num(duration,'seconds'),Tf,Lf,Hf,pErrorT,RwM,IntersectTemp]
    FAResultsD(i,:) = [i,0,Tf,Lf,Hf,pErrorT,RwM,IntersectTemp]


    disp(['[&] Process ',num2str(i),' has finished over duration: ',num2str(time2num(duration,'seconds')),' seconds'])
end

Specifications = [modelType,Hmax,HdeltaP,Rw,Rf,Tw,Lw,Hw,TempwI,TempwO,Tempi,ThermalConductivity]';
Specifications = array2table(Specifications,...
    'RowNames',{'Model','Hmax','HdeltaP (0 to 1)','R-wall','R-foam','Wall Thickness','Wall Length','Wall Height','Indoor BC','Outdoor BC','Interior Temp','Thermal Conductivity'});
FAResults = array2table(FAResults,...
    'VariableNames',{'Process','Duration (s)','F Thickness','F Length','F Height','% Error','Predicted Rwall','Temp at Intersection (K)' });

if qS == 1
    save(LogSavename,"FAResults","FAResultsD","Specifications")
    disp(['[+] Logs have been saved as ',LogSavename])
else
    disp('[-] Logs have not been saved')
end

elseif qAT == 2
    
   % Choosing Data to Load:
   disp('[?] Choose the Log file you would like to load: ')
   [filenameL, pathnameL] = uigetfile('*.*','[?] Choose the Log file you would like to load: ');
   addpath(pathnameL)
   load(filenameL)
   disp(['[+] File ',filenameL,' has been loaded!'])

else
    disp('[-] Quitting Program')
end