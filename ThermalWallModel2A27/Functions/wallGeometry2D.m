function [Lw,Tw,Lf,Tf] = wallGeometry2D(Lwr,Twr,Lfr,Tfr)
%% Description:
% This function allows the program to call and store variables
% If nargin = 0, the variables will be called.
% If nargin = 4, the variables will be stored

if nargin == 0
    if exist("wallGeometry.mat","file")
        load("wallGeometry.mat")
    else
        disp('[!] Unable to call the wallGeometry. Check wallGeometry.m or modelshapew.m')
    end
elseif nargin == 4
    
    Lws = Lwr;
    Tws = Twr;
    Lfs = Lfr;
    Tfs = Tfr;

    save("Functions/wallGeometry.mat")
else
    error('[!] Invalid number of arguments in wallGeometry.m')
end