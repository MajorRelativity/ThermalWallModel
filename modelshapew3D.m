%% Initiation:
clf('reset')
clear

%% Test Data
Tw = 4; % Thickness of the wall is in the x direction
Hw = 5; % Height of the wall is in the z direction
Lw = 6; % Length of the wall is in the y direction

Tf = 1;
Hf = 2;
Lf = 3;


Pointsw = [0 Lw/2 Hw/2; 0 Lw/2 -Hw/2; 0 -Lw/2 Hw/2; 0 -Lw/2 -Hw/2; Tw Lw/2 Hw/2; Tw Lw/2 -Hw/2; Tw -Lw/2 Hw/2; Tw -Lw/2 -Hw/2];
Pointsf = [Tw Lf/2 Hf/2; Tw Lf/2 -Hf/2; Tw -Lf/2 Hf/2; Tw -Lf/2 -Hf/2; (Tw+Tf) Lf/2 Hf/2; (Tw+Tf) Lf/2 -Hf/2; (Tw+Tf) -Lf/2 Hf/2; (Tw+Tf) -Lf/2 -Hf/2];
Points = [Pointsw;Pointsf];
IntSize = 10;

%% Function:

% Create Variables
cLow = 1;
cHigh = IntSize;
IntPointsw = [];

% Index Points:
Index = 1:size(Pointsw,1);
Pointsw = [Index',Pointsw];

Index = 1:size(Pointsf,1);
Pointsf = [Index',Pointsf];

% Interpolate Pointsw
for c = 1:2

    if c == 1
        P = Pointsw;
    elseif c == 2
        P = Pointsf;
    end
    
    for c2 = 1:2

        for n = 1:size(P,1)
            
            Point = P(n,:);
    
            for m = 1:size(P,1)
                % Point 2:
                Point2 = P(m,:);
                if Point2(1) == Point(1)
                else
                    % Interpolate Points:
                    x = linspace(Point(2),Point2(2),IntSize);
                    y = linspace(Point(3),Point2(3),IntSize);
                    z = linspace(Point(4),Point2(4),IntSize);
                    
                    % Place Into Matrix;
                    IntPoints(cLow:cHigh,1) = x;
                    IntPoints(cLow:cHigh,2) = y;
                    IntPoints(cLow:cHigh,3) = z;
                    
                    % Add to Count:
                    cLow = cLow+IntSize;
                    cHigh = cHigh+IntSize;
                
                    %Plot: 
%                     figure(1);
%                     plot3(IntPoints(:,1),IntPoints(:,2),IntPoints(:,3),'bo')
%                     hold on
%                     plot3(Points(:,1),Points(:,2),Points(:,3),'go')
%                     plot3(P(Point(1),2),P(Point(1),3),P(Point(1),4),'ro')
%                     plot3(P(Point2(1),2),P(Point2(1),3),P(Point2(1),4),'mo')
%                     disp(['Red Point = ',num2str(Point(1)),', Magenta Point = ',num2str(Point2(1))])
%                     pause(.1)
%                     clear 1
                end
            end
        end
        
        P = IntPoints;
        Index = 1:size(P,1);
        P = [Index',P];

    end
end

IntPoints = unique(P);


%% Shape Creation and Plot:
gm = alphaShape(IntPoints);
figure(2)
plot(gm)




% [elements,nodes] = boundaryFacets(gm)
% model = createpde
% 
% nodes = nodes';
% elements = elements';
% geometryFromMesh(model,nodes,elements);
% 
% pdegplot(model,'CellLabels','on','FaceAlpha',0.5)