function [Lw,Tw,Lf,Tf] = wallGeometry2D(Lwr,Twr,Lfr,Tfr)
%% Description:
% This function allows the program to call and store variables
% If nargin = 0, the variables will be called.
% If nargin = 4, the variables will be stored.
    persistent Lws
    persistent Tws
    persistent Lfs
    persistent Tfs
    
    if nargin == 0
        if isempty(Lws) && isempty(Tws) && isempty(Lfs) && isempty(Tfs)
            error('[!] Unable to call the wallGeometry2D, as it has not recieved variables yet')
        end
        Lw = Lws;
        Tw = Tws;
        Lf = Lfs;
        Tf = Tfs;
    elseif nargin == 4
        Lws = Lwr;
        Tws = Twr;
        Lfs = Lfr;
        Tfs = Tfr;
    else
        error('[!] Invalid number of arguments in wallGeometry2D.m. Either 0 or 4 args required.')
    end
end