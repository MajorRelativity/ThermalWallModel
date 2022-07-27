function [x,y]=modelshapew2D(GP,varargin)
%% modelshapew
% Based off of the file CRACKG by MatLab
% modelshapew Gives geometry data for the ThermalWallModel 2D PDE model
%
%   NE=modelshapew(GP) gives the number of boundary segment
%
%   D=modelshapew(GP,varargin) where varargin{1} = BS gives a matrix with one column for each boundary segment
%   specified in BS.
%   Row 1 contains the start parameter value.
%   Row 2 contains the end parameter value.
%   Row 3 contains the number of the left hand region.
%   Row 4 contains the number of the right hand region.
%
%   [X,Y]=modelshapew(GP,varargin) where varargin{1} = BS and 
%   varargin{2} = s gives coordinates of boundary points. BS specifies the
%   boundary segments and S the corresponding parameter values. BS may be
%   a scalar.
%
%

% Copyright 1994-2017 The MathWorks, Inc.



%% Parameter Inputs:

Lw = GP.Wall.L;
Tw = GP.Wall.T;
Lf = GP.Foam.L;
Tf = GP.Foam.T;

% Determine Argument Number
if exist('varargin','var')
    arguments = size(varargin,2);
else
    arguments = 0;
end

% Unpack Variables:
Lw = GP.Wall.L;
Tw = GP.Wall.T;
Lf = GP.Foam.L;
Tf = GP.Foam.T;

switch arguments
    case 1
        bs = varargin{1};
    case 2
        bs = varargin{1};
        s = varargin{2};
end

%% Define number of boundary segments based on property style:
switch GP.propertyStyle
    case 'ComplexNoFoam'
        nbs = 4;
        d=[
            0 0 0 0 % start parameter value
            1 1 1 1 % end parameter value
            0 0 0 0 % left hand region
            1 1 1 1 % right hand region
          ];
    otherwise
        nbs = 8;
        d=[
            0 0 0 0 0 0 0 0 % start parameter value
            1 1 1 1 1 1 1 1 % end parameter value
            0 0 0 0 0 0 0 0 % left hand region
            1 1 1 1 1 1 1 1 % right hand region
          ];

end

%% Defining the size of our box and setup calculations:

if arguments==0
    x=nbs; % number of boundary segments
    return
end

bs1=bs(:)';

if find(bs1<1 | bs1>nbs)
    error(message('pde:crackg:InvalidBs'))
end

if arguments==1
    x=d(:,bs1);
    return
end

x=zeros(size(s));
y=zeros(size(s));
[m,n]=size(bs);

if m==1 && n==1
    bs=bs*ones(size(s)); % expand bs
elseif m~=size(s,1) || n~=size(s,2)
    error(message('pde:crackg:SizeBs'));
end


%% Defines Shape of Model (if both bs and s are given):

switch GP.propertyStyle

    case 'ComplexNoFoam'
        if ~isempty(s)

            % boundary segment 1
            ii=find(bs==1);
            if ~isempty(ii)
                x(ii)=interp1([d(1,1),d(2,1)],[0 0],s(ii),'linear','extrap');
                y(ii)=interp1([d(1,1),d(2,1)],[-Lw/2 Lw/2],s(ii),'linear','extrap');
            end

            % boundary segment 2
            ii=find(bs==2);
            if ~isempty(ii)
                x(ii)=interp1([d(1,2),d(2,2)],[0 Tw],s(ii),'linear','extrap');
                y(ii)=interp1([d(1,2),d(2,2)],[Lw/2 Lw/2],s(ii),'linear','extrap');
            end

            % boundary segment 3
            ii=find(bs==3);
            if ~isempty(ii)
                x(ii)=interp1([d(1,3),d(2,3)],[Tw Tw],s(ii),'linear','extrap');
                y(ii)=interp1([d(1,3),d(2,3)],[Lw/2 -Lw/2],s(ii),'linear','extrap');
            end

            % boundary segment 4
            ii=find(bs==4);
            if ~isempty(ii)
                x(ii)=interp1([d(1,4),d(2,4)],[Tw 0],s(ii),'linear','extrap');
                y(ii)=interp1([d(1,4),d(2,4)],[-Lw/2 -Lw/2],s(ii),'linear','extrap');
            end

        end

    otherwise
        % The generic wall with foam shape that most presets take
        if ~isempty(s)
        
            % boundary segment 1 AH
            ii=find(bs==1);
            if ~isempty(ii)
                x(ii)=interp1([d(1,1),d(2,1)],[0 0],s(ii),'linear','extrap');
                y(ii)=interp1([d(1,1),d(2,1)],[-Lw/2 Lw/2],s(ii),'linear','extrap');
            end
        
            % boundary segment 2 GH
            ii=find(bs==2);
            if ~isempty(ii)
                x(ii)=interp1([d(1,2),d(2,2)],[0 Tw],s(ii),'linear','extrap');
                y(ii)=interp1([d(1,2),d(2,2)],[Lw/2 Lw/2],s(ii),'linear','extrap');
            end
        
            % boundary segment 3 FG
            ii=find(bs==3);
            if ~isempty(ii)
                x(ii)=interp1([d(1,3),d(2,3)],[Tw Tw],s(ii),'linear','extrap');
                y(ii)=interp1([d(1,3),d(2,3)],[Lw/2 Lf/2],s(ii),'linear','extrap');
            end
        
            % boundary segment 4 EF
            ii=find(bs==4);
            if ~isempty(ii)
                x(ii)=interp1([d(1,4),d(2,4)],[Tw Tw+Tf],s(ii),'linear','extrap');
                y(ii)=interp1([d(1,4),d(2,4)],[Lf/2 Lf/2],s(ii),'linear','extrap');
            end
        
            % boundary segment 5 ED
            ii=find(bs==5);
            if ~isempty(ii)
                x(ii)=interp1([d(1,5),d(2,5)],[Tw+Tf Tw+Tf],s(ii),'linear','extrap');
                y(ii)=interp1([d(1,5),d(2,5)],[Lf/2 -Lf/2],s(ii),'linear','extrap');
            end
        
            % boundary segment 6 CD
            ii=find(bs==6);
            if ~isempty(ii)
                x(ii)=interp1([d(1,6),d(2,6)],[Tw+Tf Tw],s(ii),'linear','extrap');
                y(ii)=interp1([d(1,6),d(2,6)],[-Lf/2 -Lf/2],s(ii),'linear','extrap');
            end
        
            % boundary segment 7 BC
            ii=find(bs==7);
            if ~isempty(ii)
                x(ii)=interp1([d(1,7),d(2,7)],[Tw Tw],s(ii),'linear','extrap');
                y(ii)=interp1([d(1,7),d(2,7)],[-Lf/2 -Lw/2],s(ii),'linear','extrap');
            end
        
            % boundary segment 8 AB
            ii=find(bs==8);
            if ~isempty(ii)
                x(ii)=interp1([d(1,8),d(2,8)],[Tw 0],s(ii),'linear','extrap');
                y(ii)=interp1([d(1,8),d(2,8)],[-Lw/2 -Lw/2],s(ii),'linear','extrap');
            end
        
        end
end