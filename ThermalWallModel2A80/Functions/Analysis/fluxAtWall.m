function [] = fluxAtWall(qW,numM,thermalresults,Tw,Lw)
%HEATFLUXATWALL Plots the Heat Flux across one of the two walls
%   qW determines the wall that gets plotted over
%   numM is the model number
%   thermalresults must be one model, and cannot be the full cell

%% Determine Appropriate x
switch qW
    case 1
        qWstr = 'Outdoor';
        x = Tw;
    case 2
        qWstr = 'Indoor';
        x = 0;
    otherwise
        disp('[~] Quitting Script')
        return
end

%% Interpolate Heat Flux:
y = linspace(-Lw/2,Lw/2,12);
T = zeros(1,size(y,2));
c = 1;

for i = y
    T(c) = evaluateHeatFlux(thermalresults,x,i);
    c = c + 1;
end
clear c


%% Plot
numMstr = num2str(numM);
disp(['[$] [613] Plotting Model #',numMstr])
fname = ['Heat Flux Across ',qWstr,' Wall from Model #',numMstr];
figure('Name',fname)

plot(y,T,'bo')

title(fname)
xlabel('Length (m)')
ylabel('Heat Flux')

drawnow

end

