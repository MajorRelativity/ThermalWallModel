%% ThermalWallModel3D v 3D0.18
% Updated on June 23 2022
% Created by Jackson Kustell

clear

%% Documentation:

% Process ID:
% 000) Collection
% 
%   001) Generate Geometry
%
% 100) Pre
%
%   101) Foam Name Translation
%   102) Foam Analysis - Matrix Creation
%   103) Foam Matrix if no Foam Analysis
%   104) Specify Thermal Model Identification Number
%
% 200) Load / Save / Store
%
%   201) Save ModelSpecification.mat
%   202) Load ModelSpecification.mat
%   203) Save ThermalModel.mat
%   204) Load ThermalModel.mat
%
% 300) Modification
%
%
% 400) Operation
%
%   401) Create Single New Thermal Model
%   402) Generate Single Geometry
%   403) User Verify Single Geometry
%
% 500) Analysis
%
%
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
Hmax = 2.1*10^-3; % Max Mesh Length
HdeltaP = .10; % Percent of Hmax Hmin is
Hmin = Hmax*HdeltaP;

% Foam Modification Settings:
FstepT = 1; % Step size between foam trials for thickness
FstepH = .1;% Step size between foam trials for thickness
FstepL = .1; % Step size between foam trials for length
qSF = 1; %Only analyze square foam sizes?
qPar = 0; % Use Parallel Processing

%% Save or Load Model Specifications

MSN = input('[?] Choose a Model Specification #: ');
MS = ['ModelSpecification',num2str(MSN),'.mat'];

switch qMS
    
    case 201
        savedate = datetime('now');
        save(MS)
        disp(['[+] Model Specifications have been saved to ',MS,' at ',datestr(savedate)])
    case 202
        load(MS)
        
end


%% Collection Selection:

% Create Variables:
gateC = 1;
numC = 1;

% Question:
while gateC == 1
    qCollection(numC) = input(['[?] What would you like to do?','\n    1 = Generate Geometry ']);
    
    switch qCollection(numC)
        case -1
            disp('[~] Quitting Script')
            return
        otherwise
    end
    
    gateC = input(['[?] Anything Else?','\n    (1 = y, 0 = n): ']);
    
    if gateC == 1
        numC = numC + 1;
    end
    
end

% Preallocate Varaibles: 

numC = 1;
maxpreP = 4;
preP = zeros(numC,maxpreP); % Second digit must be maximum size of program line

% Create Pre-Run Process Index:

for C = qCollection
    
    switch C
        
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

            if exist('P','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
            
    end
    
    numC = numC + 1;
    
end

%% Prerun:

disp('[&] Initializing Collection')

% Max Program Size:
maxP = 5;

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
                MN = input('[?] [104] Choose a Model ID Number #: ');
                MNstr = num2str(MN);
                disp(['[#] [104] Script Will Pull From and Save To Model: ',MN])
            case 1
                % Program #1 - Generate Geometry
                Pline = [1 401 402 403 203];
                
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

disp('[=] Collection Initialized')


%% Run:

for I = 1:size(P,1)
    for p = P(I,:)
        switch p
            case 0
                % Ignore
            case 1
                % Collection #1 - Generate Geometry
                disp('[&] Starting Collection #1')
            case 203
                % Save Thermal Model to Mat File
                save(['ThermalModel',MNstr,'.mat'],'ThermalModel','numM')
                disp(['[+] [203] [Model ',numMstr,'] ','Saving to Model Number ',MNstr])
            case 204
                % Load Thermal Model from Mat File:
                load(['ThermalModel',MNstr,'.mat'])
                disp(['[+] [204] [Model ',numMstr,'] ','Loading from Model Number ',MNstr])
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
                % User Verify Single Geometry
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
                        disp(['[!] [403] [Model ',numMstr,'] ','You '])
                    else
                        disp(['[+] [403] [Model ',numMstr,'] ','Geometry Verified'])
                    end
    
                end
                
        end
    end
    % Finish Collection:
    disp(['[=] Collection #',num2str(P(I,1)),' Finished'])
end
        
        
        
        
        
        