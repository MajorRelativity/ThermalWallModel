function AT = avgPlateTemp(thermalresults,Tw,Lp,numM,MSDLp)
%AVGPLATETEMP Built for Collection 610 to get the temp across the plate
%   MSDLp is the origonal length of the plate as defined 
%   Lp is the length of the plate
%   Tw is the thickness of the wall
%   thermalresults cannot be the full cell array. It can only be one
%   thermalresults object

%% Declare Variable:
persistent ATD

% Check Plate Legnth:
if isnan(Lp)
    Lp = MSDLp;
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
    T(c) = interpolateTemperature(thermalresults,Tw,i);
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

