function [] = createAResults()
%createAResults Stores and Creates the Analysis Results Table
%   Detailed explanation goes here

% Foam Analysis:
switch MSD.Overrides.OldVersion
    case 0
        AResults = array2table(AResultsD,...
            'VariableNames',{'Process','Duration (s)','Foam Thickness','Foam Length','Foam Height','% Error','Predicted Rwall','Temp at Intersection (K)' });
    case 1
        AResults = array2table(AResultsD,...
            'VariableNames',{'Process','Duration','FoamThickness','FoamLength','FoamHeight','PercentError','PredictedRwall','TempAtIntersection' });
end

% Stud Analysis
switch MSD.Overrides.OldVersion
    case 0
        AResults = array2table(AResultsD,...
            'VariableNames',{'Process','Duration (s)','Foam Thickness','Foam Length','Foam Height','% Error','Predicted Rwall',...
            'Temp at Intersection (K)','Stud Position (Y Pos in m)'});
    case 1
        AResults = array2table(AResultsD,...
            'VariableNames',{'Process','Duration','FoamThickness','FoamLength','FoamHeight','PercentError','PredictedRwall',...
            'TempAtIntersection','YPosInMeters'});
end