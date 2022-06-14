%% ThermalWallModel Version R1.01
% Updated on June 14 2022
% Description: Thermal model used to analyze lab conditions
% Code taken from MatLab demonstration on how to model a wall with a crack
% in it.

%% Documentation:
% This code comes in __ Stages:
% 1) Preferences: This section is made to be edited by users. It sets all
% of the variables that will be used for the rest of the process

% 2) Model Settings: Go here to edit the settings that will be used during
% the model.

% 3) While Statements: This section has two subfeatures. 
%   a) First, it has the power to analyze the effectiveness of various 
%   foam sizes, and second it has the power to find a mesh size 
%   for a desired time.
%   b) Second, it has the power to estimate the mesh size needed for a
%   desired minimum time length and maximum time length.

% 4) Mesh Graph: To aid in the understanding of the mesh size, the program
% can plot the mesh and geometry graphs after the model is run. This is
% configurable in preferences.

% 5) Animation: The script can also create an animation of the thermal
% model as it evolves through time. These specifications can be configured
% in preferences.

% 6) Log and Save: The program will save the data to two files. The
% MeshSettings get autosaved into a big file (for futre reference on
% times). The other Log Files can get saved into a separate
% LogData.mat file that contains the current date and time.

% Important Variables:
%   1) FLog = Table that logs all of the data for Foam Analysis
%   2) FLogD = A Double Version of FLog
%   3) MeshSettings specifies the appropriate mesh settings for specific
%   runtimes
%   4) PLog = The log for mesh generation testing.
%   5) TempAtIntersect = Gives temperature at intersection between foam and
%   wall
%   6) Specifications = Contains the key data for model writeups


%% Initialization and Preferences:

clear
close('all')

% Load:
qLL = 0;
%qLL = input('[?] Would you like to load log data? (1 = yes, 0 = no): ');
if qLL == 1
   disp('[?] Choose the Log file you would like to load: ')
   [filenameL, pathnameL] = uigetfile('*.*','[?] Choose the Log file you would like to load: ');
   addpath(pathnameL)
   load(filenameL)
   disp(['[+] File ',filenameL,' has been loaded!'])
   return
end

if exist('MeshSettings.mat','file')
    load 'MeshSettings.mat'
end

% Preferences:
qSM = 0; %Show Mesh and Geometry (1 = yes, 0 = no)
qSMp = 10; %Show Mesh Pause Length (s)
qPss = 0; %Plot Steady State Animation (1 = yes, 0 = no)
qIT = 0; %Readjust time? (1 = yes, 0 = no)
qFM = 1; % Foam Measurement Analysis? (1 = yes, 0 = no)
qP = 0; % Pause in between Models? (1 = yes, 0 = no)
qC = 0; % Cancel if time max is hit? (1 = yes, 0 = no). Only applies if qIT == 1

% Save Preferences:
qSMeshs = 2; % Save Mesh Settings Table (2 = yes, 1 = ask, 0 = no)
qSLog = 1; % Save Logs to ThermalData (2 = yes, 1 = ask, 0 = no)

%% User Edited Section (Model Settings):

% Model Type ("transient", "steadystate")
modelType = "steadystate";

% Shape of Wall:
FoamThickness = 2.54 * 10^-2; %m
FoamLength = 45.6 * 10^-2; %m
WallThickness = 5.08 * 10^-2; %m
WallLength = 126 * 10^-2; %m 

% Wall Thermal Properties:
ThermalConductivity = .03; % Thermal Conductivity for the Wall W/(m*K)
MassDensity = 24; % Mass Density for the Wall kg/m^3
SpecificHeat = 1500; % Specific Heat for the Wall J / kg * K

% Wall and Foam R Values. Foam Adjustment Settings:
Rw = 10; 
Rf = 5;
FMas = .01; % How much the foam size is decreased on each wraparound

% Heat Flux (if Applicable):
HFo = (1.82)*1055/((60*60)*(.305^2)); %Heat Flux Outdoor

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
%Hmaxg = .001; %Minimum Mesh Length Guess
%HdeltaP = .50; % The Percentage of Hmax you want the difference between
                  %the two to be. Given in # between 0 and 1, NOT percent.

Hmaxg = 7.62*10^-4; % Second Setting
HdeltaP = .90; % Second Setting

%Model Solver Settings:
Tmax = 70; %Max Time Allowed
Tmin = 50; %Min Time Allowed
tO = .5; %Time Percision: To what percision the model solver will keep track of the time it takes
Dp = 5; %Time Between Statements

%% Initialization

