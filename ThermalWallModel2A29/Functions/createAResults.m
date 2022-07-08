function [AResults,AResultsD,AResultsC] = createAResults(Logs,Version)
%createAResults Stores and Creates the Analysis Results Table

    %% Create AResultsD
    if ~exist('Version','var')
        Version = 0;
    end

    for numA = 1:Logs.numA
        % Create AType Variable by extending it to correct length:
        AType = Logs.AType{numA,1} * ones(Logs.Size{numA,1},1); % Create AType Variable by extending it to correct length

        % Build AResultsD
        AResultsLine = [Logs.Index{numA,1},AType,Logs.duration{numA,1},...
            Logs.Tf{numA,1},Logs.Lf{numA,1},Logs.Hf{numA,1},...
            Logs.pErrorT{numA,1},Logs.RwM{numA,1},Logs.IntersectTemp{numA,1},...
            Logs.StudPosition{numA,1},...
            ];    
        if exist('AResultsD','var')
            AResultsD = [AResultsD; AResultsLine];
        else
            AResultsD = AResultsLine;
        end

    end
    %% Create AResults and AResultsC:
    
    % Clean AResultsD:
    AResultsD = standardizeMissing(AResultsD,-1i);
    
    % Create AResults
    switch Version
        case 0
            AResults = array2table(AResultsD,...
                'VariableNames',{'Process','Analysis Type','Duration (s)',...
                'Foam Thickness','Foam Length','Foam Height',...
                '% Error','Predicted Rwall','Temp at Intersection (K)',...
                'Stud Position (Y Pos in m)'});
        case 1
            AResults = array2table(AResultsD,...
                    'VariableNames',{'Process','AnalysisType','Duration',...
                    'FoamThickness','FoamLength','FoamHeight',...
                    'PercentError','PredictedRwall','TempAtIntersection',...
                    'YPosInMeters'});
    end
    
    % Create Clean Version of AResults
    AResultsC = cleanAResults(AResults);

end


%% Clean AResultsC:
function AResultsC = cleanAResults(AResults)
% Removes all rows that are full of missing values
% Replaces non-standard missing values with NaN

    I = 0;

    while I < size(AResults,2)
        for i = 1:size(AResults,2)
            I = i;
            if all(ismissing(AResults(1,i)))
                missing = true;
                break
            end
            missing = false;
        end

        if missing
            AResults(:,I) = [];
        end       

    end

    AResultsC = standardizeMissing(AResults,-1i);

end



