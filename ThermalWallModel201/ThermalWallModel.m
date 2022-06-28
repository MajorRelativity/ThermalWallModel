%% ThermalWallModel v2.01
% Updated on June 27 2022
% Created by Jackson Kustell

clear

%% Documentation:

% Process ID:
% 000) Collection
%   
%   001 - 050 = 3D Model:
%       Standard:
%           001) Generate Single Geometry
%           002) Solve Single Model From Geometry
%           003) Create Contour Plot Slices
%           004) Get Temperature at Point
%       Generate Geometry:
%           
%
%   051 - 099 = 2D Model:
%       Standard:
%           051) Generate Single Geometry
%           052) Solve Single Model From Geometry
%           053) Create Contour Plot Slices
%           054) Get Temperature at Point
%       Generate Geometry: 
%           055) Generate Single Geometry with Stud
% 
%
% 100) PreRun
%
%   101) Foam Name Translation
%   102) 3D Foam Analysis - Matrix Creation
%   103) 3D Foam Matrix if no Foam Analysis
%   104) Specify Thermal Model File Identification Number
%   105) Create Log Directory
%   106) 3D Automatically Create LogSavename
%   107) 3D Model Style
%   108) 2D Model Style
%   109) 2D Automatically Create LogSavename
%   110) 2D Foam Analysis - Matrix Creation
%
%   111) 2D Foam Matrix if no Foam Analysis
%   112) Thermal Property Translation
%   113) Thermal Property if Studs
%   114) Thermal Property if No Studs
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
%   402) 3D Generate Single Geometry
%   403) 3D User Verify Single Geometry and Apply Initial Conditions
%   404) Generate Single Mesh
%   405) Solve Single Model
%   406) 2D Generate Single Geometry
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
%   601) 3D Create Y Slice Foam Analysis Thermal Plot (Vertical Y)
%   602) 3D Create Z Slice Foam Analysis Thermal Plot (Horzontal Z)
%   603) 3D Create X Slice Foam Analysis Thermal Plot (Vertical X)
%   604) 3D Get Temperature at Point
%   605) 2D Contour Plot
%   606) 2D Get Temperature at Point

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
ThermalConductivityWall = .03; % Thermal Conductivity for the Wall W/(m*K)
ThermalConductivityStuds = .08; % If Applicable
StudLocation = 0; % Location of the center of the stud on the diagram
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

%% Reset Overrides:

% 100:
run104 = 1;

% 200:
run206 = 1;

% 300
run301 = 1;

%% Collection Selection:

% Collections:
ColstrT1 = '\n    Standard:';
ColstrT2 = '\n    Generate Geometry:';

ColstrInput = '\n    Input: ';
Colstr3DT = '\n  1 - 50: 3D Model';

Colstr1 = '\n      1 = Generate Single Geometry ';
Colstr2 = '\n      2 = Run Single Model From Geometry ';
Colstr3 = '\n      3 = Create Contour Plot Slices';
Colstr4 = '\n      4 = Get Temperature at Point';

Colstr2DT = '\n  51 - 100: 2D Model';

Colstr51 = '\n      51 = Generate Single Geometry ';
Colstr52 = '\n      52 = Run Single Model From Geometry ';
Colstr53 = '\n      53 = Create Contour Plot Slices';
Colstr54 = '\n      54 = Get Temperature at Point';

Colstr55 = '\n      55 = Generate Single Geometry with Stud';


Colstr3D = [Colstr3DT,ColstrT1,Colstr1,Colstr2,Colstr3,Colstr4];
Colstr2D = [Colstr2DT,ColstrT1,Colstr51,Colstr52,Colstr53,Colstr54,...
    ColstrT2,Colstr55];
Colstr = [Colstr3D,Colstr2D,ColstrInput];


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

            % Clear Collection Names:
            clear -regexp Colstr
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

maxpreP = 5;
preP = zeros(numC,maxpreP); % Second digit must be maximum size of program line
numC = 1;

% Create Pre-Run Process Index:

