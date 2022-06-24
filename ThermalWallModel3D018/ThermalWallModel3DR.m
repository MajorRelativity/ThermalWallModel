%% ThermalWallModel3D v 3D0.18.02
% Updated on June 23 2022
% Created by Jackson Kustell

clear

%% Documentation:

% Process ID:
% 000) Collection
% 
%   001) Generate Geometry
%   002) Solve Model From Geometry
%   003) Y-Slice Foam Analysis Contour Plot
%
% 100) PreRun
%
%   101) Foam Name Translation
%   102) Foam Analysis - Matrix Creation
%   103) Foam Matrix if no Foam Analysis
%   104) Specify Thermal Model File Identification Number
%   105) Create Log Directory
%   106) Automatically Create LogSavename
%
% 200) Load / Save / Store
%
%   201) Make Directory and Save ModelSpecification.mat
%   202) Load ModelSpecification.mat
%   203) Make Directory and Save ThermalModel.mat
%   204) Load ThermalModel.mat
%   205) Save Foam Analysis Log Data
%   206) Load Foam Analysis Log Data
%
% 300) Modification
%
%   301) Select Model Number
%
% 400) Operation
%
%   401) Create Single New Thermal Model
%   402) Generate Single Geometry
%   403) User Verify Single Geometry and Apply Initial Conditions
%   404) Generate Single Mesh
%   405) Solve Single Model
%
% 500) Post Processing
%
%   501) Start Timer
%   502) End Timer
%   503) Find Predicted R Value and Percent Error
%   504) Duration with time2num
%   505) Collect Foam Analysis Result Variables
%   506) Create Foam Analysis Table
%
% 600) Analysis
%
%   601) Create Y Slice Foam Analysis Thermal Plot (Horzontile)
%

%% Model Specifications (User Edited):

% Specification Mode:
qMS = 201; % 201 = save, 202 = load

% Model Type ("transient", "steadystate")
modelType = "steadystate";
qRM = 0; % Use reduced size mode? (1 = yes, 0 = no). Uses only the upper left quadrant

% Shape of Wall:
FoamThickness = 2.54 * 10^-2; %m
FoamLength = 45.6 * 10^-2; %m
FoamHeight = FoamLength; 
WallThickness = 5.08 * 10^-2; %m
WallLength = 90 * 10^-2; %m 
WallHeight = WallLength;

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
%Hmax = 2.1*10^-3; % Max Mesh Length
%HdeltaP = .10; % Percent of Hmax Hmin is
%Hmin = Hmax*HdeltaP;

Hmax = 20*10^-3; % Max Mesh Length
HdeltaP = .10; % Percent of Hmax Hmin is
Hmin = Hmax*HdeltaP;

% Foam Modification Settings:
FstepT = 1; % Step size between foam trials for thickness
FstepH = .1;% Step size between foam trials for thickness
FstepL = .1; % Step size between foam trials for length
qSF = 1; %Only analyze square foam sizes?
qPar = 0; % Use Parallel Processing

%% Save or Load Model Specifications

if ~exist('ModelSpecifications','dir')
    mkdir ModelSpecifications
end

MSN = input('[?] Choose a Model Specification #: ');
MS = ['ModelSpecifications/ModelSpecification',num2str(MSN),'.mat'];

switch qMS
    
    case 201
        savedate = datetime('now');
        save(MS)
        disp(['[+] Model Specifications have been saved to ',MS,' at ',datestr(savedate)])
    case 202
        load(MS)
        disp(['[+] Model Specifications have been loaded from ',MS,' from ',datestr(savedate)])

end


%% Collection Selection:

% Collections:
Colstr1 = '\n    1 = Generate Single Geometry ';
Colstr2 = '\n    2 = Run Single Model From Geometry ';
Colstr3 = '\n    3 = Y-Slice Foam Analysis Contour Plot';
Colstr = [Colstr1,Colstr2,Colstr3];


