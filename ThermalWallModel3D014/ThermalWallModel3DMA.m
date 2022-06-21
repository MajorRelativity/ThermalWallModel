%% ThermalWallModel3D Mesh Analysis Edition:
% Updated on June 21 2022
% Created by Jackson Kustell

clear

%% Preferences:


qAT = input(['[?] What would you like to do?','\n    Save ModelSpecifications and Run Model = 1','\n    Load ModelSpecifications and Run Model = 2','\n    Save to ModelSpecifications.mat = 3','\n    Quit = -1','\n    Input: ']);

if qAT == 1 || qAT == 2
    qF = input('[?] Would you like to perform foam anaylsis? (yes = 1, 0 = no): ');
    qS = 1; % Save Data? (1 = yes, 0 = no)
    qTR = 1; % Output ThermalResults (1 = yes, 0 = no)
    qUI = input('[?] Would you like to use UI features while running this model? (yes = 1, no = 0): ');
    qPlot = input('[?] Would you like to create plots of the model? (1 = yes, 0 = no): ');
    qDur = input('[?] Do you have time2num installed? (1 = yes, 0 = no): ');
    qV = input('[?] Are you running the most recent version of MatLab? (1 = yes, 0 = no): ');
end 

% Mesh Analysis Settings

Hmax = 5*10^-3; % Max Mesh Length
HdeltaP = .10; % Perent of Hmax Hmin is
Hmin = Hmax*HdeltaP;

Hstep = 1*10^-3; % Increase in Hmax each run
HmaxF =  1.5 * 10^-2; % When Mesh Analysis Ends

countMA = 1; % Counter Variable for Mesh Analysis:

for m = Hmax:Hstep:HmaxF
    
    % Hmax Modification:
    Hmax = m;

    if qAT == 1 || qAT == 2 || qAT == 3
        if qAT == 1 || qAT == 3
            %% Model Specifications (User Edited):
            
            % Model Type ("transient", "steadystate")
            modelType = "steadystate";
            qRM = 1; % Use reduced size mode? (1 = yes, 0 = no). Uses only the upper left quadrant
            
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
            
            % Foam Modification Settings:
            FstepT = .01; % Step size between foam trials for thickness
            FstepH = .1;% Step size between foam trials for thickness
            FstepL = .1; % Step size between foam trials for length
            qSF = 1; %Only analyze square foam sizes?
            qPar = 0; % Use Parallel Processing
            
            % Save Settings:
            if countMA == 1
                savedate = datetime('now');
                save('ModelSpecification.mat')
            else
                save('ModelSpecification.mat','Hmax','-append')
            end
    
            if qAT == 3 && countMA == 1
                disp(['[+] Model Specifications have been saved to ModelSpecification.mat at ',datestr(savedate)])
                return
            end
        elseif qAT == 2 && countMA == 1
            save('ModelSpecification.mat','qAT','qF','qUI','qPlot','qDur','qV','m','-append')
            load ModelSpecification.mat
            disp(['[+] Model Specifications have been loaded from ', datestr(savedate)])
        end
        
        %% Non-User Edited Settings:
        if qS == 1
            if qUI == 1
                disp('[?] Choose the path you want to save to Log Data to:')
                pathName = uigetdir(path,'[?] Choose the path you want to save to Log Data to:');
                LogSavename = [pathName,'/3DMALogData ',datestr(now,'yyyy-mm-dd HH:MM:ss'),'.mat'];
            else
                %In the noui version, there is currently no way to choose your save
                %location
                pathName = pwd;
                LogSavename = [pathName,'/3DThermalData/3DMALogData ',datestr(now,'yyyy-mm-dd HH:MM:ss'),'.mat'];
            end
        end
        
        %% Foam Modification Matrix:
        
        Tf = FoamThickness;
        Lf = FoamLength;
        Hf = FoamHeight;
        Tw = WallThickness;
        Lw = WallLength;
        Hw = WallHeight;
        
        if qF == 1
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
            
            Foam = [Tfm, Lfm, Hfm];
        elseif qF == 0
            Foam = [Tf,Lf,Hf];
        end
        
        if countMA == 1
            ProcessNum = size(Hmax:Hstep:HmaxF,2)*size(Foam,1);
            qP = input(['[?] There are currently ',num2str(ProcessNum),' processes queued up, would you like to proceed?','\n    1 = yes','\n    0 = no','\n    Input: ']);
            if qP == 0
                disp('[-] Quitting Program')
                return
            end
        end
        
        %% Execute Model:
        
        if ProcessNum >= 2 && qPar == 1
            % Create Paralell Pool:
            F = gcp;
            
            % Find Size of Pool:
            if isempty(F)
                Fsize = 0;
            else
                Fsize = F.NumWorkers;
            end
            
            Allocation = Fsize-6;
    
            % Preallocate Columns:
                FoamT = Foam(:,1);
                FoamL = Foam(:,2);
                FoamH = Foam(:,3);
            
            %Solve Models:
            parfor (i = 1:size(Foam,1),Allocation)
                
                Index = str2double([num2str(countMA),'.',num2str(i)])

                timeri = datetime('now')
                disp(['[&] Starting Process ',num2str(Index),' on ',datestr(timeri)])
            
                Tf = FoamT(i);
                Lf = FoamL(i);
                Hf = FoamH(i);
    
                if qTR == 0
                    [pErrorT,RwM,IntersectTemp] =  ThermalWallModel3DExecute(Index,Tw,Lw,Hw,Tf,Lf,Hf);
                elseif qTR == 1
                    [pErrorT,RwM,IntersectTemp,thermalresults] =  ThermalWallModel3DExecute(Index,Tw,Lw,Hw,Tf,Lf,Hf);
                    ThermalResults{i} = thermalresults;
                end
                
                timerf = datetime('now')
                duration = timerf - timeri
    
                if qDur == 1
                    duration = time2num(duration,'seconds');
                else
                    duration = -1;
                    disp('[!] Duration will be displayed as -1 because you do not have time2num installed!')
                end

                FAResultsD(i,:) = [Index,duration,Tf,Lf,Hf,pErrorT,RwM,IntersectTemp,Hmax]
                            
                disp(['[&] Process ',num2str(Index),' has finished over duration: ',num2str(time2num(duration,'seconds')),' seconds'])
            end
        
        else
            %Solve Models:
            for i = 1:size(Foam,1)
                
                Index = str2double([num2str(countMA),'.',num2str(i)]);

                timeri = datetime('now');
                disp(['[&] Starting Process ',num2str(Index),' on ',datestr(timeri)])
            
                Tf = Foam(i,1);
                Lf = Foam(i,2);
                Hf = Foam(i,3);
    
                if qTR == 0
                    [pErrorT,RwM,IntersectTemp] =  ThermalWallModel3DExecute(Index,Tw,Lw,Hw,Tf,Lf,Hf);
                elseif qTR == 1 % Adds thermal results if requested
                    [pErrorT,RwM,IntersectTemp,thermalresults] =  ThermalWallModel3DExecute(Index,Tw,Lw,Hw,Tf,Lf,Hf);
                    ThermalResults{i} = thermalresults;
                end
    
                timerf = datetime('now');
                duration = timerf - timeri;
                if qDur == 1
                    duration = time2num(duration,'seconds');
                else
                    duration = -1;
                    disp('[!] Duration will be displayed as -1 because you do not have time2num installed!')
                end

                FAResultsD(i,:) = [Index,duration,Tf,Lf,Hf,pErrorT,RwM,IntersectTemp,Hmax];
                   
                disp(['[&] Process ',num2str(Index),' has finished over duration: ',num2str(duration),' seconds'])
            end
        end
    
    else
        disp('[-] Quitting Program')
        return
    end
    
    %% Store Thermal Results Information

    ThermalResultsF{countMA} = ThermalResults;

    %% Store MA Information:
    if countMA == 1
        MAResultsD = FAResultsD;
    else
        MAResultsD = [MAResultsD;FAResultsD];
    end

    countMA = countMA + 1;
end

%% Final Adjustments and Save:
MAResults = array2table(MAResultsD,...
                'VariableNames',{'Process','Duration','FoamThickness','FoamLength','FoamHeight','PercentError','PredictedRwall','TempAtIntersection','Hmax'});

if qV == 1
    Specifications = [modelType,HdeltaP,Rw,Rf,Tw,Lw,Hw,TempwI,TempwO,Tempi,ThermalConductivity]';
    Specifications = array2table(Specifications,...
        'RowNames',{'Model','HdeltaP (0 to 1)','R-wall','R-foam','Wall Thickness','Wall Length','Wall Height','Indoor BC','Outdoor BC','Interior Temp','Thermal Conductivity'});
else
    Specifications = [modelType,HdeltaP,Rw,Rf,Tw,Lw,Hw,TempwI,TempwO,Tempi,ThermalConductivity]';
    Specifications = array2table(Specifications,...
        'RowNames',{'Model','HdeltaP(0-to-1)','R-wall','R-foam','Wall Thickness','Wall-Length','Wall-Height','Indoor-BC','Outdoor-BC','Interior-Temp','Thermal-Conductivity'});
end

if qS == 1
    if qTR == 0
        save(LogSavename,"MAResults","MAResultsD","Specifications")
        disp(['[+] Logs have been saved as ',LogSavename])
    elseif qTR == 1
        save(LogSavename,"MAResults","MAResultsD","Specifications","ThermalResultsF")
        disp(['[+] Logs have been saved with thermalresults as ',LogSavename])
    end
else
    disp('[-] Logs have not been saved')
end