for C = qCollection
    
    switch C
        case 0
            % Ignore
            numC = numC - 1;
            break
        case 1            
            % Program #1 - Generate Geometry
            prePline = [101 103 104 107 114 1]; %prePrograms always end with their program ID #

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
            prePline = [104 105 106 107 2]; %prePrograms always end with their program ID #

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
       case 3          
            % Program #3 - Contour Slices
            prePline = [107 3]; %prePrograms always end with their program ID #

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
        case 4
            % Program #4 - Get Temperature at Point
            prePline = [107 4]; %prePrograms always end with their program ID #

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
       case 51            
            % Program #51 - 2D Generate Geometry
            prePline = [101 111 104 108 114 51]; %prePrograms always end with their program ID #

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
       case 52          
            % Program #52 - 2D Run Model From Geometry
            prePline = [104 105 109 108 52]; %prePrograms always end with their program ID #

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
       case 53          
            % Program #53 - 2D Contour Plot
            prePline = [108 53]; %prePrograms always end with their program ID #

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
        case 54
            % Program #54 - 2D Get Temperature at Point
            prePline = [108 54]; %prePrograms always end with their program ID #

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
        case 55
            % Program #55 - 2D Generate Single Geometry with Stud
            prePline = [101 111 104 108 113 55]; %prePrograms always end with their program ID #

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
                % 3D Foam Analysis - Matrix Creation

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
                % 3D Foam Matrix if no Foam Analysis

                Foam = [Tf,Lf,Hf];

                disp('[+] [103] Foam Vector Created')
                
            case 104
                if run104 == 1
                    MN = input('[?] [104] Choose a Thermal Model File ID Number #: ');
                    MNstr = num2str(MN);
                    run104 = 0;
                    disp(['[#] [104] Script Will Pull From and Save To Model: ',MN])
                end
            case 105
                % Create Log Directory
                if ~exist('ThermalData','dir')
                    mkdir ThermalData
                    disp('[+] [105] ThermaData Directory Created')
                end
            case 106
                % 3D Automatically Create LogSavename
                LogSavename = ['ThermalData/3DLogData ',datestr(now,'yyyy-mm-dd HH:MM:ss'),'.mat'];
                disp(['[+] [106] Logs will be saved to',LogSavename])
            case 107
                % 3D Model Style
                modelStyle = '3D';
                disp(['[+] [107] Model Style set to: ',modelStyle])
            case 108
                % 2D Model Style
                modelStyle = '2D';
                disp(['[+] [108] Model Style set to: ',modelStyle])
            case 109
                % 2D Automatically Create LogSavename
                LogSavename = ['ThermalData/2DLogData ',datestr(now,'yyyy-mm-dd HH:MM:ss'),'.mat'];
                disp(['[+] [109] Logs will be saved to',LogSavename]) 
            case 110
                % 2D Foam Analysis - Matrix Creation

                Tfm = Tf:-FstepT:0;
                Lfm = Lf:-FstepL:0;
                [Tfm, Lfm] = meshgrid(Tfm,Lfm);

                Logic = Tfm > 0 & Lfm > 0;
                Tfm = Tfm(Logic);
                Lfm = Lfm(Logic);

                Foam = [Tfm, Lfm]; % Full foam matrix

                Tf = Foam(:,1); % All thicknesses
                Lf = Foam(:,2); % All lengths

                disp('[+] [110] Foam Matrix Created')
            case 111
                % 3D Foam Matrix if no Foam Analysis

                Foam = [Tf,Lf];

                disp('[+] [111] Foam Vector Created')
            case 112
                % Thermal Property Translation
                TCw = ThermalConductivityWall;
                TCs = ThermalConductivityStuds;
                SL = StudLocation;
                disp('[+] [112] Thermal Property Names Translated')
            case 113
                % Thermal Properties if Studs
                SLu = SL + .05; % Stud Upper Bound
                SLl = SL - .05; % Stud Lower Bound
                ThermalConductivity = @(location,state) (location.y>=SLu || location.y<SLl).*TCw + (SLl<=location.y && location.y<SLu).*TCs;
                disp('[+] [113] Stud Location Defined')
            case 114
                % Thermal Property if No Stud
                TC = TCw;
                disp('[+] [114] Thermal Properties Defined')

            case 1
                % Collection #1 - Generate Geometry
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
                % Collection #2 - Run Model From Geometry
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
            case 3
                % Collection #3 - Plot Contour Slices
                Pline = [3 206 301 601 602 603]; % All collections must start with their collection #
                
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
            case 4 
                % Collection #4 - Get Temperature at Point
                Pline = [4 206 301 604]; % All collections must start with their collection #
                
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
            case 51
                % Collection #51 - 2D Generate Geometry
                Pline = [51 401 406 407 203]; % All collections must start with their collection #
                
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

            case 52
                % Collection #52 - Run Model From Geometry
                Pline = [52 204 301 501 404 405 502 503 504 505 506 203 205]; % All collections must start with their collection #
                
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
            case 53
                % Collection #53 - 2D Contour Plot
                Pline = [53 206 301 605]; % All collections must start with their collection #
                
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
            case 54 
                % Collection #54 - 2D Get Temperature at Point
                Pline = [54 206 301 606]; % All collections must start with their collection #
                
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
            case 55 
                % Collection #55 - 2D Generate Single Geomtry with Stud
                Pline = [55 401 402 403 203]; % All collections must start with their collection #
                
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
                break
            case 1
                % Collection #1 - Generate Single Geometry
                disp('[&] Starting Collection #1 - Generate Geometry')

                % Overrides:
                run301 = 0;
            case 2
                % Collection #2 - Solve Single Thermal Model
                disp('[&] Starting Collection #2 - Solve Thermal Model')

                % Overrides
                run206 = 0;
                run301 = 0;
            case 3
                % Collection #3 - Creating Slices
                disp('[&] Starting Collection #3 - Creating Contour Slices')
            case 4
                % Collection #3 - Creating Slices
                disp('[&] Starting Collection #4 - Plotting Temperature at Point')
            case 51
                % Collection #1 - Generate Single Geometry
                disp('[&] Starting Collection #51 - Generate Geometry')

                % Overrides:
                run301 = 0;
            case 52
                % Collection #2 - Solve Single Thermal Model
                disp('[&] Starting Collection #52 - Solve Thermal Model')

                % Overrides
                run206 = 0;
                run301 = 0;
            case 53
                % Collection #3 - Creating Slices
                disp('[&] Starting Collection #53 - Create Contour Plot')
            case 54
                % Collection #3 - Creating Slices
                disp('[&] Starting Collection #54 - Plotting Temperature at Point')
            case 203
                % Make Directory:
                if ~exist('ThermalModels','dir')
                    mkdir ThermalModels
                    disp('[+] [203] ThermaModels Directory Created')
                end

                % Keep Savedate of ModelSpecifications file
                savedateMS = savedate;

                % Save Thermal Model to Mat File
                save(['ThermalModels/ThermalModel',MNstr,'.mat'],'ThermalModel','numM','numMstr','MN','MNstr','MS','MSN','savedateMS',"Tf","Lf","Hf","Tw","Lw","Hw")
                clear savedateMS
                disp(['[+] [203] [Model ',numMstr,'] ','Saving to Model Number ',MNstr])

            case 204
                % Load Thermal Model from Mat File:
                load(['ThermalModels/ThermalModel',MNstr,'.mat'])
                disp(['[+] [204] [Model ',numMstr,'] ','Loading from Model Number ',MNstr])

                % Force and Check Model Specification:
                if ~exist(MS,'file')
                    disp(['[!] [204] [Model ',numMstr,'] ','It appears that the Model Specifications associated with this model have been deleted or are not present in the correct folder.'])
                    qContinue = input(['[?] [204] [Model ',numMstr,'] ','This could seriously mess with your results, are you sure you want to continue? (1 = y, 0 = n): ']);
                    
                    if qContinue == 0
                        disp(['[-] [204] [Model ',numMstr,'] ','Quitting Script'])
                        return
                    end

                    disp(['[*] [204] [Model ',numMstr,'] ','Bold Move. Continuing...'])
                    pause(3) % Pause so this can be read
                else
                    load(MS)
                end

                if savedateMS ~= savedate
                    disp(['[!] [204] [Model ',numMstr,'] ','It appears that the ModelSpecifications file associated with this model has been overwritten.'])
                    qContinue = input(['[?] [204] [Model ',numMstr,'] ','This could seriously mess with your results, are you sure you want to continue? (1 = y, 0 = n): ']);
                    
                    if qContinue == 0
                        disp(['[-] [204] [Model ',numMstr,'] ','Quitting Script'])
                        return
                    end

                    disp(['[*] [204] [Model ',numMstr,'] ','Bold Move. Continuing...'])
                    pause(3) % Pause so this can be read
                end
                disp(['[+] [204] [Model ',numMstr,'] ','Forced Model Specifications from ',MS])
            case 205
                % Save Foam Analysis Logs
                save(LogSavename,"FAResults","FAResultsD","Specifications","ThermalModel","ThermalResults","numM")
                disp(['[+] [205] Logs have been saved with thermalresults as ',LogSavename])

            case 206
                if run206 == 1
                    % Load Foam Analysis Logs
                    disp('[?] Choose the Log file you would like to load: ')
                    [filenameFAL, pathnameFAL] = uigetfile('*.*','[?] Choose the Log file you would like to load: ');
                    addpath(pathnameFAL)
                    load(filenameFAL)
                    disp(['[+] File ',filenameFAL,' has been loaded!'])
                end
            case 301
                % Select Thermal Model Number:
                if run301 == 1
                    numMstr = num2str(numM);
                    qnumM = input(['[?] [301] [Model ',numMstr,'] ','Current Model Number: ',numMstr,'\n    Choose a New One? (-1 = no or Input #): ']);
                    if qnumM <= 0
                        disp(['[-] [301] [Model ',numMstr,'] ','Model Number Not Modified'])
                    else
                        numM = qnumM;
                        numMstr = num2str(numM);
                        disp(['[+] [301] [Model ',numMstr,'] ','New Model Number Chosen: ',numMstr])
                    end
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
                % 3D Generate Single Geometry
                disp(['[$] [402] [Model ',numMstr,'] ','Generating Geometry'])
                ThermalModel{numM}.Geometry = modelshapew3D(thermalmodel,qRM,Lw,Hw,Tw,Lf,Hf,Tf);
                disp(['[+] [402] [Model ',numMstr,'] ','Geometry Generated'])
                
            case 403
                % 3D User Verify Single Geometry and Apply Initial Conditions
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
                        TC = ThermalConductivity; 
                        thermalProperties(thermalmodel,'ThermalConductivity',TC);
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

            case 406
                % 2D Generate Single Geometry:
                disp(['[$] [406] [Model ',numMstr,'] ','Generating 2D Geometry'])
                wallGeometry2D(Lw,Tw,Lf,Tf); %Ensures new geometry is loaded
                geometryFromEdges(ThermalModel{numM},@modelshapew); % Uses Geometry
                disp(['[+] [406] [Model ',numMstr,'] ','2D Geometry Generated'])
            case 407 
                disp(['[$] [407] [Model ',numMstr,'] ','Applying Conditions'])
                % 2D Apply Thermal Properties:
                
                thermalmodel = ThermalModel{numM}; % Import Thermal Model from Cell

                if all(modelType=="transient")
                    TCw = ThermalConductivity; 
                    TMw = MassDensity; 
                    TSw = SpecificHeat;
                    
                    thermalProperties(thermalmodel,'ThermalConductivity',TCw,...
                                                   'MassDensity',TMw,...
                                                   'SpecificHeat',TSw);
            
                    thermalIC(thermalmodel,Tempi); % Apply Initial Condition
            
                    disp('[~] Model Type = Transient')
            
                elseif all(modelType=="steadystate")
                    TCw = ThermalConductivity; 
                    thermalProperties(thermalmodel,'ThermalConductivity',TCw);
                    disp('[~] Model Type = Steady State')
                end

                % Apply Boundary Conditions
                thermalBC(thermalmodel,'Edge',1,'Temperature',TempwI);
                thermalBC(thermalmodel,'Edge',[3,5,7],'Temperature',TempwO);   

                ThermalModel{numM} = thermalmodel; % Re Apply to Cell
                disp(['[+] [407] [Model ',numMstr,'] ','Conditions Applied'])
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
                if all(modelStyle == '3D')
                    IntersectTemp = interpolateTemperature(ThermalResults{numM},Tw,0,0);
                elseif all(modelStyle == '2D')
                    IntersectTemp = interpolateTemperature(ThermalResults{numM},Tw,0);
                end
                
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

                if all(modelStyle=='2D')
                    Hf = -1;
                end

                FAResultsD(numM,:) = [numM,duration,Tf,Lf,Hf,pErrorT,RwM,IntersectTemp];
                Specifications = [modelType,Hmax,HdeltaP,Rw,Rf,Tw,Lw,Hw,TempwI,TempwO,Tempi,ThermalConductivity,modelStyle]';
            case 506
                % Create Foam Analysis Result Tables

                Specifications = array2table(Specifications,...
                    'RowNames',{'Model','Hmax','HdeltaP (0 to 1)','R-wall','R-foam','Wall Thickness','Wall Length','Wall Height','Indoor BC','Outdoor BC','Interior Temp','Thermal Conductivity','Model Style'});
                FAResults = array2table(FAResultsD,...
                    'VariableNames',{'Process','Duration (s)','Foam Thickness','Foam Length','Foam Height','% Error','Predicted Rwall','Temp at Intersection (K)' });
                disp(['[+] [506] [Model ',numMstr,'] ','Foam Analysis Results Tables Created'])

            case 601
               % 3D Y Slice Analysis (Vertical Y)
               gateP = 1;
               while gateP == 1
                   qTRpa = input('[?] [601] What model # would you like to Yslice? (-1 = all, or row index # from FAResults): ');
                   
                   % Pull Model Specifications:
                   Tw = str2double(Specifications{6,1});
                   Hw = str2double(Specifications{8,1});
                   Lw = str2double(Specifications{7,1});
                   
                   % Choose Slices:
                   Yslice = input('[?] [601] Please Select the Y position you wish to plot: ');

                   if qTRpa == -1
                       gateP = 0;
                        for i = 1:size(ThermalResults,2)
                            
                            % Create Figure:
                            disp(['[*] [601] Plotting Model #',num2str(i)])
                            fname = ['Yslice Results From Process #',num2str(i)];
                            figure('Name',fname)
                            
                            % Pull Necessary Data for This Model:
                            Tf = FAResultsD(i,3);
                
                            thermalresults = ThermalResults{i};
                            
                            % Create Mesh and Plot:
                
                            [X,Z] = meshgrid(linspace(0,(Tw+Tf)),linspace(-Hw/2,Hw/2));
                            Y = Yslice.*ones(size(X,1),size(X,2));
                            V = interpolateTemperature(thermalresults,X,Y,Z);
                            V = reshape(V,size(X));
                            surf(X,Z,V,'LineStyle','none');
                            view(0,90)
                            title(['Colored Plot through Y (Length) = ',num2str(Yslice)])
                            xlabel('X (Thickness)')
                            ylabel('Z (Height)')
                            colorbar
                        end
                   else
                       i = qTRpa;
                       % Create Figure:
                        disp(['[*] [601] Plotting Model #',num2str(i)])
                        fname = ['Yslice Results From Model #',num2str(i)];
                        figure('Name',fname)
                        
                        % Pull Necessary Data for This Model:
                        Tf = FAResultsD(i,3);
            
                        thermalresults = ThermalResults{i};
                        
                        % Create Mesh and Plot:
            
                        [X,Z] = meshgrid(linspace(0,(Tw+Tf)),linspace(-Hw/2,Hw/2));
                        Y = Yslice.*ones(size(X,1),size(X,2));
                        V = interpolateTemperature(thermalresults,X,Y,Z);
                        V = reshape(V,size(X));
                        surf(X,Z,V,'LineStyle','none');
                        view(0,90)
                        title(['Colored Plot through Y (Length) = ',num2str(Yslice)])
                        xlabel('X (Thickness)')
                        ylabel('Z (Height)')
                        colorbar
                        gateP = input('[?] [601] Would you like to plot more rows? (1 = yes, 0 = no): ');
                   end
               end
            case 602
               % 3D Z Slice Analysis (Horzontal Z)
               gateP = 1;
               while gateP == 1
                   qTRpa = input('[?] [602] What model # do you want to Zslice? (-1 = all, or row index # from FAResults): ');
                   
                   % Pull Model Specifications:
                   Tw = str2double(Specifications{6,1});
                   Hw = str2double(Specifications{8,1});
                   Lw = str2double(Specifications{7,1});
                   
                   % Choose Slice:
                   Zslice = input('[?] [602] Please Select the Z position you wish to plot: ');
                   if qTRpa == -1
                       gateP = 0;
                        for i = 1:size(ThermalResults,2)
                            
                            % Create Figure:
                            disp(['[*] [602] Plotting Model #',num2str(i)])
                            fname = ['Zslice Results From Process #',num2str(i)];
                            figure('Name',fname)
                            
                            % Pull Necessary Data for This Model:
                            Tf = FAResultsD(i,3);
                
                            thermalresults = ThermalResults{i};
                            
                            % Create Mesh and Plot:
                
                            [X,Y] = meshgrid(linspace(0,(Tw+Tf)),linspace(-Lw/2,Lw/2));
                            Z = Zslice.*ones(size(X,1),size(X,2));
                            V = interpolateTemperature(thermalresults,X,Y,Z);
                            V = reshape(V,size(X));
                            surf(X,Y,V,'LineStyle','none');
                            view(0,90)
                            title(['Colored Plot through Z (Height) = ',num2str(Zslice)])
                            xlabel('X (Thickness)')
                            ylabel('Y (Length)')
                            colorbar
                        end
                   else
                       i = qTRpa;
                       % Create Figure:
                        disp(['[*] [602] Plotting Model #',num2str(i)])
                        fname = ['Zslice Results From Model #',num2str(i)];
                        figure('Name',fname)
                        
                        % Pull Necessary Data for This Model:
                        Tf = FAResultsD(i,3);
            
                        thermalresults = ThermalResults{i};
                        
                        % Create Mesh and Plot:
            
                        [X,Y] = meshgrid(linspace(0,(Tw+Tf)),linspace(-Lw/2,Lw/2));
                        Z = Zslice.*ones(size(X,1),size(X,2));
                        V = interpolateTemperature(thermalresults,X,Y,Z);
                        V = reshape(V,size(X));
                        surf(X,Y,V,'LineStyle','none');
                        view(0,90)
                        title(['Colored Plot through Z (Height) = ',num2str(Zslice)])
                        xlabel('X (Thickness)')
                        ylabel('Y (Length)')
                        colorbar
                        gateP = input('[?] [602] Would you like to plot more rows? (1 = yes, 0 = no): ');
                   end
               end
            case 603
               % 3D X Slice Analysis (Vertical X)
               gateP = 1;
               while gateP == 1
                   qTRpa = input('[?] [603] What model # do you want to Xslice? (-1 = all, or row index # from FAResults): ');
                   
                   % Pull Model Specifications:
                   Tw = str2double(Specifications{6,1});
                   Hw = str2double(Specifications{8,1});
                   Lw = str2double(Specifications{7,1});
                   
                   % Choose Slice:
                   Xslice = Tw; % The only useful x slice is at the wall/foam intersection

                   if qTRpa == -1
                       gateP = 0;
                        for i = 1:size(ThermalResults,2)
                            
                            % Create Figure:
                            disp(['[*] [603] Plotting Model #',num2str(i)])
                            fname = ['Xslice Results From Process #',num2str(i)];
                            figure('Name',fname)
                            
                            % Pull Necessary Data for This Model:
                            Tf = FAResultsD(i,3);
                
                            thermalresults = ThermalResults{i};
                            
                            % Create Mesh and Plot:
                
                            [Z,Y] = meshgrid(linspace(Hw/2,-Hw/2),linspace(-Lw/2,Lw/2));
                            X = Xslice.*ones(size(Z,1),size(Z,2));
                            V = interpolateTemperature(thermalresults,X,Y,Z);
                            V = reshape(V,size(Z));
                            surf(Z,Y,V,'LineStyle','none');
                            view(0,90)
                            title(['Colored Plot through X (Thickness) = ',num2str(Xslice)])
                            xlabel('Z (Height)')
                            ylabel('Y (Length)')
                            colorbar
                        end
                   else
                       i = qTRpa;
                       % Create Figure:
                        disp(['[*] [603] Plotting Model #',num2str(i)])
                        fname = ['Xslice Results From Model #',num2str(i)];
                        figure('Name',fname)
                        
                        % Pull Necessary Data for This Model:
                        Tf = FAResultsD(i,3);
            
                        thermalresults = ThermalResults{i};
                        
                        % Create Mesh and Plot:
            
                        [Z,Y] = meshgrid(linspace(Hw/2,-Hw/2),linspace(-Lw/2,Lw/2));
                        X = Xslice.*ones(size(Z,1),size(Z,2));
                        V = interpolateTemperature(thermalresults,X,Y,Z);
                        V = reshape(V,size(Z));
                        surf(Z,Y,V,'LineStyle','none');
                        view(0,90)
                        title(['Colored Plot through X (Thickness) = ',num2str(Xslice)])
                        xlabel('Z (Height)')
                        ylabel('Y (Length)')
                        colorbar
                        gateP = input('[?] [603] Would you like to plot more rows? (1 = yes, 0 = no): ');
                   end
               end
            case 604
                % 3D Get Temperature at a Point
                
                % Load Important Information:
                Tw = str2double(Specifications{6,1});
                Hw = str2double(Specifications{8,1});
                Lw = str2double(Specifications{7,1});

                Tf = FAResultsD(numM,3);
                Lf = FAResultsD(numM,4);
                Hf = FAResultsD(numM,5);

                gateTAP = 1;
                while gateTAP == 1
                    % Count Number of Points
                    if ~exist('numTAP','var')
                        numTAP = 1;
                    else
                        numTAP = numTAP + 1;
                    end
                    
                    % Get Point
                    disp(['[?] [604] [Model ',numMstr,'] ','What point would you like to use?'])
                    disp('[#] Origin is in center of indoor wall')
                    x = input('    Thickness = ');
                    y = input('    Length = ');
                    z = input('    Height = ');
                    
                    % Creat Array and Table
                    TempAtPointP = interpolateTemperature(ThermalResults{numM},x,y,z);
                    TempAtPointD(numTAP,:) = [numTAP,numM,x,y,z,TempAtPointP];
                    TempAtPoint = array2table(TempAtPointD,...
                        'VariableNames',{'Point','Model #','X','Y','Z','Temperature'});
                    disp(TempAtPoint)
                    
                    % Clear Old Values:
                    clear x
                    clear y
                    clear z
                    clear TempAtPointP
    
                    % Another?
                    gateTAP = input(['[?] [604] [Model ',numMstr,'] ','Would you like to plot another point? (1 = y, 0 = n): ']);
                end
            case 605
                % 2D Contour Plot:
                
                disp(['[$] [605] Plotting Model #',num2str(numM)])
                fname = ['Results from 2D Model #',num2str(numM)];
                figure('Name',fname)

                pdeplot(ThermalModel{numM},'XYData',ThermalResults{numM}.Temperature(:), ...
                                 'Contour','on', ...
                                 'ColorMap','hot')
                title(fname)
                xlabel('Thickness (m)')
                ylabel('Length (m)')
            case 606
                % 2D Temperature at Point
                
                % Load Important Information:
                Tw = str2double(Specifications{6,1});
                Lw = str2double(Specifications{7,1});

                Tf = FAResultsD(numM,3);
                Lf = FAResultsD(numM,4);

                gateTAP = 1;
                while gateTAP == 1
                    % Count Number of Points
                    if ~exist('numTAP','var')
                        numTAP = 1;
                    else
                        numTAP = numTAP + 1;
                    end
                    
                    % Get Point
                    disp(['[?] [606] [Model ',numMstr,'] ','What point would you like to use?'])
                    disp('[#] Origin is in center of indoor wall')
                    x = input('    Thickness = ');
                    y = input('    Length = ');
                    
                    % Creat Array and Table
                    TempAtPointP = interpolateTemperature(ThermalResults{numM},x,y);
                    TempAtPointD(numTAP,:) = [numTAP,numM,x,y,TempAtPointP];
                    TempAtPoint = array2table(TempAtPointD,...
                        'VariableNames',{'Point','Model #','X','Y','Temperature'});
                    disp(TempAtPoint)
                    
                    % Clear Old Values:
                    clear x
                    clear y
                    clear TempAtPointP
    
                    % Another?
                    gateTAP = input(['[?] [606] [Model ',numMstr,'] ','Would you like to plot another point? (1 = y, 0 = n): ']);
                end
        end
    end
    % Finish Collection:
    disp(['[=] Collection #',num2str(P(I,1)),' Finished'])
end      


