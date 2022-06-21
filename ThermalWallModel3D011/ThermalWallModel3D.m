%% ThermalWallModel3D v 3D0.11
% Updated on June 17 2022
% Created by Jackson Kustell

clear

%% Preferences:


qAT = input(['[?] What would you like to do?','\n    Save ModelSpecifications and Run Model = 1','\n    Load ModelSpecifications and Run Model = 2','\n    Analyze Data = 3','\n    Save to ModelSpecifications.mat = 4','\n    Quit = -1','\n    Input: ']);

if qAT == 1 || qAT == 2
qF = input('[?] Would you like to perform foam anaylsis? (yes = 1, 0 = no): ');
qS = 1; % Save Data? (1 = yes, 0 = no)
qUI = input('[?] Would you like to use UI features while running this model? (yes = 1, no = 0): ');
qPlot = input('[?] Would you like to create plots of the model? (1 = yes, 0 = no): ');
qDur = input('[?] Do you have time2num installed? (1 = yes, 0 = no): ');
qV = input('[?] Are you running the most recent version of MatLab? (1 = yes, 0 = no): ');
end 

if qAT == 1 || qAT == 2 || qAT == 4
    if qAT == 1 || qAT == 4
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
        WallHeight = 90 * 10^-2; %m 
        
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
        
        Hmax = 2*10^-1; % Second Setting
        HdeltaP = .10; % Second Setting
        Hmin = Hmax*HdeltaP;
        
        % Foam Modification Settings:
        FstepT = .01; % Step size between foam trials for thickness
        FstepH = .1;% Step size between foam trials for thickness
        FstepL = .1; % Step size between foam trials for length
        qSF = 1; %Only analyze square foam sizes?
        
        % Save Settings:
        savedate = datetime('now');
        save('ModelSpecification.mat')

        if qAT == 4
            disp(['[+] Model Specifications have been saved to ModelSpecification.mat at ',datestr(savedate)])
            return
        end
    elseif qAT == 2
        save('ModelSpecification.mat','qAT','qF','qUI','qPlot','qDur','qV','-append')
        load ModelSpecification.mat
        disp(['[+] Model Specifications have been loaded from ', datestr(savedate)])
    end
    
    %% Non-User Edited Settings:
    if qS == 1
        if qUI == 1
            disp('[?] Choose the path you want to save to Log Data to:')
            pathName = uigetdir(path,'[?] Choose the path you want to save to Log Data to:');
            LogSavename = [pathName,'/3DLogData ',datestr(now,'yyyy-mm-dd HH:MM:ss'),'.mat'];
        else
            %In the noui version, there is currently no way to choose your save
            %location
            pathName = pwd;
            LogSavename = [pathName,'/3DThermalData/3DLogData ',datestr(now,'yyyy-mm-dd HH:MM:ss'),'.mat'];
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
    
    ProcessNum = size(Foam,1);
    qP = input(['[?] There are currently ',num2str(ProcessNum),' processes queued up, would you like to proceed?','\n    1 = yes','\n    0 = no','\n    Input: ']);
    if qP == 0
        disp('[-] Quitting Program')
        return
    end
    
    %% Execute Model:
    
    if ProcessNum >= 2
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
            FAResultsD(i,:) = [i,time2num(duration,'seconds'),Tf,Lf,Hf,pErrorT,RwM,IntersectTemp]
        
        
            disp(['[&] Process ',num2str(i),' has finished over duration: ',num2str(time2num(duration,'seconds')),' seconds'])
        end
    
    else
        %Solve Models:
        for i = 1:size(Foam,1)
            
            timeri = datetime('now');
            disp(['[&] Starting Process ',num2str(i),' on ',datestr(timeri)])
        
            Tf = Foam(i,1);
            Lf = Foam(i,2);
            Hf = Foam(i,3);
            [pErrorT,RwM,IntersectTemp] =  ThermalWallModel3DExecute(i,Tw,Lw,Hw,Tf,Lf,Hf);
            
            timerf = datetime('now');
            duration = timerf - timeri;
            if qDur == 1
                duration = time2num(duration,'seconds');
            else
                duration = -1;
                disp('[!] Duration will be displayed as -1 because you do not have time2num installed!')
            end
            
            FAResults(i,:) = [i,duration,Tf,Lf,Hf,pErrorT,RwM,IntersectTemp];
            FAResultsD(i,:) = [i,duration,Tf,Lf,Hf,pErrorT,RwM,IntersectTemp];
        
        
            disp(['[&] Process ',num2str(i),' has finished over duration: ',num2str(duration),' seconds'])
        end
    end
    
    if qV == 1
        Specifications = [modelType,Hmax,HdeltaP,Rw,Rf,Tw,Lw,Hw,TempwI,TempwO,Tempi,ThermalConductivity]';
        Specifications = array2table(Specifications,...
            'RowNames',{'Model','Hmax','HdeltaP (0 to 1)','R-wall','R-foam','Wall Thickness','Wall Length','Wall Height','Indoor BC','Outdoor BC','Interior Temp','Thermal Conductivity'});
        FAResults = array2table(FAResults,...
            'VariableNames',{'Process','Duration (s)','Foam Thickness','Foam Length','Foam Height','% Error','Predicted Rwall','Temp at Intersection (K)' });
    else
        Specifications = [modelType,Hmax,HdeltaP,Rw,Rf,Tw,Lw,Hw,TempwI,TempwO,Tempi,ThermalConductivity]';
        Specifications = array2table(Specifications,...
            'RowNames',{'Model','Hmax','HdeltaP(0-to-1)','R-wall','R-foam','Wall Thickness','Wall-Length','Wall-Height','Indoor-BC','Outdoor-BC','Interior-Temp','Thermal-Conductivity'});
        FAResults = array2table(FAResults,...
            'VariableNames',{'Process','Duration','FoamThickness','FoamLength','FoamHeight','PercentError','PredictedRwall','TempAtIntersection' });
    end
    
    if qS == 1
        save(LogSavename,"FAResults","FAResultsD","Specifications")
        disp(['[+] Logs have been saved as ',LogSavename])
    else
        disp('[-] Logs have not been saved')
    end