% Create Variables:
gateC = 1;
numC = 1;

% Question:
while gateC == 1
    switch numC
        case 1
            qCollection(numC) = input(['[?] What would you like to do?','\n   -1 = Quit ',Colstr]);
        otherwise
            qCollection(numC) = input(['[?] What else would you like to do?','\n   -1 = Quit ','\n    0 = Run with Nothing Else ',Colstr]);
    end
    
    switch qCollection(numC)
        case -1
            disp('[~] Quitting Script')
            return
        case 0
            gateC = 0;
            numC = numC - 1;
        otherwise
            numC = numC + 1;
    end
    
end

% Clear Collection Names:
clear -regexp Colstr

% Preallocate Varaibles: 

maxpreP = 4;
preP = zeros(numC,maxpreP); % Second digit must be maximum size of program line
numC = 1;

% Create Pre-Run Process Index:

for C = qCollection
    
    switch C
        case 0
            % Ignore
            numC = numC - 1;
        case 1            
            % Program #1 - Generate Geometry
            prePline = [101 103 104 1]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                disp(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
                return
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
       case 2          
            % Program #2 - Run Model From Geometry
            prePline = [104 105 106 2]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                disp(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
                return
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
    end
    
    numC = numC + 1;
    
end

%% Prerun:

disp('[&] Initializing Collections')

% Max Program Size:
maxP = 13;

% Prerun and Create Run Index
for preI = 1:size(preP,1)
    for prep = preP(preI,:)
        switch prep
            case 101
                % Foam Name Translation:
                Tf = FoamThickness;
                Lf = FoamLength;
                Hf = FoamHeight;
                Tw = WallThickness;
                Lw = WallLength;
                Hw = WallHeight;

                disp('[+] [101] Foam Names Translated')

            case 102
                % Foam Analysis - Matrix Creation

                Tfm = Tf:-FstepT:0;
                Lfm = Lf:-FstepL:0;
                Hfm = Hf:-FstepH:0;
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

                Foam = [Tfm, Lfm, Hfm]; % Full foam matrix

                Tf = Foam(:,1); % All thicknesses
                Lf = Foam(:,2); % All lengths
                Hf = Foam(:,3); % All heights

                disp('[+] [102] Foam Matrix Created')

            case 103
                % Foam Matrix if no Foam Analysis

                Foam = [Tf,Lf,Hf];

                disp('[+] [103] Foam Vector Created')
                
            case 104
                if ~exist('ran104','var')
                    MN = input('[?] [104] Choose a Thermal Model File ID Number #: ');
                    MNstr = num2str(MN);
                    ran104 = 1;
                    disp(['[#] [104] Script Will Pull From and Save To Model: ',MN])
                end
            case 105
                % Create Log Directory
                if ~exist('ThermalData','dir')
                    mkdir ThermalData
                    disp('[+] [105] ThermaData Directory Created')
                end
            case 106
                % Automaticall Create LogSavename
                LogSavename = ['ThermalData/3DLogData ',datestr(now,'yyyy-mm-dd HH:MM:ss'),'.mat'];
                disp(['[+] [106] Logs will be saved to',LogSavename])
            case 1
                % Program #1 - Generate Geometry
                Pline = [1 401 402 403 203]; % All collections must start with their collection #
                
                % Add zeros if program size is less than max size
                    
                if size(Pline,2) < maxP
                    Pline = [Pline, zeros(1,maxP - size(Pline,2))];
                elseif size(Pline,2) > maxP
                    disp(['[!] Max Program Size MUST be updated to ',num2str(size(Pline,2))])
                    return
                end
                
                % Concatonate to P
                
                if exist('P','var')
                    P = [P;Pline];
                else
                    P = Pline;
                end

            case 2
                % Program #2 - Run Model From Geometry
                Pline = [2 204 301 501 404 405 502 503 504 505 506 203 205]; % All collections must start with their collection #
                
                % Add zeros if program size is less than max size
                    
                if size(Pline,2) < maxP
                    Pline = [Pline, zeros(1,maxP - size(Pline,2))];
                elseif size(Pline,2) > maxP
                    disp(['[!] Max Program Size MUST be updated to ',num2str(size(Pline,2))])
                    return
                end
                
                % Concatonate to P
                
                if exist('P','var')
                    P = [P;Pline];
                else
                    P = Pline;
                end
                
        end
    end
end

disp('[=] Collections Initialized')


%% Run:

for I = 1:size(P,1)
    for p = P(I,:)
        switch p
            case 0
                % Ignore
            case 1
                % Collection #1 - Generate Geometry
                disp('[&] Starting Collection #1 - Generate Geometry')
            case 2
                % Collection #2 - Solve Thermal Model
                disp('[&] Starting Collection #2 - Solve Thermal Model')
            case 203
                % Make Directory:
                if ~exist('ThermalModels','dir')
                    mkdir ThermalModels
                    disp('[+] [203] ThermaModels Directory Created')
                end

                % Save Thermal Model to Mat File
                save(['ThermalModels/ThermalModel',MNstr,'.mat'],'ThermalModel','numM','numMstr','MN','MNstr','MS','MSN')
                disp(['[+] [203] [Model ',numMstr,'] ','Saving to Model Number ',MNstr])
            case 204
                % Load Thermal Model from Mat File:
                load(['ThermalModels/ThermalModel',MNstr,'.mat'])
                disp(['[+] [204] [Model ',numMstr,'] ','Loading from Model Number ',MNstr])

                % Force Model Specification:
                load(MS)
                disp(['[+] [204] [Model ',numMstr,'] ','Forced Model Specifications from ',MS])
            case 205
                % Save Foam Analysis Logs
                save(LogSavename,"FAResults","FAResultsD","Specifications","ThermalModel","ThermalResults")
                disp(['[+] Logs have been saved with thermalresults as ',LogSavename])

            case 206
                % Load Foam Analysis Logs
                disp('[?] Choose the Log file you would like to load: ')
                [filenameFAL, pathnameFAL] = uigetfile('*.*','[?] Choose the Log file you would like to load: ');
                addpath(pathnameFAL)
                load(filenameFAL)
                disp(['[+] File ',filenameFAL,' has been loaded!'])
            case 301
                % Select Thermal Model Number:
                qnumM = input(['[?] [301] [Model ',numMstr,'] ','Current Model Number: ',numMstr,'\n    Choose a New One? (-1 = no or Input #): ']);
                if qnumM <= 0
                    disp(['[-] [301] [Model ',numMstr,'] ','Model Number Not Modified'])
                else
                    numM = qnumM;
                    numMstr = num2str(numM);
                    disp(['[+] [301] [Model ',numMstr,'] ','New Model Number Chosen: ',numMstr])
                end
            case 401
                % Create Single New Thermal Model
                if exist('numM','var') % Model #
                    numM = numM + 1;
                else
                    numM = 1;
                end
                numMstr = num2str(numM);
                
                thermalmodel = createpde('thermal',modelType);
                ThermalModel{numM} = thermalmodel;
                disp(['[+] [401] [Model ',numMstr,'] ','New Thermal Model Created'])
            case 402
                % Generate Single Geometry
                disp(['[$] [402] [Model ',numMstr,'] ','Generating Geometry'])
                ThermalModel{numM}.Geometry = modelshapew3D(thermalmodel,qRM,Lw,Hw,Tw,Lf,Hf,Tf);
                disp(['[+] [402] [Model ',numMstr,'] ','Geometry Generated'])
                
            case 403
                % User Verify Single Geometry and Apply Initial Conditions
                disp(['[$] [403] [Model ',numMstr,'] ','Verifying Geometry'])
                
                % Create Variables
                thermalmodel = ThermalModel{numM};
                gateV = 0;
                
                % Verify Geometry
                while gateV == 0
                    figure(1)
                    pdegplot(thermalmodel,'FaceLabels','on','FaceAlpha',.5);

                    drawnow

                    IndoorF = input(['[?] [403] [Model ',numMstr,'] ','Specfy the face # of the indoor side: ']);
                    OutdoorFF = input(['[?] [403] [Model ',numMstr,'] ','Specify the face # of the outdoor foam side: ']);
                    OutdoorWF = input(['[?] [403] [Model ',numMstr,'] ','Specify the face # of the outdoor wall side: ']);

                    % Run Prototype Model for Check
                    disp(['[*] [403] [Model ',numMstr,'] ','Running Prototype Model for Check'])
                    generateMesh(thermalmodel,'Hmin',0.2,'Hmax',1);

                    figure(1)

                    thermalBC(thermalmodel,'Face',IndoorF,'Temperature',TempwI); % These boundary conditions will be kept for the final model
                    thermalBC(thermalmodel,'Face',[OutdoorFF,OutdoorWF],'Temperature',TempwO);


                    if all(modelType=="transient")

                        thermalIC(thermalmodel,Tempi); % Initial Conditions only apply to tranient models

                        TCw = ThermalConductivity; 
                        TMw = MassDensity; 
                        TSw = SpecificHeat;

                        thermalProperties(thermalmodel,'ThermalConductivity',TCw,...
                                                       'MassDensity',TMw,...
                                                       'SpecificHeat',TSw);

                    elseif all(modelType=="steadystate")
                        TCw = ThermalConductivity; 
                        thermalProperties(thermalmodel,'ThermalConductivity',TCw);
                    end

                    % Geometry Test Results:
                    resultstest = solve(thermalmodel);
                    pdeplot3D(thermalmodel,"ColorMapData",resultstest.Temperature)

                    drawnow

                    gateV = input(['[?] [403] [Model ',numMstr,'] ','Does this model look correct? (1 = y, 0 = n): ']);
                    if gateV == 0
                        disp(['[!] [403] [Model ',numMstr,'] ',"You likely didn't assign the sides correctly, try again!"])
                    else
                        ThermalModel{numM} = thermalmodel;
                        disp(['[+] [403] [Model ',numMstr,'] ','Geometry Verified'])
                    end
                    
                end
            case 404
                % Generate Single Mesh:
                disp(['[$] [404] [Model ',numMstr,'] ','Generating Mesh'])
                ThermalModel{numM}.Mesh = generateMesh(ThermalModel{numM},'Hmin',Hmin,'Hmax',Hmax);
                disp(['[+] [404] [Model ',numMstr,'] ','Mesh Generated'])

            case 405
                % Solve Single Thermal Model
                disp(['[$] [405] [Model ',numMstr,'] ','Solving Model'])
                ThermalResults{numM} = solve(ThermalModel{numM});
                disp(['[+] [405] [Model ',numMstr,'] ','Model Solved'])

            case 501
                % Start Timer
                timeri = datetime('now');
                disp(['[+] [501] [Model ',numMstr,'] ','Timer Started at ',datestr(timeri)])
            case 502
                % End Timer
                timerf = datetime('now');
                disp(['[+] [502] [Model ',numMstr,'] ','Timer Ended at ',datestr(timerf)])

            case 503
                % Find Predicted R Value:
                disp(['[$] [503] [Model ',numMstr,'] ','Finding Predicted R Value'])
                % Find Temperature at Intersection:
                IntersectTemp = interpolateTemperature(ThermalResults{numM},Tw,0,0);
                
                % Find R Value and Percent Error:
                dTempRatio = ((TempwI-TempwO)/(IntersectTemp-TempwO)); %Whole Wall dT / Foam dT
                RwM = Rf * dTempRatio;
                RwM = RwM - Rf;
                pErrorT = abs((RwM - Rw)/Rw) * 100; %Percent Error
            case 504
                % Duration with time2num
                duration = timerf - timeri;
                duration = time2num(duration,'seconds');
            case 505
                % Collect Foam Analysis Result Variables
                FAResultsD(numM,:) = [numM,duration,Tf,Lf,Hf,pErrorT,RwM,IntersectTemp];
                Specifications = [modelType,Hmax,HdeltaP,Rw,Rf,Tw,Lw,Hw,TempwI,TempwO,Tempi,ThermalConductivity]';
            case 506
                % Create Foam Analysis Result Tables
                Specifications = array2table(Specifications,...
                    'RowNames',{'Model','Hmax','HdeltaP (0 to 1)','R-wall','R-foam','Wall Thickness','Wall Length','Wall Height','Indoor BC','Outdoor BC','Interior Temp','Thermal Conductivity'});
                FAResults = array2table(FAResultsD,...
                    'VariableNames',{'Process','Duration (s)','Foam Thickness','Foam Length','Foam Height','% Error','Predicted Rwall','Temp at Intersection (K)' });
                disp(['[+] [506] [Model ',numMstr,'] ','Foam Analysis Results Tables Created'])

            case 601
                % Y Slice Analysis (Horzontile)
               gateP = 1;
               while gateP == 1
                   qTRpa = input('[?] [601] What row(s) would you like to plot? (-1 = all, or input row index # from FAResults): ');
                   Ypos = input('[?] [601] Please Select the Y position you wish to plot: ');
                   if qTRpa == -1
                       gateP = 0;
                        for i = 1:size(ThermalResults,2)
                            
                            % Create Figure:
                            disp(['[*] [601] Plotting Model #',num2str(i)])
                            fname = ['Results From Process #',num2str(i)];
                            figure('Name',fname)
                            
                            % Pull Necessary Data for This Model:
                            Tw = str2double(Specifications{6,1});
                            Hw = str2double(Specifications{8,1});
                            Tf = FAResultsD(i,3);
                
                            thermalresults = ThermalResults{i};
                            
                            % Create Mesh and Plot:
                
                            [X,Z] = meshgrid(linspace(0,(Tw+Tf)),linspace(-Hw/2,Hw/2));
                            Y = Ypos.*ones(size(X,1),size(X,2));
                            V = interpolateTemperature(thermalresults,X,Y,Z);
                            V = reshape(V,size(X));
                            surf(X,Z,V,'LineStyle','none');
                            view(0,90)
                            title('Colored Plot through Y (Length) = 0')
                            xlabel('X (Thickness)')
                            ylabel('Z (Height)')
                            colorbar
                        end
                   else
                       i = qTRpa;
                       % Create Figure:
                        disp(['[*] [601] Plotting Model #',num2str(i)])
                        fname = ['Results From Model #',num2str(i)];
                        figure('Name',fname)
                        
                        % Pull Necessary Data for This Model:
                        Tw = str2double(Specifications{6,1});
                        Hw = str2double(Specifications{8,1});
                        Tf = FAResultsD(i,3);
            
                        thermalresults = ThermalResults{i};
                        
                        % Create Mesh and Plot:
            
                        [X,Z] = meshgrid(linspace(0,(Tw+Tf)),linspace(-Hw/2,Hw/2));
                        Y = Ypos.*ones(size(X,1),size(X,2));
                        V = interpolateTemperature(thermalresults,X,Y,Z);
                        V = reshape(V,size(X));
                        surf(X,Z,V,'LineStyle','none');
                        view(0,90)
                        title('Colored Plot through Y (Length) = 0')
                        xlabel('X (Thickness)')
                        ylabel('Z (Height)')
                        colorbar
                        gateP = input('[?] [601] Would you like to plot more rows? (1 = yes, 0 = no): ');
                   end
               end
                
        end
    end
    % Finish Collection:
    disp(['[=] Collection #',num2str(P(I,1)),' Finished'])
end
        
        
        
        
        
        