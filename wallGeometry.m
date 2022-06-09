function [L,T,l,t] = wallGeometry(Ls,Ts,ls,ts)

%% Description:
% This function allows the program to call and store variables
% If nargin = 0, the variables will be called.
% If nargin = 4, the variables will be stored

if nargin == 0
    if exist("wallGeometry.mat","file")
        load("wallGeometry.mat","L","T","l","t")
    else
        disp('[!] Unable to call the wallGeometry. Check wallGeometry.m or modelshapew.m')
    end
elseif nargin == 4
    L = Ls;
    T = Ts;
    l = ls;
    t = ts;
    save wallGeometry.mat
else
    disp('[!] Invalid number of arguments in wallGeometry.m')
end