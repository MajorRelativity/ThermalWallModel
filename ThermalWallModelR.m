%% ThermalWallModel Version R0.15
% Updated on June 9 2022
% Code take from MatLab demonstration on how to model a wall with a crack
% in it.

%% Initialization and Preferences:

clear
close('all')

%Preferences:
qSM = 1; %Show Mesh and Geometry (1 = yes, 0 = no)
qSMp = 1; %Show Mesh Pause Length (s)
qPss = 0; %Plot Steady State Animation (1 = yes, 0 = no)
qIT = 0; %Readjust time? (1 = yes, 0 = no)

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

%Initial Mesh Specifications:
Hming = .01; %Minimum Mesh Length Guess
Hdelta = 10^-3; %How much you are willing to let it be above the minimum length

%Model Solver Settings:
Tmax = 60; %Max Time Allowed
Tmin = 50; %Min Time Allowed
tO = .5; %Time Percision: To what percision the model solver will keep track of the time it takes
Dp = 5; %Time Between Statements

%% Initialization
%Initial Model
close
tf = FoamThickness;
lf = FoamLength;
Tw = WallThickness;
Lw = WallLength;
wallGeometry(Lw,Tw,lf,tf);

Hmin = Hming; %Imports the Guess
ModelOTc = 0; %Overtime Count
ModelUTc = 0; %Undertime Count
ModelOT = 0; %Overtime 
ModelUT = 0; %Undertime
ModelIT = 0; %In Desired Time
rTries = 0; %Refinement Tries

%Modifications:
modUT = 0.5; %initial change
modUTd = 0.1; %drastic change
modUTr0 = 0.9; %refinement changes
modUTr2 = 0.95;
modUTr5 = 0.97;
modUTr10 = 0.99;
modUTr20 = 0.995;
modUTr30 = 0.999;
modUTr50 = 0.9999;

modOT = 2;
modOTd = 10;
modOTr0 = 1.10;
modOTr2 = 1.05;
modOTr5 = 1.03;
modOTr10 = 1.01;
modOTr20 = 1.005;
modOTr30 = 1.001;
modOTr50 = 1.0001;


while ModelIT == 0
Tries = ModelUTc + ModelOTc;

    %% Determining Changes to Hmin and Hmax:

    %Hmin
    if Tries >= 1
        %Adjustments:
        if ModelOTc == 0
            if Tries >=3
                Hmin = Hmin*modUTd;
                mod = modUTd;

            else
                Hmin = Hmin*modUT;
                mod = modUT;
            end
            PrevEstimate = 'Undertime';
        elseif ModelUTc == 0
            if Tries >=3
                Hmin = Hmin*modOTd;
                mod = modOTd;
            else
                Hmin = Hmin*modOT;
                mod = modOT;
            end
            PrevEstimate = 'Overtime';
        else
            if ModelUT == 1
                if rTries >= 0
                    Hmin = Hmin*modUTr0;
                    mod = modUTr0;
                elseif rTries >= 2
                    Hmin = Hmin*modUTr2;
                    mod = modUTr2;
                elseif rTries >= 5
                    Hmin = Hmin*modUTr5;
                    mod = modUTr5;
                elseif rTries >= 10
                    Hmin = Hmin*modUTr10;
                    mod = modUTr10;
                elseif rTries >= 20
                    Hmin = Hmin*modUTr20;
                    mod = modUTr20;
                elseif rTries >= 30
                    Hmin = Hmin*modUTr30;
                    mod = modUTr30;
                elseif rTries >= 50
                    Hmin = Hmin*modUTr50;
                    mod = modUTr50;
                end
                
                PrevEstimate = 'Undertime';

            elseif ModelOT == 1
                if rTries >= 0
                    Hmin = Hmin*modOTr0;
                    mod = modOTr0;
                elseif rTries >= 2
                    Hmin = Hmin*modOTr2;
                    mod = modOTr2;
                elseif rTries >= 5
                    Hmin = Hmin*modOTr5;
                    mod = modOTr5;
                elseif rTries >= 10
                    Hmin = Hmin*modOTr10;
                    mod = modOTr10;
                elseif rTries >= 20
                    Hmin = Hmin*modOTr20;
                    mod = modOTr20;
                elseif rTries >= 30
                    Hmin = Hmin*modOTr30;
                    mod = modOTr30;
                elseif rTries >= 50
                    Hmin = Hmin*modOTr50;
                    mod = modOTr50;
                end
                PrevEstimate = 'Overtime';
            end

            rTries = rTries + 1;
        end
        
        %Messages:

        disp(['[&] Previous Attempt was ',PrevEstimate])
        disp(['[&] Applying modification *',num2str(mod),' to Hmin'])

    end

    if rTries >= 100
        disp('[-] ThermalWallModel has tried over 100 times to refine the mesh. Enough is Enough. Try increasing Hdelta.')
        return
    end

    %Hmax
    Hmax = Hmin + Hdelta; %Maximum Mesh Length

    %Statements:
    disp('[&] Starting Model Attempt in 5 seconds')
    pause(3)

    disp(['[&] Starting Model Attempt # ',num2str(Tries)])
    disp(['[#] Hmin = ',num2str(Hmin)])
    disp(['[#] Hmax = ',num2str(Hmax)])
    disp(['[#] Hdelta = ',num2str(Hdelta)])
    pause(2)

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
    
    % Boundary and Initial Conditions (User Modifyable):
    
    thermalBC(thermalmodel,'Edge',1,'Temperature',TempwI);
    
    thermalBC(thermalmodel,'Edge',[3,5,7],'Temperature',TempwO);
    
    %thermalIC(thermalmodel, TempwO,'Edge',[3,5,7])
    thermalIC(thermalmodel,Tempi);
    
    disp('[+] Geomerty Imported and Conditions Applied')
    %% Generate Mesh
    Mesh = generateMesh(thermalmodel,'Hmin',Hmin,'Hmax',Hmax);
    
    %% Set Times and Solve the Model:

    %Solve Model:
    tlist = 0:timeStep:timeE; 
    disp('[$] Solving Thermal Model')
    f(1) = parfeval(@solve,1,thermalmodel,tlist);
    f(2) = parfeval(@pause,0,Tmax);
    
    StateF = f(1).State(1) == 'f';
    Cc = 0;
    Pc = 0;
    Dc = 0;
    while StateF == 0
        StateF = f(1).State(1) == 'f';
        
        pause(tO)
        Cc = Cc + tO;
        Pc = (Cc/Tmax)*100;
        Dc = Dc+1;
    
        if Pc >= 100 && (Dc*tO) == Dp
            StateF = 1;
            Dc = 0;
            disp(['[-] Process has been running for ',num2str(Cc),' seconds. It will be canceled.'])
        elseif (Dc*tO) == Dp
            Dc = 0;
            disp(['[*] Process has been running for ',num2str(Cc),' seconds. It is ',num2str(Pc),'% to cutoff.'])
        end
    end
    
    if Pc >= 100 
        cancel(f)
        ModelOTc = ModelOTc+1;
        ModelOT = 1;
        ModelUT = 0;
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
    end
end

%Fetching and Processing Results
disp('[$] Processing Results')
thermalresults = fetchOutputs(f(1));
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


%% Final Results:
disp('[+] Temperatures Have Been Found and Stored in Array "FI" and Table "FITable"')
disp(['[#] Hmin was ',num2str(Hmin)])
disp(['[#] Hmax was ',num2str(Hmax)])
disp(['[#] Time Taken: ',num2str(Cc),' seconds'])
