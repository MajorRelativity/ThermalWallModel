%% ThermalWallModel v2.76
% Updated on July 25 2022

clear
addpath("Functions")

%% Documentation:

%{

Suppressed Messages:
- %#ok<*AGROW> suppresses all messages concerning a variable increasing in
size on a loop
- %#ok<*PFTUSW> suppresses all messages concerning a variable in a parfor
loop that is used after

Required Toolboxes:

- Parallel Computing Toolbox
- Partial Differential Equation Toolbox
- Predictive Maintenance Toolbox

Process ID:
-00) Debug:

    -01) Quit
    -02) Get Collection Programs
    -03) Unit Conversion Tool

000) Collection

    001 - 050 = 3D Model:
        Standard:
            001) Generate Single Geometry
            002) Solve Single Model From Geometry
            003) Create Contour Plot Slices
            004) Get Temperature at Point
        Generate Geometry:
            005) Generate Single Geometry with Stud
        Solve Models:
            006) Solve Single Model with Overrides
          

    051 - 099 = 2D Model:
        Standard:
            051) Generate Single Geometry
            052) Solve Single Model From Geometry
            053) Create Contour Plot Slices
            054) Get Temperature at Point
        Generate Geometry: 
            055) Generate Single Geometry with Stud
            057) Generate All Stud Analysis Geometries
            059) Generate All Foam Analysis Geometries
            062) Generate All Plate Analysis Geometries
        Solve Models:
            058) Solve All Stud Analysis Models
            061) Solve All Foam Analysis Models
            063) Solve All Plate Analysis Models
        Analysis:
            056) Plot Current Thermal Properties
            060) Plot Single Geometry
            064) Plot Temperatures Across Intersection
            065) Get Average Temperature Acroos Plate Region
            066) Get Heat Flux at a Point
            067) Plot Single Mesh
            068) Plot Heat Flux Across Wall


100) PreRun

    101) Name Translation
    104) Specify Thermal Model File Identification Number
    107) 3D Model Style
    108) 2D Model Style
    115) Create Stud Analysis Matrix
    119) Reset numA if needed

    Plate Analysis:
        120) 2D Create Plate Analysis Matrix

    Thermal Properties:
        112) Thermal Property Translation
        113) Thermal Property if Specific Thermal Properties
        114) Thermal Property if Simple Thermal Properties

    Foam Matrix  Creation:
        102) 3D Foam Analysis - Matrix Creation
        103) 3D Foam Matrix if no Foam Analysis
        110) 2D Foam Analysis - Matrix Creation
        111) 2D Foam Matrix if no Foam Analysis

    Save Files:
        105) Create Log Directory
        106) Automatically Create ResultsSavename
        109) Automatically Create LogSavename
        116) Create 2D Data Save File
        117) Create 3D Data Save File
        118) Automatically Create ModelSavename

    Other:
        121) Determine Conversion

200) Load / Save / Store

    201) Make Directory and Save ModelSpecification.mat
    202) Load ModelSpecification.mat
    203) Make Directory and Save ThermalModel.mat
    204) Load ThermalModel.mat
    205) Save Analysis Log Data
    206) Load Analysis Log Data
    207) Save Meshed Thermal Model Log Data
    208) Load Meshed Thermal Model Log Data
    209) Save Thermal Results Log Data
    210) Load Thermal Results Log Data/

    211) Make Log Data Directory
    212) Store Necessary Variables for ThermalModel
    213) Unpack Necessary Variables for ThermalModel

300) Modification

    301) Select Model Number
    302) Stud Analysis Modification
    303) Create '__p' variables for Parallel Pool Usage
    304) Foam Analysis Modification
    305) Create '__p' variables for Foam Analysis in the Parallel Pool
    306) Plate Analysis Modification
    307) Add One to Model Number
    308) Set Model Number to Logs.numMi

400) Operation

    401) Create Single New Thermal Model
    402) 3D Generate Single Geometry
    403) 3D User Verify Single Geometry and Apply Initial Conditions
    404) Generate Single Mesh
    405) Solve Single Model
    406) 2D Generate Single Geometry
    407) 2D Apply Thermal Properties
    408) Generate All Meshes
    409) Solve All Models
    410) Generate Mesh with Overrides

    411) Convert R Imperial to SI
    412) Convert TC SI to Imperial

500) Post Processing

    501) Start Timer
    502) End Timer
    503) Find Predicted R Value and Percent Error
    504) Duration with time2num
    505) Log Initial numMi Before Process
    506) Add to Foam Analysis Log
    507) Find Predicted R Value and Percent Error for Stud Analysis
    508) Add to Stud Analysis Result Logs
    509) Creat Specifications Table
    510) Create AResults Table
    
    511) Add to Plate Analysis Log

600) Analysis

    601) 3D Create Y Slice Foam Analysis Thermal Plot (Vertical Y)
    602) 3D Create Z Slice Foam Analysis Thermal Plot (Horzontal Z)
    603) 3D Create X Slice Foam Analysis Thermal Plot (Vertical X)
    604) 3D Get Temperature at Point
    605) 2D Contour Plot
    606) 2D Get Temperature at Point
    607) 2D Plot Current Thermal Properties
    608) 2D Create Plot of Current Geometry
    609) 2D Plot Temperature Across Intersection
    610) 2D Take Average Across Plate Region

    611) 2D Get Heat Flux at a Point
    612) Plot Current Mesh

700) Conditions

    701) Evaluate Condition
    702) Repeat Stud Analysis
    703) Repeat Foam Analysis
    704) Repeat Plate Analysis
    705) Repeat Collection 53
    706) Repeat Collection 66

%}

%% General Model Specifications (User Edited):
% These will NOT be overwritten by the preset

% Specification Mode:
MSD.msMode = 201; % 201 = save, 202 = load

% Overrides:
MSD.Overrides.run504 = 1; % Change to 0 if time2num is not installed on your machine
MSD.Overrides.OldVersion = 0; % Choose if you are running an old version of matlab

% Model Type ("transient", "steadystate")
MSD.modelType = 'steadystate';
MSD.q.RM = 0; % Use reduced size mode? (1 = yes, 0 = no). Uses only the upper left quadrant

% Indoor Boundary Conditions: (BC stays constant in time):
MSD.BC.TempwI = 309; %Interior Wall Temperature K

% Outdoor Boundary Conditions :
MSD.BC.TempwO = 295; %Outdoor Wall Temperature K

% Mesh Settings
MSD.Mesh.Hmax = 6*10^-3; % Max Mesh Length
MSD.Mesh.Hdelta = .10; % Percent of Hmax Hmin is
MSD.Mesh.Hmin = MSD.Mesh.Hmax*MSD.Mesh.Hdelta;

