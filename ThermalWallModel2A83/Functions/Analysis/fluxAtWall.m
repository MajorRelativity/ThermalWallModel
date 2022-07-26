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
numMstr = num2str(numM);
Y = linspace(-Lw/2,Lw/2,12);
T = zeros(1,size(Y,2));
C = zeros(1,size(Y,2));

for i = 1:length(Y)
    % Evaluate Heat Flux:
    y = Y(i);
    T(i) = evaluateHeatFlux(thermalresults,x,y);
    C(i) = 1;

    % Display Current State: % NOT FUNCTIONAL YET
    for ii=1:(length(C) + 2)
        switch ii
            case 1
                fprintf(['[*] [613] Evaluating Heat Flux For Model ',numMstr,'[']);
            case (length(C) + 2)
                fprintf(']');
            otherwise
                if C(ii - 1) == 1
                    fprintf('=');
                else
                    fprintf(' ')
                end
        end
    end

end

clear i


%% Plot

disp(['[$] [613] Plotting Model #',numMstr])
fname = ['Heat Flux Across ',qWstr,' Wall from Model #',numMstr];
figure('Name',fname)

plot(y,T,'bo')

title(fname)
xlabel('Length (m)')
ylabel('Heat Flux')

drawnow

end

