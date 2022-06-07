function [x,y]=modelshapew(bs,s)
%CRACKG Gives geometry data for the crackg PDE model
%
%   NE=CRACKG gives the number of boundary segment
%
%   D=CRACKG(BS) gives a matrix with one column for each boundary segment
%   specified in BS.
%   Row 1 contains the start parameter value.
%   Row 2 contains the end parameter value.
%   Row 3 contains the number of the left hand region.
%   Row 4 contains the number of the right hand region.
%
%   [X,Y]=CRACKG(BS,S) gives coordinates of boundary points. BS specifies the
%   boundary segments and S the corresponding parameter values. BS may be
%   a scalar.

% Copyright 1994-2017 The MathWorks, Inc.

%% Parameter Inputs:

FoamThickness = 1;
FoamLength = 12;
WallThickness = 2;
WallLength = 30;

%The below seems to organize whether the determined box is inside or not
d=[
  0 0 0 0 0 0 0 0 % start parameter value
  1 1 1 1 1 1 1 1 % end parameter value
  0 0 0 0 0 0 0 0 % left hand region
  1 1 1 1 1 1 1 1 % right hand region
];


%% Defining the size of our box globaly and setup calculations:
global Lw
Lw= WallLength

global lw
lw= FoamLength

global tw
tw= FoamThickness

global Tw
Tw= WallThickness

nbs=8;

if nargin==0
  x=nbs; % number of boundary segments
  return
end

bs1=bs(:)';

if find(bs1<1 | bs1>nbs)
  error(message('pde:crackg:InvalidBs'))
end

if nargin==1
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


%% Defines Shape of Model:

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
y(ii)=interp1([d(1,3),d(2,3)],[Lw/2 lw/2],s(ii),'linear','extrap');
end

% boundary segment 4 EF
ii=find(bs==4);
if ~isempty(ii)
x(ii)=interp1([d(1,4),d(2,4)],[Tw Tw+tw],s(ii),'linear','extrap');
y(ii)=interp1([d(1,4),d(2,4)],[lw/2 lw/2],s(ii),'linear','extrap');
end

% boundary segment 5 ED
ii=find(bs==5);
if ~isempty(ii)
x(ii)=interp1([d(1,5),d(2,5)],[Tw+tw Tw+tw],s(ii),'linear','extrap');
y(ii)=interp1([d(1,5),d(2,5)],[lw/2 -lw/2],s(ii),'linear','extrap');
end

% boundary segment 6 CD
ii=find(bs==6);
if ~isempty(ii)
x(ii)=interp1([d(1,6),d(2,6)],[Tw+tw Tw],s(ii),'linear','extrap');
y(ii)=interp1([d(1,6),d(2,6)],[-lw/2 -lw/2],s(ii),'linear','extrap');
end

% boundary segment 7 BC
ii=find(bs==7);
if ~isempty(ii)
x(ii)=interp1([d(1,7),d(2,7)],[Tw Tw],s(ii),'linear','extrap');
y(ii)=interp1([d(1,7),d(2,7)],[-lw/2 -Lw/2],s(ii),'linear','extrap');
end

% boundary segment 8 AB
ii=find(bs==8);
if ~isempty(ii)
x(ii)=interp1([d(1,8),d(2,8)],[Tw 0],s(ii),'linear','extrap');
y(ii)=interp1([d(1,8),d(2,8)],[-Lw/2 -Lw/2],s(ii),'linear','extrap');
end

end

% LocalWords:  Bs