% Set to cancel if qIT = 1
qCstore = qC;
qITstore = qIT;
if qIT == 1
    qC = 1;
end

%Foam Modification
TriesF = 0;
pErrorT = 0;
FLc = 0;

%Initial Model
close
tf = FoamThickness;
lf = FoamLength;
Tw = WallThickness;
Lw = WallLength;

Hmax = Hmaxg; %Imports the Guess
ModelOTc = 0; %Overtime Count
ModelUTc = 0; %Undertime Count
ModelOT = 0; %Overtime 
ModelUT = 0; %Undertime
ModelIT = 0; %In Desired Time
rTries = 0; %Refinement Tries
cTries = 0; %Catch Up Tries
pModelT = 0; %Previous Model OT/UT

%Modifications:
PLc = 0;

modUT = 0.5; %initial change
modUTd = 0.1; %drastic change
modUTr0 = 0.7; %refinement changes
modUTr1 = 0.75;
modUTr2 = 0.80;
modUTr3 = 0.85;
modUTr4 = 0.90;
modUTr5 = 0.95;
modUTr6 = 0.99;

modOT = 2;
modOTd = 10;
modOTr0 = 1.30;
modOTr1 = 1.25;
modOTr2 = 1.20;
modOTr3 = 1.15;
modOTr4 = 1.10;
modOTr5 = 1.05;
modOTr6 = 1.01;

%% While Statements:
while pErrorT <= 10 %Foam Size Analysis

wallGeometry(Lw,Tw,lf,tf); %Ensures new geometry is loaded

