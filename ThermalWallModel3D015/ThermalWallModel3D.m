%% ThermalWallModel3D v 3D0.15
% Updated on June 22 2022
% Created by Jackson Kustell

clear

%% Preferences:


qAT = input(['[?] What would you like to do?','\n    Save ModelSpecifications and Prepare Mesh = 1','\n    Load Model Specifications and Prepare Model = 2','\n    Load ModelSpecifications and Run Model = 3','\n    Analyze Data = 4','\n    Save to ModelSpecifications.mat = 5','\n    Quit = -1','\n    Input: ']);

qS = 1; % Save Data? (1 = yes, 0 = no)

if qAT == 1 || qAT == 2
    qF = input('[?] Would you like to perform foam anaylsis? (yes = 1, 0 = no): ');
end

if qAT == 3
    qUI = input('[?] Would you like to use UI features while running this model? (yes = 1, no = 0): ');
    qPlot = input('[?] Would you like to create plots of the model? (1 = yes, 0 = no): ');
    qDur = input('[?] Do you have time2num installed? (1 = yes, 0 = no): ');
    qV = input('[?] Are you running the most recent version of MatLab? (1 = yes, 0 = no): ');
end

if qAT == 1 || qAT == 2 || qAT == 3 || qAT == 5
    MSN = input('[?] Choose a Model Specification #: ');
    MS = ['ModelSpecification',num2str(MSN),'.mat'];
end

