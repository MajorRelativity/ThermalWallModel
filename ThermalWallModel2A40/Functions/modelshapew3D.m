function gm = modelshapew3D(model,qRM,Lw,Hw,Tw,Lf,Hf,Tf)
% Description: Creates a 3D model of the wall and foam by plotting a grid
% of points in the shape of the model and applying alphaShape

%% Initialization

%Pointsw = [0 Lw/2 Hw/2; 0 Lw/2 -Hw/2; 0 -Lw/2 Hw/2; 0 -Lw/2 -Hw/2; Tw Lw/2 Hw/2; Tw Lw/2 -Hw/2; Tw -Lw/2 Hw/2; Tw -Lw/2 -Hw/2];
%Pointsf = [Tw Lf/2 Hf/2; Tw Lf/2 -Hf/2; Tw -Lf/2 Hf/2; Tw -Lf/2 -Hf/2; (Tw+Tf) Lf/2 Hf/2; (Tw+Tf) Lf/2 -Hf/2; (Tw+Tf) -Lf/2 Hf/2; (Tw+Tf) -Lf/2 -Hf/2];
%Points = [Pointsw;Pointsf];

IntSize = .005; %Controls the spread of points created within the geometry

%% Find Wall and Foam # of Points:

PointNum.Lw = Lw/IntSize;
PointNum.Hw = Hw/IntSize;
PointNum.Tw = Tw/IntSize;

PointNum.Lf = Lf/IntSize;
PointNum.Hf = Hf/IntSize;
PointNum.Tf = Tf/IntSize;


%% Wall:

% Create Mesh Grid: Creates a 3D mesh grid of all points in the wall
xw = linspace(0,Tw,PointNum.Tw);
if qRM == 0
    yw = linspace(-Lw/2,Lw/2,PointNum.Lw);
    zw = linspace(-Hw/2,Hw/2,PointNum.Hw);
elseif qRM == 1
    PointNum.Lw = PointNum.Lw/2;
    PointNum.Hw = PointNum.Hw/2;

    yw = linspace(0,Lw/2,PointNum.Lw);
    zw = linspace(0,Hw/2,PointNum.Hw);
end
[Xw, Yw, Zw] = meshgrid(xw,yw,zw);

% Index: calculates a linear index for every point in the mesh grid

Index = 1:(size(Xw,1)*size(Xw,2)*size(Xw,3));

% Pre-Alocation: Prealocates the size of the size of the Interpolated
% Points for the wall:
IntPointsw = zeros(size(Index,2),3);

% Re-Idex Points: Changes all of the mesh-grid points into a list of
% points us linear indexing.
IntPointsw(Index,1) = Xw(Index);
IntPointsw(Index,2) = Yw(Index);
IntPointsw(Index,3) = Zw(Index);

%% Foam (runs same as wall):
xf = linspace(Tw,Tw+Tf,PointNum.Tf);
if qRM == 0
    yf = linspace(-Lf/2,Lf/2,PointNum.Lf);
    zf = linspace(-Hf/2,Hf/2,PointNum.Hf);
elseif qRM == 1
    PointNum.Lf = PointNum.Lf/2;
    PointNum.Hf = PointNum.Hf/2;

    yf = linspace(0,Lf/2,PointNum.Lf);
    zf = linspace(0,Hf/2,PointNum.Hf);
end
[Xf, Yf, Zf] = meshgrid(xf,yf,zf);

Index = 1:(size(Xf,1)*size(Xf,2)*size(Xf,3));
IntPointsf = zeros(size(Index,2),3);

IntPointsf(Index,1) = Xf(Index);
IntPointsf(Index,2) = Yf(Index);
IntPointsf(Index,3) = Zf(Index);

%% Combine: Combines all of the points created and makes sure only unique ones are kept
IntPoints = [IntPointsw;IntPointsf];

IntPoints = unique(IntPoints,'row');


%% Shape Creation:
% Generate Alpha Shape:
Alphagm = alphaShape(IntPoints,IntSize);

% Pick Out Boundary Facts:
[elements,nodes] = boundaryFacets(Alphagm);
nodes = nodes';
elements = elements';

% Create Geometry
gm = geometryFromMesh(model,nodes,elements);

% Clears all other variables
clearvars -except gm