MSD.q.NCM3D = 1; % Ask for inconsistant mesh specifications when generating 3D geometry
% in order to accomidate hardware limitations on smaller mesh sizes
MSD.Mesh.HOverride = 15*10^-3; % Override Mesh Length (for inconsistant mesh
% specificaton

% Foam Modification Settings:
MSD.FMod.FstepT = 1; % Step size between foam trials for thickness
MSD.FMod.FstepH = .1;% Step size between foam trials for thickness
MSD.FMod.FstepL = .1; % Step size between foam trials for length
MSD.q.SF = 1; %Only analyze square foam sizes?

%% Specific Model Specifications (User Edited):

% Property Style:
%{ 
- 'GenericStud' = Traditional stud style
- 'TimeMachine' = Recreates the bottem seciton of time machine. Stud 
    through middle with difference for plywood section
- 'TimeMachineNoPlate = Just like time machine except there is no plate
    between the foam and the wall.
- 'Complex' = Plate with stud, wallboard, and siding. This is meant to
    represent a real house
- 'ComplexNoFoam' = Same as complex, but the wall siding continues to
    infinity.

%}
MSD.propertyStyle = 'TimeMachine'; 

% Shape of Wall:
MSD.Foam.Thickness = 2.54 * 10^-2; %m
MSD.Foam.Length = 45.6 * 10^-2; %m
MSD.Foam.Height = MSD.Foam.Length; 

MSD.Wall.Thickness = 5.08 * 10^-2; %m Generic Setting
MSD.Wall.Length = 90 * 10^-2; %m 
MSD.Wall.Height = MSD.Wall.Length;

% Wall Thermal Properties:
MSD.Wall.TC = .0288; % Thermal Conductivity for the Wall W/(m*K)
MSD.Foam.TC = MSD.Wall.TC;

% Plate:
MSD.Plate.Length = .302; %Plate Length
MSD.Plate.Thickness = 0.0015875; % Plate Thickness
MSD.Plate.TC = 150; %Plate Thermal Conductivity
MSD.Plate.On = false;

% Stud:
MSD.Stud.TC = .115; % If Applicable
MSD.Stud.Pos = 0; % Location of the center of the stud on the diagram
MSD.Stud.Length = 0.0381; % Length of the stud along the y direction in meters

% Wall and Foam R Values. Foam Adjustment Settings:
MSD.Wall.eR = NaN;
MSD.Wall.R = 10  + .63; 
MSD.Foam.R = 5;

%% Model Specification Preset (User Edited):
% If a preset is applied, then it will overwrite all of the above settings
%{
'None' - No Preset, Above Specifications are used
'Generic' - Generic Wall with Generic Stud Positioning if Needed
'TimeMachine' - Time Machine Wall with Plate
'GenericExtended' - Generic Wall with Generic Stud Positioning. In 3D,
 the Foam is extended to meet the height of the wall
'Complex' - Plate with stud, wallboard, and siding. This is meant to
represent a real house
'ComplexNoFoam' - Same as complex but the foam is not on the wall

%}
MSD.Preset = 'Complex';

%% Save or Load Model Specifications

% Apply Presets:
MSD = msPreset(MSD);

% Creates Directors for Model Specifications
if ~exist('ModelSpecifications','dir')
    mkdir ModelSpecifications
end

% Tells user current mode:
switch MSD.msMode
    case 201
        disp('[#] ModelSpecifications are currently in mode: SAVE')
    case 202
        disp('[#] ModelSpecifications are currently in mode: LOAD')
end

% Specify current model specifications
MSD.MSN = input('[?] Choose a Model Specification #: ');
MS = ['ModelSpecifications/ModelSpecification',num2str(MSD.MSN),'.mat'];

switch MSD.msMode
    
    case 201
        MSD.savedate = datetime('now');
        save(MS,'MSD')
        disp(['[+] Model Specifications have been saved to ',MS,' at ',datestr(MSD.savedate)])
    case 202
        load(MS)
        disp(['[+] Model Specifications have been loaded from ',MS,' from ',datestr(MSD.savedate)])

end

%% Reset Overrides:

% 000
run.p54 = true;
run.p57 = true;
run.p59 = true;
run.p62 = true;
run.p66 = true;

% 100:
run.p104 = true;

% 200:
run.p206 = true;
run.p208 = true;
run.p210 = true;

% 300
run.p301 = true;
run.p307 = true;

%% Collection Selection:

% Collections:
ColstrT1 = '\n    Standard:';
ColstrT2 = '\n    Generate Geometry:';
ColstrT3 = '\n    Solve Models';
ColstrT4 = '\n    Analysis:';

ColstrInput = '\n  Input: ';

ColstrDebug3 = '\n -3 = Debug: Unit Conversion Tool ';
ColstrDebug2 = '\n -2 = Debug: Show Collection Programs ';
ColstrQuit = '\n -1 = Quit ';

ColstrRun = '\n  0 = Run with Nothing Else ';


Colstr3DT = '\n  1 - 50: 3D Model';

Colstr1 = '\n      1 = Generate Single Geometry ';
Colstr2 = '\n      2 = Run Single Model From Geometry ';
Colstr3 = '\n      3 = Create Contour Plot Slices';
Colstr4 = '\n      4 = Get Temperature at Point';

Colstr5 = '\n      5 = Plot Single Geometry with Stud';

Colstr6 = '\n      6 = Run Single Model From Geometry with Mesh Overrides';


Colstr2DT = '\n  51 - 100: 2D Model';

Colstr51 = '\n      51 = Generate Single Geometry ';
Colstr52 = '\n      52 = Run Single Model From Geometry ';
Colstr53 = '\n      53 = Create Contour Plot';
Colstr54 = '\n      54 = Get Temperature at Point';

Colstr55 = '\n      55 = Generate Single Geometry with Stud';
Colstr57 = '\n      57 = Generate All Stud Analysis Geometries';
Colstr59 = '\n      59 = Generate All Foam Analysis Geometries';
Colstr62 = '\n      62 = Generate All Plate Analysis Geometries';

Colstr58 = '\n      58 = Solve All Stud Analysis Models';
Colstr61 = '\n      61 = Solve All Foam Analysis Models';
Colstr63 = '\n      63 = Solve All Plate Analysis Models';

Colstr56 = '\n      56 = Plot Current Thermal Properties';
Colstr60 = '\n      60 = Plot Single Geometry';
Colstr64 = '\n      64 = Plot Temperatures Across Intersection';
Colstr65 = '\n      65 = Get Average Temperature Across Plate Region';
Colstr66 = '\n      66 = Get Heat Flux At Point';
Colstr67 = '\n      67 = Plot Single Mesh';
Colstr68 = '\n      68 = Plot Heat Flux Across Wall';

% General Colstr
Colstr3D1 = [ColstrT1,Colstr1,Colstr2,Colstr3,Colstr4];
Colstr3D2 = [ColstrT2,Colstr5];
Colstr3D3 = [ColstrT3,Colstr6];
Colstr3D = [Colstr3DT,Colstr3D1,Colstr3D2,Colstr3D3];

Colstr2D1 = [ColstrT1,Colstr51,Colstr52,Colstr53,Colstr54];
Colstr2D2 = [ColstrT2,Colstr55,Colstr57,Colstr59,Colstr62];
Colstr2D3 = [ColstrT3,Colstr58,Colstr61,Colstr63];
Colstr2D4 = [ColstrT4,Colstr56,Colstr60,Colstr64,Colstr65,...
    Colstr66,Colstr67,Colstr68];
Colstr2D = [Colstr2DT,Colstr2D1,Colstr2D2,Colstr2D3,Colstr2D4];

ColstrDebug = [ColstrDebug2,ColstrDebug3];
Colstr = [Colstr3D,Colstr2D,ColstrDebug];

% Colstr Pages:
n = 0.1;
p = 0.2;
a = 0.3;
ColstrPC = '\n  n = "Next Page", p = "Previous Page", a = "Show All Collections"';

Colstr3DP1 = [Colstr3DT,Colstr3D1];
Colstr3DP2 = [Colstr3DT,Colstr3D2,Colstr3D3];

Colstr2DP1 = [Colstr2DT,Colstr2D1];
Colstr2DP2 = [Colstr2DT,Colstr2D2];
Colstr2DP3 = [Colstr2DT,Colstr2D3];
Colstr2DP4 = [Colstr2DT,Colstr2D4];

ColstrP = {Colstr3DP1,Colstr3DP2,Colstr2DP1,Colstr2DP2,Colstr2DP3,Colstr2DP4};
ColstrPD = [];

% Create Variables:
gateC = 1;
numC = 1;
numP = 0;

% First Question:
SQ = false;
qCollection(numC) = input(['[?] What would you like to do?',ColstrPC,ColstrQuit,ColstrInput]);

% Check First Answer
Invalid = qCollection == 0 || qCollection == -2;
if Invalid
    error("[!] You can't use that as the first collection!")
end

while gateC == 1

    % Subsequent Questions:
    if SQ
        qCollection(numC) = input(['[?] What else would you like to do?',ColstrPD,ColstrQuit,ColstrRun,ColstrPC,ColstrInput]);
    end
    
    % Takes action based on the current choice:
    switch qCollection(numC)
        case -2
            disp('[&] Initiating Debug Mode: Getting programs for all requested collections.')
            gateC = 0;
        case -1
            disp('[~] Quitting Script')

            % Clear Collection Names:
            clear -regexp Colstr
            return
        case 0
            gateC = 0;
            numC = numC - 1;
        case p
            if numP <= 1
                numP = size(ColstrP,2);
            else
                numP = numP - 1;
            end
            ColstrPD = ColstrP{numP};
            qCollection(numC) = [];
        case n
            if numP == size(ColstrP,2)
                numP = 1;
            else
                numP = numP + 1;
            end
            ColstrPD = ColstrP{numP};
            qCollection(numC) = [];
        case a
            ColstrPD = Colstr;
            qCollection(numC) = [];
        otherwise
            numC = numC + 1;
    end
    SQ = true;
    
end

% Clear Collection Names:
clear -regexp Colstr
clear Invalid
clear p
clear n
clear a

%% Create Pre-Run Process Index:
[preP,numC] = preRunIndex(qCollection);

%% Prerun:

disp('[&] Initializing Collections')

P = [];

% Prerun and Create Run Index
for preI = 1:size(preP,1)
    for prep = preP(preI,:)
        switch prep
            case 0
                % Ignore
                break
            case 101
                % Name Translation
                % Foam and Wall Name Translation:
                Tf = MSD.Foam.Thickness;
                Lf = MSD.Foam.Length;
                Hf = MSD.Foam.Height;
                Tw = MSD.Wall.Thickness;
                Lw = MSD.Wall.Length;
                Hw = MSD.Wall.Height;

                % R Value Name Translation:
                eRw = MSD.Wall.eR;
                Rw = MSD.Wall.R;
                Rf = MSD.Foam.R;

                % Plate Name Translation:
                Lp = MSD.Plate.Length;

                % Mesh Name Translation
                Hmax = MSD.Mesh.Hmax;
                Hmin = MSD.Mesh.Hmin;
                HOverride = MSD.Mesh.HOverride;

                disp('[+] [101] Names Translated')

            case 102
                % 3D Foam Analysis - Matrix Creation
                
                Tfm = Tf:-MSD.FMod.FstepT:0;
                Lfm = Lf:-MSD.FMod.FstepL:0;
                Hfm = Hf:-MSD.FMod.FstepH:0;
                [Tfm, Lfm, Hfm] = meshgrid(Tfm,Lfm,Hfm);

                Logic = Tfm > 0 & Lfm > 0 &  Hfm > 0;
                Tfm = Tfm(Logic);
                Lfm = Lfm(Logic);
                Hfm = Hfm(Logic);

                if MSD.q.SF == 1
                    Logic = Hfm == Lfm;
                    Tfm = Tfm(Logic);
                    Lfm = Lfm(Logic);
                    Hfm = Hfm(Logic);
                end
                
                Index = (1:size(Tfm,1))';
                Foam = [Tfm, Lfm, Hfm, Index]; % Full foam matrix

                Tf = Foam(:,1); % All thicknesses
                Lf = Foam(:,2); % All lengths
                Hf = Foam(:,3); % All heights

                disp('[+] [102] Foam Matrix Created')
            case 103
                % 3D Foam Matrix if no Foam Analysis

                Foam = [Tf,Lf,Hf];

                disp('[+] [103] Foam Vector Created')
                
            case 104
                if run.p104
                    MN = input('[?] [104] Choose a Thermal Model File ID Number #: ');
                    MNstr = num2str(MN);
                    run.p104 = false;
                    disp(['[#] [104] Script Will Pull From and Save To Model: ',num2str(MN)])
                end
            case 105
                % Create Log Directory
                if ~exist('ThermalData','dir')
                    mkdir ThermalData
                    disp('[+] [105] ThermaData Directory Created')
                end
            case 106
                % Automatically Create ResultsSavename
                ResultsSavename = [DataSavename,'/ThermalResults ',datestr(now,'yyyy-mm-dd HH-MM-ss'),'.mat'];
                disp(['[+] [106] Thermal Results will be saved to',ResultsSavename])
            case 107
                % 3D Model Style
                modelStyle = '3D';
                disp(['[+] [107] Model Style set to: ',modelStyle])
            case 108
                % 2D Model Style
                modelStyle = '2D';
                disp(['[+] [108] Model Style set to: ',modelStyle])
            case 109
                % Create LogSavename
                LogSavename = [DataSavename,'/AnalysisResults ',datestr(now,'yyyy-mm-dd HH-MM-ss'),'.mat'];
                disp(['[+] [109] Logs will be saved to',LogSavename]) 
            case 110
                % 2D Foam Analysis - Matrix Creation
                
                Tfm = Tf:-MSD.FMod.FstepT:0;
                Lfm = Lf:-MSD.FMod.FstepL:0;
                [Tfm, Lfm] = meshgrid(Tfm,Lfm);

                Logic = Tfm > 0 & Lfm > 0;
                Tfm = Tfm(Logic);
                Lfm = Lfm(Logic);

                Index = (1:size(Tfm,1))';
                Foam = [Tfm, Lfm, Index]; % Full foam matrix

                Tf = Foam(:,1); % All thicknesses
                Lf = Foam(:,2); % All lengths

                disp('[+] [110] Foam Matrix Created')
                
            case 111
                % 3D Foam Matrix if no Foam Analysis

                Foam = [Tf,Lf,1];

                disp('[+] [111] Foam Vector Created')
            case 112
                % Thermal Property Translation
                TP.Wall.TC = MSD.Wall.TC;
                TP.Foam.TC = MSD.Foam.TC;

                % Stud:
                TP.Stud.TC = MSD.Stud.TC;
                SP = MSD.Stud.Pos;
                TP.Stud.L = MSD.Stud.Length;

                % Plate
                TP.Plate.L = MSD.Plate.Length;
                TP.Plate.T = MSD.Plate.Thickness;
                TP.Plate.TC = MSD.Plate.TC;

                % Extra:
                

                disp('[+] [112] Thermal Property Names Translated')
            case 113
                % Thermal Properties if Studs

                TP.Stud.Center = SP(1);
                TP.Stud.UpB = TP.Stud.Center + TP.Stud.L/2; % Stud Size Upper Bound
                TP.Stud.LowB = TP.Stud.Center - TP.Stud.L/2; % Stud Size Lower Bound
                TP.Wall.T = Tw;

                TC = @(location,state)thermalProperties(location,state,TP,MSD.propertyStyle);
                disp('[+] [113] Stud Location Defined')
            case 114
                % Thermal Property if No Stud
                TC = TP.Wall.TC;
                SP = NaN;
                disp('[+] [114] Thermal Properties Defined')
            case 115
                % Create Stud Analysis Matrix
                qSA = 0;

                while qSA == 0
                    qSA = input('[?] [115] Choose the number of stud analysis models you would like to run: ');
                    switch qSA
                        case qSA <= 0
                            fprintf(2,"[!] [115] That doesn't make sense, try again!\n")
                            qSA = 0;
                        otherwise
                            disp(['[$] [115] Creating Stud matrix with ',num2str(qSA),' elements'])
                            break
                    end
                end
      
                SP = (linspace(-Lw/2,Lw/2,qSA-1))';
                SP = [-Lw*10;SP]; %#ok<*AGROW> % Adding extra evaluation location where there is no stud
                disp('[+] [115] Stud Matrix Created')
            case 116
                % Create 2D Data Save File:
                DataSavename = ['ThermalData/2DLogData ',datestr(now,'yyyy-mm-dd HH-MM-ss')];
                disp('[+] [116] Current Data Directory Created')
            case 117
                % Create 3D Data Save File:
                DataSavename = ['ThermalData/3DLogData ',datestr(now,'yyyy-mm-dd HH-MM-ss')];
                disp('[+] [117] Current Data Directory Created')
            case 118
                % Automatically Create ModelSavename
                ModelSavename = [DataSavename,'/MeshedModels ',datestr(now,'yyyy-mm-dd HH-MM-ss'),'.mat'];
                disp(['[+] [109] Meshed Models will be saved to',ModelSavename])
            case 119
                if ~exist('numA','var')
                    numA = 0;
                end
            case 120
                % 2D Create Plate Analysis Matrix
                qPA = 0;

                while qPA == 0
                    qPA = input('[?] [120] Choose the number of plate analysis models you would like to run: ');
                    switch qPA
                        case qPA <= 0
                            fprintf(2,"[!] [120] That doesn't make sense, try again!\n")
                            qPA = 0;
                        otherwise
                            disp(['[$] [120] Creating Plate matrix with ',num2str(qPA),' elements'])
                            break
                    end
                end

                Lp = (linspace(MSD.Plate.Length,0,qPA))';
                disp('[+] [120] Plate Matrix Created')
            case 121
                % Determine Conversion
                MSD.q.CON = input(['[?] [121] Would you like to:',...
                    '\n    1 = R Imperial to SI' ...
                    '\n    2 = TC SI to Imperial',...
                    '\n   -1 = Quit',...
                    '\n  Input: ']);
                switch MSD.q.CON
                    case -1
                        disp('[~] [121] Quitting Script')
                        return
                    case 1
                        R = input('[?] [121] Input Imperial R Value: ');
                    case 2
                        TCSI = input('[?] [121] Input Thermal Conductivity Value: ');
                    otherwise
                        disp('[~] [121] Invalid Input, Quitting Script')
                        return
                end

                T = input('[?] [411] Please Enter the Thinkness This R is Associated to in Meters: ');

            case -3
                % Collection #-3 - Unit Conversion Tool

                switch MSD.q.CON
                    case 1
                        Pline = [-3 411];
                    case 2
                        Pline = [-3 412];
                end

            case -2
                % Collection #-2 - Display PreP and P
                disp('[+] [-02] Displaying preP:')
                disp(preP)
                disp('[+] [-02] Displaying P:')
                disp(P)
                disp('[~] [-02] Quitting Script:')
                return
            case 1
                % Collection #1 - Generate Geometry
                Pline = [1 505 401 402 403 212 203]; % All collections must start with their collection #

            case 2
                % Collection #2 - Run Model From Geometry
                Pline = [2 204 213 301 501 404 405 502 503 504 ...
                    506 509 510 211 205 207 209]; % All collections must start with their collection #
                
            case 3
                % Collection #3 - Plot Contour Slices
                Pline = [3 206 210 601 602 603]; % All collections must start with their collection #
                
            case 4 
                % Collection #4 - Get Temperature at Point
                Pline = [4 206 210 301 604]; % All collections must start with their collection #

            case 5
                % Collection #5 - Generate Single Geometry with Stud
                Pline = [5 505 401 402 403 212 203]; % All collections must start with their collection #

            case 6
                % Collection #6 - Run Model From Geometry with Mesh Overrides
                Pline = [2 204 213 301 501 410 405 502 503 504 ...
                    506 509 510 211 205 207 209]; % All collections must start with their collection #
                
            case 51
                % Collection #51 - 2D Generate Geometry
                Pline = [51 505 401 406 407 212 203]; % All collections must start with their collection #
                
            case 52
                % Collection #52 - Run Model From Geometry
                Pline = [52 204 213 301 501 404 405 502 503 ...
                    504 506 509 510 211 205 207 209]; % All collections must start with their collection #
                
            case 53
                % Collection #53 - 2D Contour Plot
                Pline = [53 206 208 210 605]; % All collections must start with their collection #
                
            case 54 
                % Collection #54 - 2D Get Temperature at Point
                Pline = [54 206 210 301 606 705 701]; % All collections must start with their collection #
                
            case 55
                % Collection #55 - Generate Single Geometry with Stud
                Pline = [55 505 401 406 407 212 203]; % All collections must start with their collection #
                
            case 56
                % Collection #56 - 2D Plot Current Thermal Properties
                Pline = [56 607]; % All collections must start with their collection #
                
            case 57
                % Collection #57 - 2D Generate All Geometries with Studs
                Pline = [57 505 401 302 406 407 702 701 212 203]; % All collections must start with their collection #
                
            case 58
                % Collection #58 - 2D Solve All Stud Analysis Models
                Pline = [58 204 213 303 408 409 507 504 508 509 510 211 205 207 209]; % All collections must start with their collection #
                
            case 59
                % Collection #59 - 2D Create all Foam Analysis Geometries
                Pline = [59 212 505 401 304 406 407 703 701 203]; % All collections must start with their collection #
                
            case 60
                % Collection #60 - 2D Plot Single Geometry
                Pline = [60 204 213 301 608]; % All collections must start with their collection #
            case 61
                % Collection #61 - 2D Solve All Foam Analysis Models
                Pline = [61 204 213 305 408 409 507 504 506 509 510 211 205 207 209]; % All collections must start with their collection #
            case 62
                % Collection #62 - 2D Generate All Plate Analysis Geometries
                Pline = [62 505 401 306 406 407 704 701 212 203]; % All collections must start with their collection #
            case 63
                % Collection #63 - 2D Solve All Plate Analysis Models
                Pline = [63 204 213 303 408 409 507 504 511 509 510 211 205 207 209]; % All collections must start with their collection #
            case 64
                % Collection #64 - 2D Plot Temperatures Across Intersection
                Pline = [64 206 210 609]; % All collections must start with their collection #
            case 65
                % Collection #65 - 2D Get Temperature Across Plate Region
                Pline = [65 206 210 610]; % All collections must start with their collection #
            case 66
                % Collection #66 - 2D Get Heat Flux At Point
                Pline = [66 206 210 301 307 611 706 701]; % All collections must start with their collection #
            case 67
                % Collection #67 - 2D Plot Single Mesh
                Pline = [67 204 213 301 612]; % All collections must start with their collection #
            case 68
                % Collection #68 - 2D Plot Heat Flux Across Wall
                Pline = [68 206 210 613]; % All collections must start with their collection #
        end
    end
    % Concatonate Collection to P
    P = concat2P(Pline,P,1);
end

disp('[=] Collections Initialized')


%% Run:

for I = 1:size(P,1)
    
    dummyCondition = 1; % Makes it so that the while loop can only be exited with a "break"

    while dummyCondition == 1 % Start Loop

    for p = P(I,:)
        switch p
            case 0
                % Ignore and Finish Collection
                break
            case -3
                % Collection #-3 - Unit Conversion Tool
                disp('[&] Starting Collection #-3 - Unit Conversion Tool')

            case 1
                % Collection #1 - Generate Single Geometry
                disp('[&] Starting Collection #1 - Generate Geometry')

                % Overrides:
                run.p301 = false;
            case 2
                % Collection #2 - Solve Single Thermal Model
                disp('[&] Starting Collection #2 - Solve Thermal Model')

                % Overrides
                run.p206 = false;
                run.p208 = false;
                run.p210 = false;
                run.p301 = false;
            case 3
                % Collection #3 - Creating Slices
                disp('[&] Starting Collection #3 - Creating Contour Slices')
            case 4
                % Collection #4 - Plotting Temperature at Point
                disp('[&] Starting Collection #4 - Plotting Temperature at Point')
            case 5
                % Collection #5 - Generate Single Geometry with Stud
                disp('[&] Starting Collection #5 - Generate Single Geometry with Stud')

                % Overrides:
                run.p301 = false;
            case 6
                % Collection #6 - Run Single Model From Geometry with Mesh Overrides
                disp('[&] Starting Collection #6 - Solve Single Model with Mesh Overrides')

                % Overrides
                run.p206 = false;
                run.p208 = false;
                run.p210 = false;
                run.p301 = false;
            case 51
                % Collection #51 - Generate Single Geometry
                disp('[&] Starting Collection #51 - Generate Geometry')

                % Overrides:
                run.p301 = 0;
            case 52
                % Collection #52 - Solve Single Thermal Model
                disp('[&] Starting Collection #52 - Solve Thermal Model')

                % Overrides
                run.p206 = false;
                run.p208 = false;
                run.p210 = false;
                run.p301 = false;
            case 53
                % Collection #53 - Creating Slices
                disp('[&] Starting Collection #53 - Create Contour Plot')
            case 54
                % Collection #54 - Plotting Temperature at Point
                if run.p54
                    disp('[&] Starting Collection #54 - Plotting Temperature at Point')
                    run.p54 = false;
                end
            case 55
                % Collection #55 - Generating Single Geometry with Stud
                disp('[&] Starting Collection #55 - Generating Single Geometry with Stud')
            case 56
                % Collection #56 - Plot Current Thermal Properties
                disp('[&] Starting Collection #56 - 2D Plot Current Termal Properties')
            case 57
                % Collection #57 - Generate All Geometries with Stud
                if run.p57 == 1
                    disp('[&] Starting Collection #57 - Generate All Stud Analysis Geometries')
                    run.p57 = false;
                end
            case 58
                % Collection #58 - Solve All Stud Analysis Models
                disp('[&] Starting Collection #58 - Solve All Stud Analysis Models')

                % Overrides
                run.p206 = false;
                run.p208 = false;
                run.p210 = false;
            case 59
                % Collection #59 - Create all Foam Analysis Geometries
                if run.p59
                    disp('[&] Starting Collection #59 - Create all Foam Analysis Geometries')
                    run.p59 = false;
                end

            case 60
                % Collection #60 - Plot Single Geometry
                disp('[&] Starting Collection #60 - Plot Single Geometry')
            case 61
                % Collection #61 - Solve All Foam Analysis Models
                disp('[&] Starting Collection #61 - Solve All Foam Analysis Models')

                % Overrides
                run.p206 = false;
                run.p208 = false;
                run.p210 = false;
            case 62
                % Collection #62 - Generate All Plate Analysis Geometries
                if run.p62
                    disp('[&] Starting Collection #62 - Generate All Plate Analysis Geometries')
                    run.p62 = false;
                end
            case 64
                % Collection #64 - Plot Temperatures Across Intersection
                disp('[&] Starting Collection #64 - Plot Temperatures Across Intersection')
            case 65
                % Collection #65 - Get Temperature Across Plate Region
                disp('[&] Starting Collection #65 - Get Temperature Across Plate Region')
            case 66
                if run.p66
                    % Collection #66 - Get Heat Flux at Point
                    disp('[&] Starting Collection #66 - Get Heat Flux at Point')
    
                    % Overrides:
                    run.p307 = false;
                    run.p66 = false;
                end
            case 67
                % Collection #67 - Plot Single Mesh
                disp('[&] Starting Collection #67 - Plot Single Mesh')
            case 68
                % Collection #68 - Plot Heat Flux Across Wall
                disp('[&] Starting Collection #68 - Plot Heat Flux Across Wall')

            case 203
                % Make Directory:
                if ~exist('ThermalModels','dir')
                    mkdir ThermalModels
                    disp('[+] [203] ThermaModels Directory Created')
                end

                % Store MSD
                MSDm = MSD;

                % Save Thermal Model to Mat File
                save(['ThermalModels/ThermalModel',MNstr,'.mat'],'ThermalModel','Logs','numM','numMstr','MN','MNstr','MSDm',"Store",'-v7.3')
                clear MSDm
                disp(['[+] [203] [Model ',numMstr,'] ','Saving to Model Number ',MNstr])

            case 204
                % Load Thermal Model from Mat File:
                load(['ThermalModels/ThermalModel',MNstr,'.mat'])
                disp(['[+] [204] [Model ',numMstr,'] ','Loading from Model Number ',MNstr])

                % Force and Check Model Specification:
                if MSDm.savedate ~= MSD.savedate
                    fprintf(2,['[!] [204] [Model ',numMstr,'] ','It appears that you are attempting to overwrite the Model Specifications associated with this file.\n'])
                    qContinue = input(['[?] [204] [Model ',numMstr,'] ','What would you like to do (1 = Overwrite MS, 0 = Load MS from Model File, -1 = Quit): ']);
                    
                    switch qContinue
                        case 1
                            disp(['[*] [204] [Model ',numMstr,'] ','Overwritig Model Specifications with Current Settings'])
                            pause(1) % Pause so this can be read
                        case 0
                            MSD = MSDm;
                            disp(['[+] [204] [Model ',numMstr,'] ','Forced Model Specifications from ',datestr(MSD.savedate)])
                        case -1
                            disp(['[-] [204] [Model ',numMstr,'] ','Quitting Script'])
                            return
                    end
                    clear qContinue
                end
                
            case 205
                % Save Analysis Logs
                disp('[$] [205] Saving Logs')
                save(LogSavename,"AResults","AResultsD","AResultsC","Specifications","numM","Logs",'-v7.3')
                disp(['[+] [205] Logs have been saved as ',LogSavename])

            case 206
                if run.p206
                    % Load Foam Analysis Logs
                    disp('[?] Choose the Log file you would like to load: ')
                    [filenameAL, pathnameAL] = uigetfile('*.*','[?] Choose the Log file you would like to load: ');
                    load([pathnameAL,filenameAL])
                    disp(['[+] [206] File ',filenameAL,' has been loaded!'])
                end
            case 207
                % Save Thermal Model Logs
                disp('[$] [207] Saving Thermal Models')
                save(ModelSavename,"ThermalModel","numM",'-v7.3')
                disp(['[+] [207] Mesh Thermal Models have been saved as ',LogSavename])
            case 208
                if run.p208
                    % Load Thermal Model Logs
                    disp('[?] Choose the Meshed Thermal Model file you would like to load: ')
                    [filenameTML, pathnameTML] = uigetfile('*.*','[?] Choose the Meshed Thermal Model file you would like to load: ');
                    load([pathnameTML,filenameTML])
                    disp(['[+] [208] File ',filenameTML,' has been loaded!'])
                end
            case 209
                % Save Thermal Results Logs
                disp('[$] [209] Saving Thermal Results')
                save(ResultsSavename,"ThermalResults","numM",'-v7.3')
                disp(['[+] [209] Thermal Results have been saved as ',ResultsSavename])
            case 210
                if run.p210
                    % Load Thermal Results Logs
                    disp('[?] Choose the Thermal Results file you would like to load: ')
                    [filenameTRL, pathnameTRL] = uigetfile('*.*','[?] Choose the Meshed Thermal Model file you would like to load: ');
                    load([pathnameTRL,filenameTRL])
                    disp(['[+] [210] File ',filenameTRL,' has been loaded!'])
                end
            case 211
                % Create DataLog Folder:
                if ~exist(DataSavename,'dir')
                    mkdir(DataSavename)
                end
            case 212
                % Store necessary variables for ThermalModel

                % Foam:
                Store.Foam.T = Foam(:,1);
                Store.Foam.H = Foam(:,3);
                Store.Foam.L = Foam(:,2);
                Store.Foam.Foam = Foam;
                Logs.Foam.numMAdj = Foam(1,end) - 1; % Stores how the 
                % model number must be adjusted to access the correct Foam
                % #

                % Wall
                Store.Wall.T = Tw;
                Store.Wall.H = Hw;
                Store.Wall.L = Lw;


            case 213
                % Unpack necessary variables for ThermalModel
                % Foam:
                Tf = Store.Foam.T;
                Hf = Store.Foam.H;
                Lf = Store.Foam.L;
                Foam = Store.Foam.Foam;

                % Wall
                Tw = Store.Wall.T;
                Hw = Store.Wall.H;
                Lw = Store.Wall.L;
                
                % Clear Variable
                clear Store
            case 301
                % Select Thermal Model Number:
                if run.p301
                    numMstr = num2str(numM);
                    qnumM = input(['[?] [301] [Model ',numMstr,'] ','Current Model Number: ',numMstr,'\n    Choose a New One? (0 = no or Input #): ']);
                    if qnumM <= 0
                        disp(['[-] [301] [Model ',numMstr,'] ','Model Number Not Modified'])
                    else
                        numM = qnumM;
                        numMstr = num2str(numM);
                        disp(['[+] [301] [Model ',numMstr,'] ','New Model Number Chosen: ',numMstr])
                    end
                end
            case 302
                % Stud Analysis Modification

                % Load Variables
                TP.Stud.Center = SP(numM-(Logs.numMi-1));
                TP.Stud.UpB = TP.Stud.Center + TP.Stud.L/2; % Stud Size Upper Bound
                TP.Stud.LowB = TP.Stud.Center - TP.Stud.L/2; % Stud Size Lower Bound
                TP.Wall.T = Tw;

                % Condition
                TC = @(location,state)thermalProperties(location,state,TP,MSD.propertyStyle);
                disp(['[+] [302] [Model ',numMstr,'] ','New Stud Location Set: ', num2str(TP.Stud.Center)])
            case 303
                % Create '__p' variables for the Parallel Pool
                
                % Preallocate:
                ip = (Logs.numMi:numM) - (Logs.numMi - 1);
                sizeip = size(ip,2);
                Tfp = zeros(1,sizeip);
                Lfp = zeros(1,sizeip);
                Hfp = zeros(1,sizeip);
                Twp = zeros(1,sizeip);
                Lwp = zeros(1,sizeip);
                Hwp = zeros(1,sizeip);
                % Create:
                for ip = ip
                    Tfp(ip) = Tf;
                    Lfp(ip) = Lf;
                    Hfp(ip) = Hf;
                    Twp(ip) = Tw;
                    Lwp(ip) = Lw;
                    Hwp(ip) = Hw;
                end
                
                % Clear
                clear ip
            case 304
                % Foam Analysis Modification:
                Tf = Foam(numM-(Logs.numMi-1),1);
                Lf = Foam(numM-(Logs.numMi-1),2);
                Hf = Foam(numM-(Logs.numMi-1),3);
                Foam(numM-(Logs.numMi-1),end) = numM;
            case 305
                % Create '__p' variables for Foam Analysis in the Parallel Pool
                Tfp = Tf;
                Lfp = Lf;
                Hfp = Hf;
                
                % Pre Allocate
                ip = (Logs.numMi:numM) - (Logs.numMi - 1);
                sizeip = size(ip,2);
                Twp = zeros(1,sizeip);
                Lwp = zeros(1,sizeip);
                Hwp = zeros(1,sizeip);
                
                % Create
                for ip = ip
                    Twp(ip) = Tw;
                    Lwp(ip) = Lw;
                    Hwp(ip) = Hw;
                end
            case 306
                % Plate Analysis Modification

                % Load Variables
                TP.Plate.L = Lp(numM-(Logs.numMi-1));

                % Condition
                TC = @(location,state)thermalProperties(location,state,TP,MSD.propertyStyle);
                disp(['[+] [306] [Model ',numMstr,'] ','New Plate Length Set: ', num2str(TP.Plate.L)])
            case 307
                % Add One to numM
                if run.p307
                    numM = numM + 1;
                    numMstr = num2str(numM);
                    disp('[+] [307] Added One to numM')
                end

            case 401
                % Create Single New Thermal Model
                if exist('numM','var') % Model #
                    numM = numM + 1;
                else
                    numM = 1;
                end
                numMstr = num2str(numM);
                
                thermalmodel = createpde('thermal',MSD.modelType);
                ThermalModel{numM} = thermalmodel;
                disp(['[+] [401] [Model ',numMstr,'] ','New Thermal Model Created'])
            case 402
                % 3D Generate Single Geometry
                disp(['[$] [402] [Model ',numMstr,'] ','Generating Geometry'])
                ThermalModel{numM}.Geometry = modelshapew3D(thermalmodel,MSD.q.RM,Lw,Hw,Tw,Lf,Hf,Tf);
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


                    % Ask for Inconsistant Mesh:
                    if MSD.q.NCM3D == 1
                        Logs.NCMF = input(['[?] [403] [Model ',numMstr,'] ','Specify the face #(s) you would like to use a reduced mesh around: ']);
                    end

                    % Run Prototype Model for Check
                    disp(['[*] [403] [Model ',numMstr,'] ','Running Prototype Model for Check'])
                    generateMesh(thermalmodel,'Hmin',0.2,'Hmax',1);

                    figure(1)

                    thermalBC(thermalmodel,'Face',IndoorF,'Temperature',MSD.BC.TempwI); % These boundary conditions will be kept for the final model
                    thermalBC(thermalmodel,'Face',[OutdoorFF,OutdoorWF],'Temperature',MSD.BC.TempwO);


                    if all(MSD.modelType=="transient")

                        thermalIC(thermalmodel,Tempi); % Initial Conditions only apply to tranient models

                        TP.Wall.TC = ThermalConductivity; 
                        TMw = MassDensity; 
                        TSw = SpecificHeat;

                        thermalProperties(thermalmodel,'ThermalConductivity',TP.Wall.TC,...
                                                       'MassDensity',TMw,...
                                                       'SpecificHeat',TSw);

                    elseif all(MSD.modelType=="steadystate")
                        thermalProperties(thermalmodel,'ThermalConductivity',TC);
                    end

                    % Geometry Test Results:
                    resultstest = solve(thermalmodel);
                    pdeplot3D(thermalmodel,"ColorMapData",resultstest.Temperature)

                    drawnow

                    gateV = input(['[?] [403] [Model ',numMstr,'] ','Does this model look correct? (1 = y, 0 = n): ']);
                    if gateV == 0
                        fprintf(2,['[!] [403] [Model ',numMstr,'] ','You likely did not choose the faces correctly, try again!\n'])
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
                thermalmodel = ThermalModel{numM};
                thermalresults = solve(thermalmodel);
                ThermalResults{numM} = thermalresults;
                disp(['[+] [405] [Model ',numMstr,'] ','Model Solved'])

            case 406
                % 2D Generate Single Geometry:
                disp(['[$] [406] [Model ',numMstr,'] ','Generating 2D Geometry'])
                GP.Wall.L = Lw;
                GP.Wall.T = Tw;
                GP.Foam.L = Lf;
                GP.Foam.T = Tf;
                GP.propertyStyle = MSD.propertyStyle;
                modelshapew = @(varargin)modelshapew2D(GP,varargin{:});
                geometryFromEdges(ThermalModel{numM},modelshapew); % Uses Geometry
                disp(['[+] [406] [Model ',numMstr,'] ','2D Geometry Generated'])
            case 407 
                disp(['[$] [407] [Model ',numMstr,'] ','Applying Conditions'])
                % 2D Apply Thermal Properties:
                
                thermalmodel = ThermalModel{numM}; % Import Thermal Model from Cell

                if all(MSD.modelType=="transient")
                    TP.Wall.TC = ThermalConductivity; 
                    TMw = MassDensity; 
                    TSw = SpecificHeat;
                    
                    thermalProperties(thermalmodel,'ThermalConductivity',TP.Wall.TC,...
                                                   'MassDensity',TMw,...
                                                   'SpecificHeat',TSw);
            
                    thermalIC(thermalmodel,Tempi); % Apply Initial Condition
            
                    disp(['[#] [407] [Model ',numMstr,'] ','Model Type = Transient'])            
                elseif all(MSD.modelType=="steadystate")
                    thermalProperties(thermalmodel,'ThermalConductivity',TC);
                    disp(['[#] [407] [Model ',numMstr,'] ','Model Type = Steady State'])
                end

                % Apply Boundary Conditions based on property style
                switch MSD.propertyStyle
                    case 'ComplexNoFoam'
                        thermalBC(thermalmodel,'Edge',1,'Temperature',MSD.BC.TempwI);
                        thermalBC(thermalmodel,'Edge',3,'Temperature',MSD.BC.TempwO);  
                    otherwise
                        thermalBC(thermalmodel,'Edge',1,'Temperature',MSD.BC.TempwI);
                        thermalBC(thermalmodel,'Edge',[3,5,7],'Temperature',MSD.BC.TempwO);  
                end


                ThermalModel{numM} = thermalmodel; % Re Apply to Cell
                disp(['[+] [407] [Model ',numMstr,'] ','Conditions Applied'])

            case 408
                % Generate All Meshes
                disp('[$] [408] Generating All Meshes')
                parfor numM = Logs.numMi:numM
                    numMstr = num2str(numM);
                    disp(['[*] [408] [Model ',numMstr,'] ','Generating Mesh'])
                    timeri(numM,1) = datetime('now');
                    
                    % Generate Mesh
                    ThermalModel{numM}.Mesh = generateMesh(ThermalModel{numM},'Hmin',Hmin,'Hmax',Hmax);
                    
                    timerf(numM,1) = datetime('now');
                    disp(['[*] [408] [Model ',numMstr,'] ','Mesh Generated'])  
                end
                disp('[+] [408] All Meshes generated')

            case 409
                % Solve All Thermal Models
                disp('[$] [408] Solving All Models')
                parfor numM = Logs.numMi:size(ThermalModel,2)
                    numMstr = num2str(numM); %#ok<*PFTUSW> 
                    disp(['[*] [409] [Model ',numMstr,'] ','Solving Model'])
                    timeri(numM,2) = datetime('now')
                    ThermalResults{numM} = solve(ThermalModel{numM});
                    timerf(numM,2) = datetime('now')
                    disp(['[*] [409] [Model ',numMstr,'] ','Model Solved'])
                end
                disp('[$] [408] All Models Solved')
            case 410
                % Generate Single Mesh with Overrides:
                disp(['[$] [410] [Model ',numMstr,'] ','Generating Mesh with overrides'])
                
                if ~exist('Logs.NCMF','var')
                    error('[!] [410] This model does not appear to have any overries associated with it')
                end

                ThermalModel{numM}.Mesh = generateMesh(ThermalModel{numM},'Hmin',Hmin,'Hmax',Hmax,'Hface',{Logs.NCMF,HOverride});
                disp(['[+] [410] [Model ',numMstr,'] ','Mesh Generated'])
            case 411
                % Convert Imperial R to Metric Thermal Conductivity
                RSI = R * (1/1055) * (3600/1) * (1/10.76) * (1/1.8); %Conversion In order: (btu/J) * (2/hr) * (msq/ftsq) * (C/F)

                TCSI = T/RSI;

                Conversion = [R;T;RSI;TCSI];
                Conversion = array2table(Conversion,...
                    'RowNames',{'Initial R (hr*F*ft^2/Btu)','Thickness (m)','RSI (K*m^2/W)','Thermal Conductivity (W/m*k)'});
                disp('[+] [411] Displaying Conversions')
                disp(Conversion)

            case 412
                % Convert Metric Thermal Conductivity to Imperial R
                RSI = T/TCSI;

                R = RSI / ((1/1055) * (3600/1) * (1/10.76) * (1/1.8)); %Conversion In order: (btu/J) * (2/hr) * (msq/ftsq) * (C/F)

                Conversion = [TCSI;T;RSI;R];
                Conversion = array2table(Conversion,...
                    'RowNames',{'Thermal Conductivity (W/m*k)','Thickness (m)','RSI (K*m^2/W)','R (hr*F*ft^2/Btu)'});
                disp('[+] [411] Displaying Conversions')
                disp(Conversion)

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
                dTempRatio = ((MSD.BC.TempwI-MSD.BC.TempwO)/(IntersectTemp-MSD.BC.TempwO)); %Whole Wall dT / Foam dT
                RwM = Rf * dTempRatio;
                RwM = RwM - Rf;

                % Find Percent Errors:
                pErrorT = abs((RwM - Rw)/Rw) * 100; %Percent Error from Insulation R
                pErrorET = abs((RwM - eRw)/eRw) * 100; %Percent Error from Effective R

            case 504
                % Duration with time2num
                duration = NaN*ones(size(timerf,1),1);
                if MSD.Overrides.run504 == 1
                    duration = timerf - timeri;
                    duration = time2num(duration,'seconds');
                    duration = (ones(1,size(duration,2))*duration')'; % Sums rows
                end
            case 505
                % Log Initial Logs.numM Before Process
                Logs.numMi = 1;
                
                if exist('Logs.numMi','var')
                    Logs.numMi = numM;
                end
                
                disp(['[+] [505] ','Logs.numMi determined to be: ',num2str(Logs.numMi)])

            case 506
                % Add to Foam Analysis Result Log
                numA = numA + 1;
                i = (Logs.numMi:numM)';
                
                % Logs (Always Present
                Logs.numA = numA;
                Logs.AType{numA,1} = 1; % AType = 1 means foam analysis
                Logs.Size{numA,1} = size(i,1);
                
                Logs.Index{numA,1} = i;
                Logs.duration{numA,1} = duration;
                Logs.Tf{numA,1} = Tf;
                Logs.Lf{numA,1} = Lf;
                Logs.pErrorT{numA,1} = pErrorT;
                Logs.pErrorET{numA,1} = pErrorET;
                Logs.RwM{numA,1} = RwM;
                Logs.IntersectTemp{numA,1} = IntersectTemp;
                
                % Logs (Sometimes Present
                if all(modelStyle=='2D')
                    Hf = NaN*ones(Logs.Size{numA,1},1);
                end
                Logs.Hf{numA,1} = Hf;
                
                Logs.StudPosition{numA,1} = NaN*ones(Logs.Size{numA,1},1);
                if exist('SP','var')
                    Logs.StudPosition{numA,1} = SP.*ones(Logs.Size{numA,1},1);
                end

                Logs.Lp{numA,1} = NaN*ones(Logs.Size{numA,1},1);
                if MSD.Plate.On
                    Logs.Lp{numA,1} = Lp.*ones(Logs.Size{numA,1},1);
                end
                
                % Logs (Never Present:
                
                disp(['[+] [506] [Model ',numMstr,'] ','Added to Foam Analysis Result Logs'])
            case 507
                % Find Predicted R Value and Percent Error for Stud Analysis     
                warning off
                TempwI = MSD.BC.TempwI;
                TempwO = MSD.BC.TempwO;
                parfor numM = Logs.numMi:numM
                    numMstr = num2str(numM);
                    disp(['[*] [507] [Model ',numMstr,'] ','Finding Predicted R Value'])
                    % Find Temperature at Intersection:
                    if all(modelStyle == '3D')
                        intersecttemp = interpolateTemperature(ThermalResults{numM},Tw,0,0);
                    elseif all(modelStyle == '2D')
                        intersecttemp = interpolateTemperature(ThermalResults{numM},Tw,0);
                    end
                    
                    % Find R Value
                    dTempRatio = ((TempwI-TempwO)/(intersecttemp-TempwO)); %Whole Wall dT / Foam dT
                    RwM(numM,1) = Rf * dTempRatio;
                    RwM(numM,1) = RwM(numM,1) - Rf;
                    
                    % Find Percent Errors: 
                    pErrorT(numM,1) = abs((RwM(numM,1) - Rw)/Rw) * 100; %Percent Error from Insulation
                    pErrorET(numM,1) = abs((RwM(numM,1) - eRw)/eRw) * 100; %Percent Error from Effective


                    % Save Intersect Temp
                    IntersectTemp(numM,1) = intersecttemp
                end
                warning on
                disp('[+] [507] Predicted R Values Found')
            case 508
                % Add to Stud Analysis Result Logs
                numMstr = num2str(numM);
                numA = numA + 1;
                i = (Logs.numMi:numM)';
                
                % Logs
                Logs.numA = numA;
                Logs.AType{numA,1} = 2; % AType = 2 means Stud Analysis
                Logs.Size{numA,1} = size(i,1);
                
                Logs.Index{numA,1} = i;
                Logs.duration{numA,1} = duration;
                Logs.Tf{numA,1} = Tf .* ones(size(i,1),1);
                Logs.Lf{numA,1} = Lf .* ones(size(i,1),1);
                Logs.pErrorT{numA,1} = pErrorT;
                Logs.pErrorET{numA,1} = pErrorET;
                Logs.RwM{numA,1} = RwM;
                Logs.IntersectTemp{numA,1} = IntersectTemp;
                Logs.StudPosition{numA,1} = SP;
                
                % Logs (Sometimes Present):
                switch modelStyle
                    case '3D'
                        Logs.Hf{numA,1} = Hf .* ones(Logs.Size{numA,1},1);
                    case '2D'
                        Logs.Hf{numA,1} = NaN .* ones(Logs.Size{numA,1},1);
                end

                Logs.Lp{numA,1} = NaN*ones(Logs.Size{numA,1},1);
                if MSD.Plate.On
                    Logs.Lp{numA,1} = Lp.*ones(Logs.Size{numA,1},1);
                end

                % Logs (Never Present):
                
                % Message
                disp(['[+] [508] ','Added Stud Analysis to Result Logs'])
            case 509
                % Create Specifications Table:
                modelTypeSTR = string(MSD.modelType);
                Specifications = [modelTypeSTR,MSD.Mesh.Hmax,MSD.Mesh.Hdelta,MSD.Wall.R,MSD.Foam.R,MSD.Wall.Thickness,MSD.Wall.Length,...
                    MSD.Wall.Height,MSD.BC.TempwI,MSD.BC.TempwO,MSD.Wall.TC,MSD.Stud.TC,modelStyle,MSD.propertyStyle]';
                Specifications = array2table(Specifications,...
                            'RowNames',{'Model','Hmax','Hdelta (0 to 1)','R-wall','R-foam','Wall Thickness','Wall Length','Wall Height','Indoor BC',...
                            'Outdoor BC','Wall Thermal Conductivity','Stud Thermal Conductivity','Model Style','Property Style'});
            case 510
                % Create AResults Table:
                [AResults,AResultsD,AResultsC] = createAResults(Logs,MSD.Overrides.OldVersion);
            case 511
                % Add to Plate Analysis Results Log
                numMstr = num2str(numM);
                numA = numA + 1;
                i = (Logs.numMi:numM)';
                
                % Logs
                Logs.numA = numA;
                Logs.AType{numA,1} = 3; % AType = 3 means Plate Analysis
                Logs.Size{numA,1} = size(i,1);
                
                Logs.Index{numA,1} = i;
                Logs.duration{numA,1} = duration;
                Logs.Tf{numA,1} = Tf * ones(size(i,1),1);
                Logs.Lf{numA,1} = Lf * ones(size(i,1),1);
                Logs.pErrorT{numA,1} = pErrorT;
                Logs.pErrorET{numA,1} = pErrorET;
                Logs.RwM{numA,1} = RwM;
                Logs.IntersectTemp{numA,1} = IntersectTemp;

                Logs.Lp{numA,1} = Lp;
                
                % Logs (Sometimes Present):
                switch modelStyle
                    case '3D'
                        Logs.Hf{numA,1} = Hf * ones(Logs.Size{numA,1},1);
                    case '2D'
                        Logs.Hf{numA,1} = NaN * ones(Logs.Size{numA,1},1);
                end

                Logs.StudPosition{numA,1} = NaN * ones(Logs.Size{numA,1},1);
                if exist('SP','var')
                    Logs.StudPosition{numA,1} = SP.*ones(Logs.Size{numA,1},1);
                end
                

                % Logs (Never Present):
                
                % Message
                disp(['[+] [508] ','Added Stud Analysis to Result Logs'])

            case 601
               % 3D Y Slice Analysis (Vertical Y)
               gateP = 1;
               while gateP == 1
                   qTRpa = input('[?] [601] What model # would you like to Yslice? (-1 = all, or row index # from AResults): ');
                   
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
                            Tf = AResultsD(i,4);
                
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
                        Tf = AResultsD(i,4);
            
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
                   qTRpa = input('[?] [602] What model # do you want to Zslice? (-1 = all, or row index # from AResults): ');
                   
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
                            Tf = AResultsD(i,4);
                
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
                        Tf = AResultsD(i,4);
            
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
                   qTRpa = input('[?] [603] What model # do you want to Xslice? (-1 = all, or row index # from AResults): ');
                   
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
                            Tf = AResultsD(i,4);
                
                            thermalresults = ThermalResults{i};
                            
                            % Create Mesh and Plot:
                
                            [Z,Y] = meshgrid(linspace(Hw/2,-Hw/2),linspace(-Lw/2,Lw/2));
                            X = Xslice.*ones(size(Z,1),size(Z,2));
                            V = interpolateTemperature(thermalresults,X,Y,Z);
                            V = reshape(V,size(Z));
                            surf(Y,Z,V,'LineStyle','none');
                            view(0,90)
                            title(['Colored Plot through X (Thickness) = ',num2str(Xslice)])
                            xlabel('Y (Length)')
                            ylabel('Z (Height)')
                            colorbar
                        end
                   else
                       i = qTRpa;
                       % Create Figure:
                        disp(['[*] [603] Plotting Model #',num2str(i)])
                        fname = ['Xslice Results From Model #',num2str(i)];
                        figure('Name',fname)
                        
                        % Pull Necessary Data for This Model:
                        Tf = AResultsD(i,4);
            
                        thermalresults = ThermalResults{i};
                        
                        % Create Mesh and Plot:
            
                        [Z,Y] = meshgrid(linspace(Hw/2,-Hw/2),linspace(-Lw/2,Lw/2));
                        X = Xslice.*ones(size(Z,1),size(Z,2));
                        V = interpolateTemperature(thermalresults,X,Y,Z);
                        V = reshape(V,size(Z));
                        surf(Y,Z,V,'LineStyle','none');
                        view(0,90)
                        title(['Colored Plot through X (Thickness) = ',num2str(Xslice)])
                        xlabel('Y (Length)')
                        ylabel('Z (Height)')
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

                Tf = AResultsD(numM,4);
                Lf = AResultsD(numM,5);
                Hf = AResultsD(numM,6);

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
                
                gateP = 1;
                while gateP == 1
                    qTRpa = input('[?] [605] What model # do you want to 2D Plot? (-1 = all, or row index # from AResults): ');
    
                    if qTRpa == -1
                        % Create plot for all table values
                        for numM = 1:size(ThermalResults,2)
                        % Pull Important Info:
                        Tw = str2double(Specifications{6,1});
                        Lw = str2double(Specifications{7,1});
                        
                        Tf = AResultsD(numM,4);
                        Lf = AResultsD(numM,5);
                        numMstr = num2str(numM);
                        
                        % Plot
                        disp(['[$] [605] Plotting Model #',num2str(numM)])
                        fname = ['Results from 2D Model #',num2str(numM)];
                        figure('Name',fname)
        
                        pdeplot(ThermalModel{numM},'XYData',ThermalResults{numM}.Temperature(:), ...
                                         'Contour','on', ...
                                         'ColorMap','hot')
                        hold on
                        xaxis = [0,Tw+Tf+Tw];
                        yaxis = [-3*Lw/4,3*Lw/4];
                        axis([xaxis,yaxis])
                        axis square
                        title(fname)
                        xlabel('Thickness (m)')
                        ylabel('Length (m)')
                        hold off
                        
                        drawnow

                        end
                        gateP = 0;
                    else
                        % Create plot for specific value
                        numM = qTRpa;
                        numMstr = num2str(numM);
                        disp(['[$] [605] Plotting Model #',num2str(numM)])
                        fname = ['Results from 2D Model #',num2str(numM)];
                        figure('Name',fname)
        
                        pdeplot(ThermalModel{numM},'XYData',ThermalResults{numM}.Temperature(:), ...
                                         'Contour','on', ...
                                         'ColorMap','hot')
                        hold on
                        xaxis = [0,Tw+Tf+Tw];
                        yaxis = [-3*Lw/4,3*Lw/4];
                        axis([xaxis,yaxis])
                        axis square
                        title(fname)
                        xlabel('Thickness (m)')
                        ylabel('Length (m)')
                        hold off

                        drawnow

                        gateP = input('[?] [605] Would you like to plot anything else? (1 = y, 0 = n): ');
                    end
                end
            case 606
                % 2D Temperature at Point
                
                % Load Important Information:
                Tw = str2double(Specifications{6,1});
                Lw = str2double(Specifications{7,1});

                Tf = AResultsD(numM,4);
                Lf = AResultsD(numM,5);

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
                    
                    % Create Array and Table
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
            case 607
                % Plot Current Thermal Properties:
                disp(['[$] [607] Plotting Current Thermal Properties for propertyStyle: "',MSD.propertyStyle,'"'])
                fname = ['Thermal Properties for propertyStyle: "',MSD.propertyStyle,'"'];
                figure('Name',fname)

                % Create Mesh and Plot:

                [location.x,location.y] = meshgrid(linspace(0,Tw + Tf,500),linspace(-Lw/2,Lw/2,500));
                X = location.x;
                Y = location.y;
                V = thermalProperties(location,-1,TP,MSD.propertyStyle);
                surf(X,Y,V,'LineStyle','none');
                view(0,90)
                title(fname)
                xlabel('X (Thickness)')
                ylabel('Y (Length)')
                colorbar
                disp(['[+] [607] Plotted Current Thermal Properties for propertyStyle: "',MSD.propertyStyle,'"'])
                disp('[#] [607] Note: The exact shape of the geometry is NOT shown, only the thermal properties')
           case 608
                % Create Plot of Current Thermal Model Geometry
                while numM > 0
                    % Asign Lf and Tf
                    Tf = Foam(numM-Logs.Foam.numMAdj,1);
                    Lf = Foam(numM-Logs.Foam.numMAdj,2);

                    % Plot Model
                    numMstr = num2str(numM);
                    Fwg = figure('Name','Wall Geometry');
                    pdegplot(ThermalModel{numM},'EdgeLabels','on')
                    xaxis = [0,Tw+Tf+Tw];
                    yaxis = [-3*Lw/4,3*Lw/4];
                    axis([xaxis,yaxis])
                    hold on
                    axis square
                    hold off
                    drawnow
                    disp(['[+] [608] [Model ',numMstr,'] ','Plotted Current Geometry']);
                    numM = input(['[?] [608] [Model ',numMstr,'] ','Would you like to plot another geometry? (Choose Model # or 0 = n): ']);
                end
            case 609
                % Create Graph of Temperatures Across Intersection:
                gateP = 1;
                while gateP == 1
                    qTRpa = input('[?] [609] What model # do you want to plot the Intersection of? (-1 = all, or row index # from AResults): ');
    
                    if qTRpa == -1
                        % Create plot for all table values
                        for numM = 1:size(ThermalResults,2)

                        % Pull Important Info:
                        Tw = str2double(Specifications{6,1});
                        Lw = str2double(Specifications{7,1});
                        
                        Tf = AResultsD(numM,4);
                        Lf = AResultsD(numM,5);
                        numMstr = num2str(numM);

                        % Interpolate Temperature:
                        y = linspace(-Lf/2,Lf/2);
                        T = zeros(1,size(y,2));
                        c = 1;
                        for i = y
                            T(c) = interpolateTemperature(ThermalResults{numM},Tw,i);
                            c = c + 1;
                        end
                        clear c
                        
                        % Plot
                        disp(['[$] [609] Plotting Model #',num2str(numM)])
                        fname = ['Temperature Across Intersection from Model #',num2str(numM)];
                        figure('Name',fname)
        
                        plot(y,T,'ro')

                        title(fname)
                        xlabel('Length (m)')
                        ylabel('Temperature')

                        drawnow

                        end
                        gateP = 0;
                    else
                        % Create plot for specific value
                        numM = qTRpa;

                        % Pull Important Info:
                        Tw = str2double(Specifications{6,1});
                        Lw = str2double(Specifications{7,1});
                        
                        Tf = AResultsD(numM,4);
                        Lf = AResultsD(numM,5);
                        numMstr = num2str(numM);

                        % Interpolate Temperature:
                        y = linspace(-Lf/2,Lf/2);
                        T = zeros(1,size(y,2));
                        c = 1;
                        for i = y
                            T(c) = interpolateTemperature(ThermalResults{numM},Tw,i);
                            c = c + 1;
                        end
                        clear c


                        % Plot
                        disp(['[$] [609] Plotting Model #',num2str(numM)])
                        fname = ['Temperature Across Intersection from Model #',num2str(numM)];
                        figure('Name',fname)
        
                        plot(y,T,'ro')
                        
                        title(fname)
                        xlabel('Length (m)')
                        ylabel('Temperature')

                        drawnow

                        gateP = input('[?] [609] Would you like to plot anything else? (1 = y, 0 = n): ');
                    end
                end
            case 610
                % Get Average Temperature Across Plate Region
                gateP = 1;
                while gateP == 1
                    qTRpa = input('[?] [610] What model # do you want to average the Intersection of? (-1 = all, or row index # from AResults): ');
    
                    if qTRpa == -1
                        % Create plot for all table values
                        for numM = 1:size(ThermalResults,2)
                            
                        % Pull Important Info:
                        Tw = str2double(Specifications{6,1});
                        Lw = str2double(Specifications{7,1});
                        
                        Tf = AResultsD(numM,4);
                        Lf = AResultsD(numM,5);
                        Lp = AResultsD(numM,11);
                        numMstr = num2str(numM);

                        % Check Plate Legnth:
                        if isnan(Lp)
                            Lp = MSD.Plate.Length;
                            fprintf(2,['[!] [610] [Model ',num2str(numM),'] ',...
                                'Plate Length not Found in AResults, using length from Model Specifications: ',num2str(Lp),'\n']);
                        end

                        % Interpolate Temperature:
                        disp(['[*] [610] [Model ',num2str(numM),'] ',...
                            'Getting Average'])

                        y = linspace(-Lp/2,Lp/2);
                        T = zeros(1,size(y,2));
                        c = 1;
                        for i = y
                            T(c) = interpolateTemperature(ThermalResults{numM},Tw,i);
                            c = c + 1;
                        end
                        clear c
                        
                        % Get Average Temperature:
                        ATi = (ones(1,size(y,2)) * T')./size(y,2);

                        if ~exist('ATD','var')
                            ATD = [numM Lp ATi];
                        else
                            ATD = [ATD;numM Lp ATi];
                        end
                        AT = array2table(ATD,...
                        'VariableNames',{'Model #','Plate Length','Mean Temp'});

                        end
                        disp(AT)
                        gateP = 0;
                    else
                        % Create plot for specific value
                        numM = qTRpa;

                        % Pull Important Info:
                        Tw = str2double(Specifications{6,1});
                        Lw = str2double(Specifications{7,1});
                        
                        Tf = AResultsD(numM,4);
                        Lf = AResultsD(numM,5);
                        Lp = AResultsD(numM,11);
                        numMstr = num2str(numM);
                        
                        % Check Plate Legnth:
                        if isnan(Lp)
                            Lp = MSD.Plate.Length;
                            disp(['[!] [610] [Model ',num2str(numM),'] ',...
                                'Plate Length not Found in AResults, using length from Model Specifications: ',num2str(Lp)]);
                        end

                        % Interpolate Temperature:
                        disp(['[*] [610] [Model ',num2str(numM),'] ',...
                            'Getting Average'])
                        y = linspace(-Lp/2,Lp/2);
                        T = zeros(1,size(y,2));
                        c = 1;
                        for i = y
                            T(c) = interpolateTemperature(ThermalResults{numM},Tw,i);
                            c = c + 1;
                        end
                        clear c
                        
                        % Get Average Temperature:
                        ATi = (ones(1,size(y,2)) * T')./size(y,2);

                        if ~exist('ATD','var')
                            ATD = [numM Lp ATi];
                        else
                            ATD = [ATD;numM Lp ATi];
                        end
                        AT = array2table(ATD,...
                        'VariableNames',{'Model #','Plate Length','Mean Temp'});

                        disp(AT)

                        gateP = input('[?] [610] Would you like to plot anything else? (1 = y, 0 = n): ');
                    end
                end
            case 611
                % 2D Get Heat Flux at Point
                
                % Load Important Information:
                Tw = str2double(Specifications{6,1});
                Lw = str2double(Specifications{7,1});

                Tf = AResultsD(numM,4);
                Lf = AResultsD(numM,5);

                TempwI = str2double(Specifications{9,1});
                TempwO = str2double(Specifications{10,1});

                gateHFAP = 1;
                while gateHFAP == 1
                    % Count Number of Points
                    if ~exist('numHFAP','var')
                        numHFAP = 1;
                    else
                        numHFAP = numHFAP + 1;
                    end
                    
                    % Get Point

                    if ~exist('qHFAM','var') || qHFAM ~= 2
                        disp(['[?] [606] [Model ',numMstr,'] ','What point would you like to use?'])
                        disp('[#] Origin is in center of indoor wall')
                        x = input('    Thickness = ');
                        y = input('    Length = ');
                    end

                    if ~exist('qHFAM','var') || qHFAM == 0
                        qHFAM = input('Plot This Value across All Models? (1 = y, 0 = n): ');
                        if qHFAM == 1 % Let it cycle through once to prevent double plotting
                            numHFAP = numHFAP - 1;
                            break
                        end
                    end
                        % Create Array and Table
                        disp(['[$] [611] Getting Heat Flux at Point on Model ',numMstr,': (',num2str(x),',',num2str(y),')'])
                        HFAtPointP = evaluateHeatFlux(ThermalResults{numM},x,y);
                        RfromHF = ((abs(TempwI - TempwO))/HFAtPointP) * 5.678;

                        HFAtPointD(numHFAP,:) = [numHFAP,numM,x,y,HFAtPointP,RfromHF];
                        HFAtPoint = array2table(HFAtPointD,...
                            'VariableNames',{'Point','Model #','X','Y','HeatFlux','Rwall'});
                        if ~(qHFAM == 2 && numM < size(ThermalResults,2))
                            disp(HFAtPoint)
                        end
                        
                        if qHFAM == 0
                            % Clear Old Values:
                            clear x
                            clear y
                            clear HFAtPointP
                            clear RfromHF
        
                            % Another?
                            gateHFAP = input(['[?] [606] [Model ',numMstr,'] ','Would you like to plot another point? (1 = y, 0 = n): ']);
                        else
                            gateHFAP = 0;
                        end
                end
            case 612
                % Plot Current Thermal Model Mesh
                disp(['[$] [612] [Model ',numMstr,'] ','Plotting Mesh'])

                while numM > 0
                    % Asign Lf and Tf
                    disp(['[*] [612] [Model ',numMstr,'] ','Generating Mesh'])
                    Tf = Foam(numM-Logs.Foam.numMAdj,1);
                    Lf = Foam(numM-Logs.Foam.numMAdj,2);
                    
                    % Generate Mesh:
                    Mesh612 = generateMesh(ThermalModel{numM},'Hmax',Hmax,'Hmin',Hmin);

                    % Plot Model
                    disp(['[*] [612] [Model ',numMstr,'] ','Plotting Mesh'])
                    numMstr = num2str(numM);
                    Fwg = figure('Name','Mesh');
                    hold on
                    title(['Mesh for Model ',numMstr,' - Note the Scale Difference'])
                    xlabel('Thickness')
                    ylabel('Length')
                    pdemesh(Mesh612)
                    xaxis = [0,Tw+Tf+Tw];
                    yaxis = [-3*Lw/4,3*Lw/4];
                    axis([xaxis,yaxis])
                    axis square
                    hold off
                    drawnow
                    disp(['[+] [612] [Model ',numMstr,'] ','Plotted Current Geometry']);
                    numM = input(['[?] [612] [Model ',numMstr,'] ','Would you like to plot another mesh? (Choose Model # or 0 = n): ']);

                end
                clear Mesh612
            case 613
                % Create Graph of Heat Flux Across the Outdoor Wall:
                gateP = 1;
                qW = input('[?] [613] Plot Heat Flux across: (1 = Outdoor Wall, 2 = Indoor Wall, -1 = Quit): ');
                switch qW
                    case 1
                        qWstr = 'Outdoor';
                    case 2
                        qWstr = 'Indoor';
                    otherwise
                        disp('[~] Quitting Script')
                        return
                end
                
                while gateP == 1
                    a = 0;
                    qTRpa = input(['[?] [613] What model # do you want to plot the Heat Flux across the',...
                        qWstr,' Wall of? (a = all, or row index # from AResults): ']);
    
                    if qTRpa == a
                        % Create plot for all table values
                        for numM = 1:size(ThermalResults,2)

                        % Pull Important Info:
                        Tw = str2double(Specifications{6,1});
                        Lw = str2double(Specifications{7,1});
                        
                        Tf = AResultsD(numM,4);
                        Lf = AResultsD(numM,5);
                        numMstr = num2str(numM);

                        % Interpolate Temperature:
                        y = linspace(-Lf/2,Lf/2,12);
                        T = zeros(1,size(y,2));
                        c = 1;
                        
                        switch qW
                            case 1
                                x = Tw;
                            case 2
                                x = 0;
                        end

                        for i = y
                            T(c) = evaluateHeatFlux(ThermalResults{numM},x,i);
                            c = c + 1;
                        end
                        clear c
                        
                        % Plot
                        disp(['[$] [613] Plotting Model #',num2str(numM)])
                        fname = ['Heat Flux Across ',qWstr,' Wall from Model #',num2str(numM)];
                        figure('Name',fname)
        
                        plot(y,T,'bo')

                        title(fname)
                        xlabel('Length (m)')
                        ylabel('Heat Flux')

                        drawnow

                        end
                        gateP = 0;
                    else
                        % Create plot for specific value
                        numM = qTRpa;

                        % Pull Important Info:
                        Tw = str2double(Specifications{6,1});
                        Lw = str2double(Specifications{7,1});
                        
                        Tf = AResultsD(numM,4);
                        Lf = AResultsD(numM,5);
                        numMstr = num2str(numM);

                        % Interpolate Temperature:
                        y = linspace(-Lf/2,Lf/2,12);
                        T = zeros(1,size(y,2));
                        c = 1;

                        switch qW
                            case 1
                                x = Tw;
                            case 2
                                x = 0;
                        end
                        
                        for i = y
                            T(c) = evaluateHeatFlux(ThermalResults{numM},x,i);
                            c = c + 1;
                        end
                        clear c


                        % Plot
                        disp(['[$] [613] Plotting Model #',num2str(numM)])
                        fname = ['Heat Flux Across ',qWstr,' Wall from Model #',num2str(numM)];
                        figure('Name',fname)
        
                        plot(y,T,'bo')
                        
                        title(fname)
                        xlabel('Length (m)')
                        ylabel('Heat Flux')

                        drawnow

                        gateP = input('[?] [613] Would you like to plot anything else? (1 = y, 0 = n): ');
                    end
                end

            case 701
                % Evaluate Condition. When Condition == 1, the Collection
                % will be repeated
                if Condition == 1
                    break % If the condition is 1, exit before we can run case 0
                end
            case 702
                % Stud Analysis Condition
                if TP.Stud.Center == SP(end)
                    Condition = 0;
                else
                    Condition = 1;
                end
            case 703
                % Foam Analysis Condition
                if (numM-(Logs.numMi-1)) == Foam(end,end)
                    Condition = 0;
                else
                    Condition = 1;
                end
            case 704
                % Plate Analysis Condition
                if TP.Plate.L == Lp(end)
                    Condition = 0;
                else
                    Condition = 1;
                end
            case 705
                % Repeat Collection 54
                Condition = input('[?] [705] Would you like to restart Collection 54? (y = 1, n = 0): ');
                
                % Adjust Run Variables
                switch Condition
                    case 0
                        disp('[-] [705] Exiting Collection')
                    case 1
                        run.p206 = false;
                        run.p210 = false;
                        disp('[+] [705] Restarting Collection')
                    otherwise
                        Condition = 0;
                        disp('[-] [705] Invalid Input - Exiting Collection')
                end
            case 706
                % Repeat Collection 66
                run.p206 = false;
                run.p210 = false;

                switch qHFAM
                    case 0
                        Condition = input('[?] [705] Would you like to restart Collection 66? (y = 1, n = 0): ');
                    case 1
                        qHFAM = 2;
                        numM = 0;

                        Condition = 1;

                        if size(ThermalResults,2) == 1
                            qHFAM = 0;
                            disp('[-] [706] There was only one model to plot in, so there is no sense in walking through the models')
                        end

                        run.p301 = false;
                        run.p307 = true;
                    case 2
                        if numM == size(ThermalResults,2)
                            qHFAM = 0;
                            numM = 1;
                            run.p301 = true;
                            run.p307 = false;
                            Condition = input('[?] [705] Would you like to restart Collection 66? (y = 1, n = 0): ');
                            disp('[+] [706] Finished Walking Through Models')
                        end

                end

        end
    end
    
    if exist('Condition','var') % Determines if the loop should be repeated
        if Condition == 1
            disp(['[*] Repeating Collection #',num2str(P(I,1))])
        else
            break % Exits Loop
        end
    else
        break % Exits loop
    end

    end % End Loop

    % Finish Collection:
    disp(['[=] Collection #',num2str(P(I,1)),' Finished'])
end      

%% Model Specification Presets: 

function MSD = msPreset(MSD)
    switch MSD.Preset
        case 'None'
            disp('[~] No MSPreset has been applied')
        case 'TimeMachine'
            % Property Style:
            MSD.propertyStyle = 'TimeMachine'; 

            % Shape of Wall:
            MSD.Foam.Thickness = 2.54 * 10^-2 + 0.0015875; % Including Aluminum Plate
            MSD.Foam.Length = 45.6 * 10^-2; %m
            MSD.Foam.Height = MSD.Foam.Length; 
            
            MSD.Wall.Thickness = 0.0635; %m
            MSD.Wall.Length = 90 * 10^-2; %m 
            MSD.Wall.Height = MSD.Wall.Length;

            % Wall Thermal Properties:
            MSD.Wall.TC = .0288; % Thermal Conductivity for the Wall W/(m*K)
            MSD.Foam.TC = MSD.Wall.TC;

            % Plate:
            MSD.Plate.Length = .302; %Plate Length
            MSD.Plate.Thickness = 0.0015875; % Plate Thickness
            MSD.Plate.TC = 150; %Plate Thermal Conductivity
            MSD.Plate.On = true;

            % Stud
            MSD.Stud.TC = MSD.Wall.TC*(10/4.38); % If Applicable
            MSD.Stud.Pos = 0; % Location of the center of the stud on the diagram
            MSD.Stud.Length = 0.0381; % Length of the stud along the y direction in meters

            % Wall and Foam R Values. Foam Adjustment Settings:
            MSD.Wall.eR = NaN;
            MSD.Wall.R = 10  + .63; 
            MSD.Foam.R = 5;
            
            % Message
            disp('[=] MSPreset "TimeMachine" has been applied')

        case 'GenericExtended'
            
            % Property Style:
            MSD.propertyStyle = 'GenericStud'; 

            % Shape of Wall:

            MSD.Wall.Thickness = 5.08 * 10^-2; %m
            MSD.Wall.Length = 90 * 10^-2; %m 
            MSD.Wall.Height = MSD.Wall.Length;

            MSD.Foam.Thickness = 2.54 * 10^-2; %m
            MSD.Foam.Length = 45.6 * 10^-2; %m
            MSD.Foam.Height = MSD.Wall.Height; 

            % Plate:
            MSD.Plate.On = false;

            % Wall Thermal Properties:
            MSD.Wall.TC = .0288; % Thermal Conductivity for the Wall W/(m*K)
            MSD.Foam.TC = MSD.Wall.TC;
            
            % Stud
            MSD.Stud.TC = .115; % If Applicable
            MSD.Stud.Pos = 0; % Location of the center of the stud on the diagram
            MSD.Stud.Length = 0.0381; % Length of the stud along the y direction in meters

            % Wall and Foam R Values. Foam Adjustment Settings:
            MSD.Wall.eR = NaN;
            MSD.Wall.R = 10; 
            MSD.Foam.R = 5;

            % Message:
            disp('[=] MSPreset "GenericExtended" has been applied')
        case 'Generic'
            
            % Property Style:
            MSD.propertyStyle = 'GenericStud'; 

            % Shape of Wall:

            MSD.Foam.Thickness = 2.54 * 10^-2; %m
            MSD.Foam.Length = 45.6 * 10^-2; %m
            MSD.Foam.Height = MSD.Foam.Length; 

            MSD.Wall.Thickness = 5.08 * 10^-2; %m
            MSD.Wall.Length = 90 * 10^-2; %m 
            MSD.Wall.Height = MSD.Wall.Length;

            % Plate:
            MSD.Plate.On = false;

            % Wall Thermal Properties:
            MSD.Wall.TC = .0288; % Thermal Conductivity for the Wall W/(m*K)
            MSD.Foam.TC = MSD.Wall.TC;
            
            % Stud
            MSD.Stud.TC = .115; % If Applicable
            MSD.Stud.Pos = 0; % Location of the center of the stud on the diagram
            MSD.Stud.Length = 0.0381; % Length of the stud along the y direction in meters

            % Wall and Foam R Values. Foam Adjustment Settings:
            MSD.Wall.eR = NaN;
            MSD.Wall.R = 10; 
            MSD.Foam.R = 5;

            % Message:
            disp('[=] MSPreset "Generic" has been applied')
        case 'Complex'

            % Property Style:
            MSD.propertyStyle = 'Complex'; 

            % Shape of Wall:

            MSD.Foam.Thickness = 2.54 * 10^-2 + 0.0015875; %m
            MSD.Foam.Length = 45.6 * 10^-2; %m
            MSD.Foam.Height = MSD.Foam.Length; 

            MSD.Wall.Thickness = (13.97 + 1.27 + 1.27) * 10^-2; %m
            MSD.Wall.Length = 90 * 10^-2; %m 
            MSD.Wall.Height = MSD.Wall.Length;

            % Plate:
            MSD.Plate.Length = .302; %Plate Length
            MSD.Plate.Thickness = 0.0015875; % Plate Thickness
            MSD.Plate.TC = 150; %Plate Thermal Conductivity
            MSD.Plate.On = true;

            % Wall and Foam Thermal Properties:
            MSD.Wall.TC = 0.044051; % Thermal Conductivity for the Wall W/(m*K)
            MSD.Foam.TC = 0.0288;
            
            % Stud
            MSD.Stud.TC = .115; % If Applicable
            MSD.Stud.Pos = 0; % Location of the center of the stud on the diagram
            MSD.Stud.Length = 0.0381; % Length of the stud along the y direction in meters

            % Wall and Foam R Values. Foam Adjustment Settings:
            MSD.Wall.eR = (16/((1.5/4.38) + (14.5/18))) + .45 + .81; % Effective R value
            MSD.Wall.R = 18 + .45 + .81; 
            MSD.Foam.R = 5;

            % Message:
            disp('[=] MSPreset "Complex" has been applied') 
        case 'ComplexNoFoam'

            % Property Style:
            MSD.propertyStyle = 'ComplexNoFoam'; 

            % Shape of Wall:

            MSD.Foam.Thickness = 0;
            MSD.Foam.Length = 0; %m
            MSD.Foam.Height = MSD.Foam.Length; 

            MSD.Wall.Thickness = (13.97 + 1.27 + 1.27) * 10^-2; %m
            MSD.Wall.Length = 90 * 10^-2; %m 
            MSD.Wall.Height = MSD.Wall.Length;

            % Plate:
            MSD.Plate.Length = 0; %Plate Length
            MSD.Plate.Thickness = 0.0015875; % Plate Thickness
            MSD.Plate.TC = 150; %Plate Thermal Conductivity
            MSD.Plate.On = false;

            % Wall and Foam Thermal Properties:
            MSD.Wall.TC = 0.044051; % Thermal Conductivity for the Wall W/(m*K)
            MSD.Foam.TC = 0.0288;
            
            % Stud
            MSD.Stud.TC = .115; % R value for studs is 6.88/5.5in
            MSD.Stud.Pos = 0; % Location of the center of the stud on the diagram
            MSD.Stud.Length = 0.0381; % Length of the stud along the y direction in meters

            % Wall and Foam R Values. Foam Adjustment Settings:
            MSD.Wall.eR = (16/((1.5/6.88) + (14.5/18))) + .45 + .81; % Effective R value
            MSD.Wall.R = 18 + .45 + .81; 
            MSD.Foam.R = 5;

            % Message:
            disp('[=] MSPreset "ComplexNoFoam" has been applied') 
            
    end


end