if qAT == 1 || qAT == 2 || qAT == 3 || qAT == 5
    if qAT == 1 || qAT == 5
        %% Model Specifications (User Edited):
        
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
        Hmax = 10*10^-3; % Max Mesh Length
        HdeltaP = .10; % Perent of Hmax Hmin is
        Hmin = Hmax*HdeltaP;
        
        % Foam Modification Settings:
        FstepT = 1; % Step size between foam trials for thickness
        FstepH = .1;% Step size between foam trials for thickness
        FstepL = .1; % Step size between foam trials for length
        qSF = 1; %Only analyze square foam sizes?
        qPar = 0; % Use Parallel Processing

        % Foam Name Translation:
        Tf = FoamThickness;
        Lf = FoamLength;
        Hf = FoamHeight;
        Tw = WallThickness;
        Lw = WallLength;
        Hw = WallHeight;
        
        % Save Settings:
        savedate = datetime('now');
        save(MS)

        if qAT == 5
            disp(['[+] Model Specifications have been saved to ',MS,' at ',datestr(savedate)])
            return
        end
    elseif qAT == 2 || qAT == 3
        if qAT == 2
            save(MS,'qAT','qF','-append')
        elseif qAT == 3
            save(MS,'qAT','qUI','qPlot','qDur','qV','-append')
        end
        
        load(MS)
        disp(['[+] Model Specifications have been loaded from ',MS,' from ', datestr(savedate)])
    end
    
    if qAT == 1 || qAT == 2
        %% Foam Modification Matrix:

        
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
        
        ProcessNum = size(Foam,1);
        qP = input(['[?] There are currently ',num2str(ProcessNum),' processes queued up, would you like to proceed?','\n    1 = yes','\n    0 = no','\n    Input: ']);
        if qP == 0
            disp('[-] Quitting Program')
            return
        end
        
        %% Create Geometry and Generate Mesh:
    
        for i = 1:ProcessNum
    
            % Thermal Model:
        
            thermalmodel = createpde('thermal',modelType);
            
            % Thermal Geometry:
            disp(['[Process ',num2str(i),'/',num2str(ProcessNum),'] ','[$] Creating Geometry'])
            gm = modelshapew3D(thermalmodel,qRM,Lw,Hw,Tw,Lf,Hf,Tf);
            thermalmodel.Geometry = gm;
            
            gateV = 0;
    
            while gateV == 0
                figure(1)
                pdegplot(thermalmodel,'FaceLabels','on','FaceAlpha',.5);
        
                drawnow
        
                IndoorF = input('[?] Please specify the face # of the indoor side: ');
                OutdoorFF = input('[?] Please specify the face # of the outdoor foam side: ');
                OutdoorWF = input('[?] Please specify the face # of the outdoor wall side: ');
                
                % Run Prototype Model for Check
                generateMesh(thermalmodel,'Hmin',0,'Hmax',1)
                
                figure(1)
                
                thermalBC(thermalmodel,'Face',IndoorF,'Temperature',TempwI);
                thermalBC(thermalmodel,'Face',[OutdoorFF,OutdoorWF],'Temperature',TempwO);
                thermalIC(thermalmodel,Tempi);
                
                if all(modelType=="transient")
                    TCw = ThermalConductivity; 
                    TMw = MassDensity; 
                    TSw = SpecificHeat;
                    
                    thermalProperties(thermalmodel,'ThermalConductivity',TCw,...
                                                   'MassDensity',TMw,...
                                                   'SpecificHeat',TSw);
                    disp(['[Process ',num2str(i),'/',num2str(ProcessNum),'] ','[~] Model Type = Transient'])
                
                elseif all(modelType=="steadystate")
                    TCw = ThermalConductivity; 
                    thermalProperties(thermalmodel,'ThermalConductivity',TCw);
                    disp(['[Process ',num2str(i),'/',num2str(ProcessNum),'] ','[~] Model Type = Steady State'])
                end
                
                % Geometry Test Results:
                resultstest = solve(thermalmodel);
                pdeplot3D(thermalmodel,"ColorMapData",resultstest.Temperature)
                
                drawnow
    
                gateV = input('[?] Does this test model look close to correct? (1 = yes, 0 = no): ');
                if gateV == 0
                    disp(['[Process ',num2str(i),'/',num2str(ProcessNum),'] ','[!] You may have chosen the faces incorrectly, please try again'])
                end
    
            end
    
            disp(['[Process ',num2str(i),'/',num2str(ProcessNum),'] ','[+] Geometry Created and Verified'])
            
            % Generate True Mesh
            disp(['[Process ',num2str(i),'/',num2str(ProcessNum),'] ','[$] Generating True Mesh'])
            F(i) = parfeval(@generateMesh,1,thermalmodel,'Hmin',Hmin,'Hmax',Hmax);
            
            F
            
            % Save Thermal Model:
            ThermalModel{i} = thermalmodel;
    
        end
        
        disp('[*] Waiting for Mesh Generation to complete')
    
        wait(F)
        
        disp('[$] Extracting Mesh Generation')
    
        for ii = 1:size(F,2)
            ThermalModel{ii}.Mesh = fetchOutputs(F(ii));
        end

        if qS == 1
            save(MS,'ThermalModel','ProcessNum','-append')
        end
        
        disp('[+] Thermal Model Preparation Complete')
        return
    end

    if qAT == 3

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
            parfor (i = 1:ProcessNum,Allocation)
                
                %% Start Timer and Prepare Foam

                timeri = datetime('now');
                disp(['[&] Starting Process ',num2str(i),' on ',datestr(timeri)])
                    
                %% Solve Model:
                disp(['[Process ',num2str(i),'] [$] Solving Model'])
                if all(modelType=="transient")
                tlist = 0:timeStep:timeE;
                thermalresults = solve(ThermalModel{i},tlist);
                else
                    thermalresults = solve(ThermalModel{i});
                end
                
                disp(['[Process ',num2str(i),'] [+] Model Solved'])
                
                %% Predict R Value:
                
                % Find Temperature at Intersection
                IntersectTemp = interpolateTemperature(thermalresults,Tw,0,0);
                
                % Find R Value:
                dTempRatio = ((TempwI-TempwO)/(IntersectTemp-TempwO)); %Whole Wall dT / Foam dT
                RwM = Rf * dTempRatio;
                RwM = RwM - Rf;
                pErrorT = abs((RwM - Rw)/Rw) * 100; %Percent Error
                
                % Plotting Thermal Contour Map
                if qPlot == 1
                    figure(2)
                
                    [X,Z] = meshgrid(linspace(0,(Tw+Tf)),linspace(-Hw/2,Hw/2));
                    Y = 0.*ones(size(X,1),size(X,2));
                    V = interpolateTemperature(thermalresults,X,Y,Z);
                    V = reshape(V,size(X));
                    surf(X,Z,V,'LineStyle','none');
                    view(0,90)
                    title('Colored Plot through Y (Length) = 0')
                    xlabel('X (Thickness)')
                    ylabel('Z (Height)')
                    colorbar
                end

             
                %% Finish timing of model and store results
                ThermalResults{i} = thermalresults;

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

        else
            %Solve Models:
            for i = 1:ProcessNum
                
                %% Start Timer and Prepare Foam

                timeri = datetime('now');
                disp(['[&] Starting Process ',num2str(i),' on ',datestr(timeri)])
                    
                %% Solve Model:
                disp(['[Process ',num2str(i),'] [$] Solving Model'])
                if all(modelType=="transient")
                tlist = 0:timeStep:timeE;
                thermalresults = solve(ThermalModel{i},tlist);
                else
                    thermalresults = solve(ThermalModel{i});
                end
                
                disp(['[Process ',num2str(i),'] [+] Model Solved'])
                
                %% Predict R Value:
                
                % Find Temperature at Intersection
                IntersectTemp = interpolateTemperature(thermalresults,Tw,0,0);
                
                % Find R Value:
                dTempRatio = ((TempwI-TempwO)/(IntersectTemp-TempwO)); %Whole Wall dT / Foam dT
                RwM = Rf * dTempRatio;
                RwM = RwM - Rf;
                pErrorT = abs((RwM - Rw)/Rw) * 100; %Percent Error
                
                % Plotting Thermal Contour Map
                if qPlot == 1
                    figure(2)
                
                    [X,Z] = meshgrid(linspace(0,(Tw+Tf)),linspace(-Hw/2,Hw/2));
                    Y = 0.*ones(size(X,1),size(X,2));
                    V = interpolateTemperature(thermalresults,X,Y,Z);
                    V = reshape(V,size(X));
                    surf(X,Z,V,'LineStyle','none');
                    view(0,90)
                    title('Colored Plot through Y (Length) = 0')
                    xlabel('X (Thickness)')
                    ylabel('Z (Height)')
                    colorbar
                end

             
                %% Finish timing of model and store results
                ThermalResults{i} = thermalresults;

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
        
            %% Final Processing and Save:
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
                save(LogSavename,"FAResults","FAResultsD","Specifications","ThermalModel","ThermalResults")
                disp(['[+] Logs have been saved with thermalresults as ',LogSavename])
            else
                disp('[-] Logs have not been saved')
            end
        end
    end