while ModelIT == 0 || qIT == 0 % Time Analysis
Tries = ModelUTc + ModelOTc;

    %% Determining Changes to Hmin and Hmax:
    if qIT == 1    
        %Hmax
        if Tries >= 1 && pModelT ~= 0
            %Adjustments:
            if ModelOTc == 0
                if Tries >=3
                    Hmax = Hmax*modUTd;
                    mod = modUTd;
                else
                    Hmax = Hmax*modUT;
                    mod = modUT;
                end
                pModelT = 1;
                PrevEstimate = 'Undertime';
            elseif ModelUTc == 0
                if Tries >=3
                    Hmax = Hmax*modOTd;
                    mod = modOTd;
                else
                    Hmax = Hmax*modOT;
                    mod = modOT;
                end
                pModelT = 2;
                PrevEstimate = 'Overtime';
            else
                if ModelOT == 1 && pModelT == 1
                    Hmax = Hmax/mod; %undoes previous change

                    if rTries >= 0 && rTries < 1
                        Hmax = Hmax*modUTr0;
                        mod = modUTr0;
                    elseif rTries >= 1 && rTries < 2
                        Hmax = Hmax*modUTr1;
                        mod = modUTr1;
                    elseif rTries >= 2 && rTries < 3
                        Hmax = Hmax*modUTr2;
                        mod = modUTr2;
                    elseif rTries >= 3 && rTries < 4
                        Hmax = Hmax*modUTr3;
                        mod = modUTr3;
                    elseif rTries >= 4 && rTries < 5
                        Hmax = Hmax*modUTr4;
                        mod = modUTr4;
                    elseif rTries >= 5 && rTries < 6
                        Hmax = Hmax*modUTr5;
                        mod = modUTr5;
                    elseif rTries >= 6
                        Hmax = Hmax*modUTr6;
                        mod = modUTr6;
                    end
                    pModelT = 1;
                    PrevEstimate = 'Overtime';
                    cTries = 0;
    
                elseif ModelUT == 1 && pModelT == 2 
                    Hmax = Hmax/mod; %undoes previous change

                    if rTries >= 0 && rTries < 1
                        Hmax = Hmax*modOTr0;
                        mod = modOTr0;
                    elseif rTries >= 1 && rTries < 2
                        Hmax = Hmax*modOTr1;
                        mod = modOTr1;
                    elseif rTries >= 2 && rTries < 3
                        Hmax = Hmax*modOTr2;
                        mod = modOTr2;
                    elseif rTries >= 3 && rTries < 4
                        Hmax = Hmax*modOTr3;
                        mod = modOTr3;
                    elseif rTries >= 4 && rTries < 5
                        Hmax = Hmax*modOTr4;
                        mod = modOTr4;
                    elseif rTries >= 5 && rTries < 6
                        Hmax = Hmax*modOTr5;
                        mod = modOTr5;
                    elseif rTries >= 6
                        Hmax = Hmax*modOTr6;
                        mod = modOTr6;
                    end
                    pModelT = 2;
                    PrevEstimate = 'Undertime';
                    cTries = 0;

                elseif ModelUT == 1 && pModelT == 1
                    Hmax = Hmax*modUT;
                    mod = modUT;
                    pModelT = 1;
                    PrevEstimate = 'Undertime';
                    rTries = 0;

                elseif ModelOT == 1 && pModelT == 2 
                    Hmax = Hmax*modOT;
                    mod = modOT;
                    pModelT = 2;
                    PrevEstimate = 'Overtime';
                    rTries = 0;

                end
                rTries = rTries + 1; % Refinement Tries
                cTries = cTries + 1; % Catchup Tries (refinement doesn't work)
            end

            %Messages:
    
            disp(['[~] Previous Attempt was ',PrevEstimate])
            disp(['[*] Applying modification *',num2str(mod),' to Hmax'])
            
        elseif Tries >= 1 && pModelT == 0
%Adjustments:
            if ModelOTc == 0
                if Tries >=3
                    Hmax = Hmax*modUTd;
                    mod = modUTd;
                else
                    Hmax = Hmax*modUT;
                    mod = modUT;
                end
    
                pModelT = 1;
                PrevEstimate = 'Undertime';
            elseif ModelUTc == 0
                if Tries >=3
                    Hmax = Hmax*modOTd;
                    mod = modOTd;
                else
                    Hmax = Hmax*modOT;
                    mod = modOT;
                end
    
                pModelT = 2;
                PrevEstimate = 'Overtime';
            end
            
            %Messages:
    
            disp(['[&] Previous Attempt was ',PrevEstimate])
            disp(['[*] Applying modification *',num2str(mod),' to Hmax'])
            
        end
    end

    if rTries >= 100
        disp('[-] ThermalWallModel has tried over 100 times to refine the mesh. Enough is Enough. Try increasing HdeltaP.')
        return
    end

    %Hmin and Delta:
    Hdelta = Hmax*HdeltaP;
    Hmin = Hmax - Hdelta; %Maximum Mesh Length

    %Statements:
    disp('[&] Starting Model Attempt in 5 seconds')

    if qP == 1
        pause(3)
    end

    disp(['[&] Starting Model Attempt # ',num2str(Tries)])
    disp(['[#] Hmax = ',num2str(Hmax),', Hdelta = ',num2str(Hdelta),', Hmin = ',num2str(Hmin)])
    disp(['[#] Foam Length = ',num2str(lf)])

    if qP == 1
        pause(2)
    end

    %% Creating Model
    thermalmodel = createpde('thermal',modelType);
    
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
    if all(modelType=="transient")
        TCw = ThermalConductivity; 
        TMw = MassDensity; 
        TSw = SpecificHeat;
        
        thermalProperties(thermalmodel,'ThermalConductivity',TCw,...
                                       'MassDensity',TMw,...
                                       'SpecificHeat',TSw);
        disp('[~] Model Type = Transient')

    elseif all(modelType=="steadystate")
        TCw = ThermalConductivity; 
        thermalProperties(thermalmodel,'ThermalConductivity',TCw);
        disp('[~] Model Type = Steady State')
    end
    
    % Boundary and Initial Conditions (User Modifyable):
    
    thermalBC(thermalmodel,'Edge',1,'Temperature',TempwI);
    
    thermalBC(thermalmodel,'Edge',[3,5,7],'Temperature',TempwO);
    
    %thermalIC(thermalmodel, TempwO,'Edge',[3,5,7])
    thermalIC(thermalmodel,Tempi);
    
    disp('[+] Geomerty Imported and Conditions Applied')

    %% Set Times and Solve the Model:
    
    %Solve Model:
    tlist = 0:timeStep:timeE; 
    disp('[$] Generating Mesh')
    f(1) = parfeval(@generateMesh,1,thermalmodel,'Hmin',Hmin,'Hmax',Hmax);
    
    StateF1 = f(1).State(1) == 'f';
    StateF2 = 0;
    StartF2 = 0;
    Cc = 0;
    Pc = 0;
    Dc = 0;
    while StateF2 == 0
        StateF1 = f(1).State(1) == 'f';
        
        if StartF2 == 1
            StateF2 = f(2).State(1) == 'f';
        end
        if StateF1 == 1 && StartF2 == 0
            Ccm = Cc;
            disp('[$] Solving Thermal Model')
            thermalmodel.Mesh = fetchOutputs(f(1));
            f(2) = parfeval(@solve,1,thermalmodel,tlist);
            StartF2 = 1;
        end

        pause(tO)
        Cc = Cc + tO;
        Pc = (Cc/Tmax)*100;
        Dc = Dc+1;

        if Pc >= 100 && (Dc*tO) == Dp && qC == 1
            StateF2 = 1;
            Dc = 0;
            disp(['[-] Process has been running for ',num2str(Cc),' seconds. It will be canceled.'])
        elseif (Dc*tO) == Dp
            Dc = 0;
            disp(['[*] Process has been running for ',num2str(Cc),' seconds. It is ',num2str(Pc),'% to cutoff.'])
        end
    end
    
    if Pc >= 100 && qC == 1
        cancel(f)
        ModelOTc = ModelOTc+1;
        ModelOT = 1;
        ModelUT = 0;
        
        if qIT == 0
            return
        end

    elseif Cc <= Tmin
        cancel(f)
        ModelUTc = ModelUTc+1;
        ModelOT = 0;
        ModelUT = 1;
    else
        disp(['[+] Thermal Model Solved at ',num2str(Pc),'% of allowed time'])
        ModelIT = 1;
    end
    
    if qIT == 0 %For if time readjustment is not wanted
        disp('[+] Thermal Model Solved')
        ModelIT = 1;
        qIT = 1;
    end

    %Process Log:
    PLc = PLc + 1;
    PLog(PLc,1) = Tries;
    PLog(PLc,2) = rTries;
    PLog(PLc,3) = Hmin;
    PLog(PLc,4) = Hdelta;
    PLog(PLc,5) = Hmax;
    PLog(PLc,6) = ModelOT;
    PLog(PLc,7) = ModelUT;
    PLog(PLc,8) = Cc;

end

% Specifies that no more time reprosessing shall be done:
qIT = 0; 
qC = qCstore;

%Fetching and Processing Results
disp('[$] Processing Results')
thermalresults = fetchOutputs(f(2));
[qx,qy] = evaluateHeatFlux(thermalresults);
disp('[+] Results Processed')

%% Plot Temperature and Heat Flux:

% Create Mesh Plots

disp('[$] Creating Mesh Plots')

Fmg = figure('Name','Mesh Geomerty');
Fmg.Visible = "off";
pdemesh(thermalmodel)
title('Mesh with Quadratic Triangular Elements')
disp('[+] Mesh Plot Generated')

Fmgz = figure('Name','Mesh Geomerty Zoom');
Fmgz.Visible = "off";
pdemesh(thermalmodel)
hold on
axis([-tf,Tw+tf+tf,(-lf/10),(lf/10)])
title('Zoomed Mesh with Quadratic Triangular Elements (Zoomed About Center)')
movegui(Fmgz,'east');
hold off
disp('[+] Zoom Mesh Plot Generated')

% Show Mesh and Geometry
if qSM == 1
    movegui(Fmgz,'north')
    movegui(Fwg,'west')
    movegui(Fmg,'east')

    Fmgz.Visible = "on";
    Fwg.Visible = "on";
    Fmg.Visible = "on";

    disp(['[@] Displaying Geometry for ',num2str(qSMp),' second(s):'])

    pause(qSMp)
    close(Fwg)
    close(Fmg)
    close(Fmgz)
else
    close(Fmgz)
    close(Fmg)
    close(Fwg)
end

%Initial Setup:
if qPss == 1 && all(modelType == "transient")
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
elseif qPss == 1 && all(modelType == "steadystate")

% Figure Name

    Fname = "Steady State Model";

% Plot Figure:
    F.Name = Fname;
    pdeplot(thermalmodel,'XYData',thermalresults.Temperature(:,1), ...
                     'Contour','on',...
                     'FlowData',[qx(:,1),qy(:,1)], ...
                     'ColorMap','hot')
    xaxis = [0,Tw+tf+Tw];
    yaxis = [-3*Lw/4,3*Lw/4];
    axis([xaxis,yaxis])
    title(Fname)
    xlabel('Meters')
    ylabel('Meters')

end

%% Find Temperature at Point Between Foam Using interpolateTemperature:
disp('[$] Finding Temperatures in Between the Foam and Wall')
if all(modelType == "transient")
    Y = linspace(-lf/2,lf/2,11);
    cI = 1;
    for n = Y
    TempAtIntersect(cI) = interpolateTemperature(thermalresults,Tw,n,...
        size(tlist,2)); %interpolates temperature at (Tw,Y)
    cI = cI+1;
    end
elseif all(modelType == "steadystate")
    Y = linspace(-lf/2,lf/2,11);
    cI = 1;
    for n = Y
    TempAtIntersect(cI) = interpolateTemperature(thermalresults,Tw,n); %interpolates temperature at (Tw,Y)
    cI = cI+1;
    end
end

FI = [Y(2:end-1)',TempAtIntersect(2:end-1)']; %Returns array with first column being y values and second column being temperature values
FITable = array2table(FI);
FITable.Properties.VariableNames(1:2) = {'Y-Value','Temperature'};

%% Foam Modification End Statement:
if qFM == 0
    pErrorT = 999;
else
    % Calculate Error
    dTempRatio = ((TempwI-TempwO)/(FI(5,2)-TempwO)); %Whole Wall dT / Foam dT
    RwM = Rf * dTempRatio;
    RwM = RwM - Rf;
    pErrorT = abs((RwM - Rw)/Rw) * 100; %Percent Error
    
    % Log Current Settings
    FLc = FLc + 1;

    FLog(FLc,1) = TriesF;
    FLog(FLc,2) = lf;
    FLog(FLc,3) = dTempRatio;
    FLog(FLc,4) = RwM;
    FLog(FLc,5) = pErrorT;

    % ReAdjust Foam
    if pErrorT <= 10
        TriesF = TriesF + 1;
        lf = lf - FMas;
    end
end
    
end

%% Final Results:
% Process Logs:
PLog = array2table(PLog,...
    'VariableNames',{'Attempt','Refine Attempt','Hmin','Hdelta','Hmax','OT','UT','Time'});
disp('[+] Mesh Size Attempt Log Has Been Stored in "PLog"')
Specifications = [Hmin,HdeltaP,Hmax,'N/A','N/A',modelType];

if qFM == 1
    FLogD = FLog;
    FLog = array2table(FLog,...
    'VariableNames',{'Attempt #','Foam Length (m)','Delta Temp Ratio','Predicted Rwall','Percent Error (Rwall)'});
    disp('[+] Foam Size Attempt Log Has Been Stored in "FLog"')
    
    Specifications(4) = FLogD(1,2);
    Specifications(5) = FMas;
else
    FLog = 'N/A';
    FLogD = 'N/A';

end

Specifications = array2table(Specifications,...
    'VariableNames',{'Hmin','Hdelta (% of Hmax)','Hmax','Initial Foam Size','Foam Step','Model Type'});

% Save Logs:
qSLogTemp = qSLog;

while qSLog == 1
    qSLog = input('[?] Would you like to save Logs? (2 = yes, 0 = no): ');
    if qSLog == 1
        disp('[!] Invalid Input, try again.')
    end
end

if qSLog == 2
    disp('[?] Choose the path you want to save to:')
    pathName = uigetdir(path,'[?] Choose the path you want to save to:');
    LogSavename = [pathName,'/LogData ',datestr(now,'yyyy-mm-dd HH:MM:ss'),'.mat'];
    save(LogSavename,"FLog","FLogD","PLog","TempAtIntersect","Specifications")
    disp('[+] Logs have been saved.')
else
    disp('[-] Logs have not been saved.')
end


% Stores Hmin, Hdelta, and Hmax for certain time
if qITstore == 1
    if exist('MeshC','var')
        MeshC = MeshC+1;
    else
        MeshC = 1;
    end
    MeshSettingsD(MeshC,:) = [modelType,Cc,Hmax,HdeltaP,Hmin];
    MeshSettings = array2table(MeshSettingsD,'VariableNames',{'Model Type','Time (s)','Hmax (m)','HdeltaP (0 to 1)','Hmin (m)'});
    
    % Save:
    qSMeshsTemp = qSMeshs;

    while qSMeshs == 1
        qSMeshs = input('[?] Would you like to save the mesh settings? (2 = yes, 0 = no): ');
        if qSMeshs == 1
            disp('[!] Invalid Input, try again.')
        end
    end
    
    if qSMeshs == 2
        save('MeshSettings.mat',"MeshSettings","MeshC")
        disp('[+] Mesh Settings have been saved.')
    else
        disp('[-] Mesh Settings have not been saved.')
    end
    qSMeshs = qSMeshsTemp;
end

%Reset Question Variables (that needed to get adjusted mid run)
qIT = qITstore;

% Messages:
disp('[+] Temperatures Have Been Found and Stored in Array "FI" and Table "FITable"')
disp(['[#] Hmin was ',num2str(Hmin)])
disp(['[#] Hmax was ',num2str(Hmax)])
disp(['[#] Mesh Generation - Time Taken: ',num2str(Ccm),' seconds'])
disp(['[#] Thermal Model Solution - Time Taken: ',num2str(Cc),' seconds'])
