function [Temp,aTemp] = tempAtIntersection(thermalresults,Tw,Lw,numM,PN)
%TEMPATINTERSECTION Plots and obtains all temperatures across Tw
%   Tw is the wall thickness
%   Lf is the length of the foam
%   PN is the number of points that will be plotted

%% Define variables
persistent TempD
persistent aTempD

%% Interpolate Temperature:
Y = linspace(-Lw/2,Lw/2,PN);
T = zeros(1,length(Y));

% Waitbar
gcp;

Q = parallel.pool.DataQueue;
lineWaitbar(0)
N = length(Y);
bar = @(t)lineWaitbar(1,N,609,numM,['Evaluating Temperature (',num2str(t),'): ']);
afterEach(Q, bar);
lineWaitbar(2,N,609,numM,'Evaluating Temperature: ')

% Interpolation
for i = 1:length(Y)
    y = Y(i);
    T(i) = interpolateTemperature(thermalresults,Tw,y);
    send(Q, T(i));
end
clear c

%% Logs:
I = numM * ones(length(Y),1);
aT = mean(T);
TempD = [TempD;I,Y',T'];
Temp = array2table(TempD,...
    'VariableNames',{'Model Number','Ypos','Temperature'});
aTempD = [aTempD;numM, aT];
aTemp = array2table(aTempD,...
    'VariableNames',{'Model Number','Average Temperature'});

%% Plot
disp(['[$] [609] Plotting Model #',num2str(numM)])
fname = ['Temperature Across Intersection from Model #',num2str(numM)];
figure('Name',fname)

plot(Y,T,'ro')

title(fname)
xlabel('Length (m)')
ylabel('Temperature')

drawnow

end