elseif qAT == 4
    
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
       if exist('ThermalResults','var')
           qTRp = input('[?] Would you like to create a plot from the ThermalResults? (1 = yes, 0 = no): ');
       else
           qTRp = 0;
       end
       
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

   %% Plot Thermal Results:
   if qTRp == 1
       gateP = 1;
       while gateP == 1
           qTRpa = input('[?] What row(s) would you like to plot? (-1 = all, or input row index # from FAResults): ');
           if qTRpa == -1
               gateP = 0;
                for i = 1:size(ThermalResults,2)
                    
                    % Create Figure:
                    disp(['[*] Plotting Process #',num2str(i)])
                    fname = ['Results From Process #',num2str(i)];
                    figure('Name',fname)
                    
                    % Pull Necessary Data for This Model:
                    Tw = str2double(Specifications{6,1});
                    Hw = str2double(Specifications{8,1});
                    Tf = FAResultsD(i,3);
        
                    thermalresults = ThermalResults{i};
                    
                    % Create Mesh and Plot:
        
                    [X,Z] = meshgrid(linspace(0,(Tw+Tf)),linspace(-Hw/2,Hw/2));
                    Y = 0.*ones(size(X,1),size(X,2));
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
                disp(['[*] Plotting Process #',num2str(i)])
                fname = ['Results From Process #',num2str(i)];
                figure('Name',fname)
                
                % Pull Necessary Data for This Model:
                Tw = str2double(Specifications{6,1});
                Hw = str2double(Specifications{8,1});
                Tf = FAResultsD(i,3);
    
                thermalresults = ThermalResults{i};
                
                % Create Mesh and Plot:
    
                [X,Z] = meshgrid(linspace(0,(Tw+Tf)),linspace(-Hw/2,Hw/2));
                Y = 0.*ones(size(X,1),size(X,2));
                V = interpolateTemperature(thermalresults,X,Y,Z);
                V = reshape(V,size(X));
                surf(X,Z,V,'LineStyle','none');
                view(0,90)
                title('Colored Plot through Y (Length) = 0')
                xlabel('X (Thickness)')
                ylabel('Z (Height)')
                colorbar
                gateP = input('[?] Would you like to plot more rows? (1 = yes, 0 = no): ');
           end
       end

   else

   end

disp('[+] Analysis Complete')

else
    disp('[-] Quitting Program')
end