elseif qAT == 3
    
   % Choosing Data to Load:
   disp('[?] Choose the Log file you would like to load: ')
   [filenameL, pathnameL] = uigetfile('*.*','[?] Choose the Log file you would like to load: ');
   addpath(pathnameL)
   load(filenameL)
   disp(['[+] File ',filenameL,' has been loaded!'])

   % Choose how to process data:
   FreezeGate = 1;
   while FreezeGate == 1
       qFT = input('[?] Would you like to freeze Thickness? (1 = yes, 0 = no): ');
       qFL = input('[?] Would you like to freeze Length? (1 = yes, 0 = no): ');
       qFH = input('[?] Would you like to freeze Height? (1 = yes, 0 = no): ');
       qOV = input('[?] Choose the Column of FAResultsD to use as your output column: ');
       
       Dim = 3 - qFT - qFL - qFH;

       if Dim >= 3 || Dim <0
           disp('[%] Dim >= 3 or <= 0')
           disp('[!] Invalid input, you must choose to freeze at least one variable.')
       else
           FreezeGate = 0;
       end
   end
    
   %% Unique Values:
   % Determines Unique Values:
   uTf(:,1) = unique(FAResultsD(:,3));
   uLf(:,1) = unique(FAResultsD(:,4));
   uHf(:,1) = unique(FAResultsD(:,5));

   % Finds Max Length:
   uTfnum = size(uTf,1);
   uLfnum = size(uLf,1);
   uHfnum = size(uHf,1);
   uMax = max([uTfnum,uLfnum,uHfnum]);

   % Rewrites Variables to Size:
   uTf = zeros(uMax,1);
   uLf = zeros(uMax,1);
   uHf = zeros(uMax,1);
    
   % Determines Unique Values:
   uTf(1:uTfnum,1) = unique(FAResultsD(:,3));
   uLf(1:uLfnum,1) = unique(FAResultsD(:,4));
   uHf(1:uHfnum,1) = unique(FAResultsD(:,5));
   
   Index = 1:uMax;
   Index = Index';

   % Places Unique Values Together:
   UniqueValuesD = [Index,uTf,uLf,uHf];

   % Create and Display Table (Show Output is intentional):
   UniqueValues = array2table(UniqueValuesD,...
       "VariableNames",{'Row #','Thickness','Length','Height'});
   disp(UniqueValues)
    
   %% Freeze and Plot:
    
   % Reset Variables
   Freeze1 = 0;
   Freeze2 = 0;
   Freeze3 = 0;

   Col1 = 0;
   Col2 = 0;
   Col3 = 0;

   Var1 = 0;
   Var2 = 0;
   Var3 = 0;

   % Determines Freeze Values and Specifies Freeze Columns:
   if qFT == 1
       FT = input('[?] Choose a row # to use as the Thicnkess: ');
       FT = UniqueValuesD(FT,2); 
       Var1 = FT;
       Freeze1 = 3;
   else
       Col1 = 3;
       Col1N = 'Thickness';
   end

   if qFL == 1
       FL = input('[?] Choose a row # to use as the Length: ');
       FL = UniqueValuesD(FL,3);
       if Var1 == 0
           Var1 = FL;
       else
           Var2 = FL;
       end

       if Freeze1 == 0
           Freeze1 = 4;
       else
           Freeze2 = 4;
       end
   else
       if Col1 == 0
            Col1 = 4;
            Col1N = 'Length';
       else
           Col2 = 4;
           Col2N = 'Length';
       end
   end

   if qFH == 1
       FH = input('[?] Choose a row # to use as the Height: ');
       FH = UniqueValuesD(FH,4);

       if Var1 == 0 
            Var1 = FH;
       elseif Var1 ~= 0 && Var2 == 0
           Var2 = FH;
       else
           Var3 = FH;
       end

       if Freeze1 == 0 
            Freeze1 = 5;
       elseif Freeze1 ~= 0 && Freeze2 == 0
           Freeze2 = 5;
       else
           Freeze3 = 5;
       end
   else
       if Col1 == 0 
            Col1 = 5;
            Col1N = 'Height';
       elseif Col1 ~= 0 && Col2 == 0
           Col2 = 5;
           Col2N = 'Height';
       else
           Col3 = 5;
           Col3N = 'Height';
       end
   end

   % Find Values:
   count = 1;
   if Dim == 2
       % Set Up Plot
       F = figure('Name','3D Model - Data Plot');
       for i = 1:size(FAResultsD,1)
           if FAResultsD(i,Freeze1) == Var1
               % Find Variables:
               Plot1(count,1) = FAResultsD(i,Col1);
               Plot2(count,1) = FAResultsD(i,Col2);
               PlotOV(count,1) = FAResultsD(i,qOV);
               count = count + 1;
               
               % Plot Variables
               plot3(Plot1,Plot2,PlotOV,'bo')
               title(['Plot of ',FAResults.Properties.VariableNames{qOV},' when',FAResults.Properties.VariableNames{Freeze1},' = ',num2str(Var1)])
               xlabel(Col1N)
               ylabel(Col2N)
               zlabel(FAResults.Properties.VariableNames{qOV})

           end
       end
   elseif Dim == 1
       % Set Up Plot
       F = figure('Name','3D Model - Data Plot');
       for i = 1:size(FAResultsD,1)
           if FAResultsD(i,Freeze1) == Var1 && FAResultsD(i,Freeze2) == Var2
               % Find Variable
               Plot1(count,1) = FAResultsD(i,Col1);
               PlotOV(count,1) = FAResultsD(i,qOV);
               count = count + 1;

               % Plot:
               plot(Plot1,PlotOV,'bo')
               title(['Plot of ',FAResults.Properties.VariableNames{qOV},' when',FAResults.Properties.VariableNames{Freeze1},' = ',num2str(Var1),' and ',FAResults.Properties.VariableNames{Freeze2},' = ',num2str(Var2)])
               xlabel(Col1N)
               ylabel(FAResults.Properties.VariableNames{qOV})

           end
       end
   elseif Dim == 0
       for i = 1:size(FAResultsD,1)
           if FAResultsD(i,Freeze1) == Var1 && FAResultsD(i,Freeze2) == Var2 && FAResultsD(i,Freeze3) == Var3
               PointOV = FAResultsD(i,qOV);
               PointV = [Var1,Var2,Var3,PointOV];   
               PointV = array2table(PointV,...
                "VariableNames",{'Thickness','Length','Height','Output Variable'});
           end
       end
   end

else
    disp('[-] Quitting Program')
end