function [HF,aHF] = fluxAtWall(qW,numM,thermalresults,Tw,Lw)
%HEATFLUXATWALL Plots the Heat Flux across one of the two walls
%   qW determines the wall that gets plotted over
%   numM is the model number
%   thermalresults must be one model, and cannot be the full cell
%
%   Currently, this function lives within program 613, so all displays
%   relate to that program

%% Define Persistent Variables:
persistent HFD
persistent aHFD

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
numMstr = num2str(numM);
Y = linspace(-Lw/2,Lw/2);
F = zeros(1,size(Y,2));
N = length(Y);

% Waitbar:
Q = parallel.pool.DataQueue;
lineWaitbar(0)
bar = @(t)lineWaitbar(1,N,613,numM,['Evaluating Heat Flux (',num2str(t),'): ']);
afterEach(Q, bar);

parfor i = 1:length(Y)
    % Evaluate Heat Flux:
    y = Y(i);
    F(i) = evaluateHeatFlux(thermalresults,x,y);
    send(Q, F(i));
end

clear y
clear i

%% Logs:
I = numM * ones(length(Y),1);
aF = mean(F);
HFD = [HFD;I,Y',F'];
HF = array2table(HFD,...
    'VariableNames',{'Model Number','Ypos','HeatFlux'});
aHFD = [aHFD;numM, aF];
aHF = array2table(aHFD,...
    'VariableNames',{'Model Number','Average HeatFlux'});

%% Plot

disp(['[$] [613] Plotting Model #',numMstr])
fname = ['Heat Flux Across ',qWstr,' Wall from Model #',numMstr];
figure('Name',fname)

plot(Y,F,'bo')

title(fname)
xlabel('Length (m)')
ylabel('Heat Flux')

drawnow

end

