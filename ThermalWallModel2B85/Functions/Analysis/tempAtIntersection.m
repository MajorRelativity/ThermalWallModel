function T = tempAtIntersection(thermalresults,Tw,Lf,numM)
%TEMPATINTERSECTION Summary of this function goes here
%   Detailed explanation goes here

% Interpolate Temperature:
y = linspace(-Lf/2,Lf/2);
T = zeros(1,size(y,2));
c = 1;
for i = y
    T(c) = interpolateTemperature(thermalresults,Tw,i);
    c = c + 1;
end
clear c

% Plot
disp(['[$] [609] Plotting Model #',num2str(numM)])
fname = ['Temperature Across Intersection from Model #',num2str(numM)];
figure('Name',fname)

plot(y,T,'ro')

title(fname)
xlabel('Length (m)')
ylabel('Temperature')

drawnow

end

