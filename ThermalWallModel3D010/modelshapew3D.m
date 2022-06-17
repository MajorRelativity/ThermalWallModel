function gm = modelshapew3D(model,Lw,Hw,Tw,Lf,Hf,Tf)
% Description: Creates a 3D model of the wall and foam by plotting a grid
% of points in the shape of the model and applying alphaShape

%% Initialization

%Pointsw = [0 Lw/2 Hw/2; 0 Lw/2 -Hw/2; 0 -Lw/2 Hw/2; 0 -Lw/2 -Hw/2; Tw Lw/2 Hw/2; Tw Lw/2 -Hw/2; Tw -Lw/2 Hw/2; Tw -Lw/2 -Hw/2];
%Pointsf = [Tw Lf/2 Hf/2; Tw Lf/2 -Hf/2; Tw -Lf/2 Hf/2; Tw -Lf/2 -Hf/2; (Tw+Tf) Lf/2 Hf/2; (Tw+Tf) Lf/2 -Hf/2; (Tw+Tf) -Lf/2 Hf/2; (Tw+Tf) -Lf/2 -Hf/2];
%Points = [Pointsw;Pointsf];

IntSize = .005; %Controls the spread of points created within the geometry
qRM = 0; % Use reduced size model (only uses the upper left corner of the model)


%% Wall:

% Create Mesh Grid: Creates a 3D mesh grid of all points in the wall
xw = 0:IntSize:Tw;
if qRM == 0
    yw = (-Lw/2):IntSize:(Lw/2);
    zw = (-Hw/2):IntSize:(Hw/2);
elseif qRM == 1
    yw = (0):IntSize:(Lw/2);
    zw = (0):IntSize:(Hw/2);
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
xf = Tw:IntSize:(Tw+Tf);
if qRM == 0
    yf = (-Lf/2):IntSize:(Lf/2);
    zf = (-Hf/2):IntSize:(Hf/2);
elseif qRM == 1
    yf = (0):IntSize:(Lf/2);
    zf = (0):IntSize:(Hf/2);
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