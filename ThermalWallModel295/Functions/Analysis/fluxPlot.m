function [] = fluxPlot(thermalmodel,thermalresults,numM,HFSF)
%FLUXPLOT Plots the heat flux for the entire thermal model
%   Associated with Program 614
%   This program requires both the thermalmodel and the thermalresults
%   HFSF = Scale factor for the heat flux

% Evaluate
[qx,qy] = evaluateHeatFlux(thermalresults);
qx = qx .* HFSF;
qy = qy .* HFSF;

% Name
numMstr = num2str(numM);
HFSFstr = num2str(HFSF);
fname = ['Heat Flux Plot from Model #',numMstr,' - HF Scale = ',HFSFstr];
figure('Name',fname)

% Plot
pdeplot(thermalmodel,'FlowData',[qx qy])

% Labels
title(fname)
xlabel('Thickness')
ylabel('Length')

drawnow

end

