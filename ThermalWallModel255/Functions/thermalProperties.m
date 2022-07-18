function TC = thermalProperties(location,state,TP,propertyStyle)
%% Thermal Properties
switch propertyStyle
    case 'GenericStud'
        Stud = ((location.y>TP.Stud.UpB | location.y<TP.Stud.LowB).*TP.Wall.TC + (location.y>=TP.Stud.LowB & location.y<=TP.Stud.UpB).*TP.Stud.TC);
        TC = ((.9*TP.Wall.T)<location.x)*TP.Wall.TC + ((.9*TP.Wall.T)>=location.x & (.1*TP.Wall.T)<=location.x).*Stud + ((.1*TP.Wall.T)>location.x)*TP.Wall.TC;
    case 'TimeMachine'

        % Pieces:
        Plate = (TP.Wall.T<=location.x & TP.Wall.T+TP.Plate.T>=location.x).*...
            ((TP.Plate.L/2>location.y & -TP.Plate.L/2<location.y).*TP.Plate.TC + (TP.Plate.L/2<=location.y | -TP.Plate.L/2>=location.y).*TP.Wall.TC);
        Stud = ((location.y>TP.Stud.UpB | location.y<TP.Stud.LowB).*TP.Wall.TC + (location.y>=TP.Stud.LowB & location.y<=TP.Stud.UpB).*TP.Stud.TC);
        Plywood = ((TP.Wall.T*.8)<location.x & TP.Wall.T>location.x)*(TP.Wall.TC*5/1.26); %This is the conversion to the thermal conductivity for the plywood covering the wall
       
        % Thermal Conductivity:
        TC = ((TP.Wall.T*.8)>=location.x).*Stud + Plywood + Plate + (TP.Wall.T+TP.Plate.T<location.x)*TP.Wall.TC;
     case 'TimeMachineNoPlate'
        % Pieces:
        Stud = ((location.y>TP.Stud.UpB | location.y<TP.Stud.LowB).*TP.Wall.TC + (location.y>=TP.Stud.LowB & location.y<=TP.Stud.UpB).*TP.Stud.TC);
        Plywood = ((TP.Wall.T*.8)<location.x & TP.Wall.T>location.x)*(TP.Wall.TC*5/1.26); %This is the conversion to the thermal conductivity for the plywood covering the wall
       
        % Thermal Conductivity:
        TC = ((TP.Wall.T*.8)>=location.x).*Stud + Plywood + (TP.Wall.T<=location.x)*TP.Wall.TC;
    case 'Complex'
        % Wallboard and Siding Boards
        TP.Wallboard.TC = 0.16019;
        TP.Siding.TC = .088993;
        TP.Wallboard.T = 0.0127;
        TP.Siding.T = 0.0127;
        
        % Find Stud 2 and Stud 3 Positions
        TP.Stud.UpB2 = TP.Stud.UpB + 0.4064; % Places studs 16 inces apart
        TP.Stud.UpB2 = TP.Stud.UpB - 0.4064;

        TP.Stud.LowB2 = TP.Stud.LowB + 0.4064;
        TP.Stud.LowB3 = TP.Stud.LowB - 0.4064;

        % Pieces:
        Plate = (TP.Wall.T<=location.x & TP.Wall.T+TP.Plate.T>=location.x).*...
            ((TP.Plate.L/2>=location.y & -TP.Plate.L/2<=location.y).*TP.Plate.TC + (TP.Plate.L/2<=location.y | -TP.Plate.L/2>=location.y).*TP.Foam.TC);

        Stud = (TP.Wallboard.T<location.x & TP.Wall.T - TP.Siding.T > location.x).*...
            ((location.y >= TP.Stud.LowB & location.y <= TP.Stud.UpB) | (location.y >= TP.Stud.LowB2 & location.y <= TP.Stud.UpB2) | (location.y >= TP.Stud.LowB3 & location.y <= TP.Stud.UpB3)).*...
            TP.Stud.TC +...
            ~((location.y >= TP.Stud.LowB & location.y <= TP.Stud.UpB) | (location.y >= TP.Stud.LowB2 & location.y <= TP.Stud.UpB2) | (location.y >= TP.Stud.LowB3 & location.y <= TP.Stud.UpB3)).*...
            TP.Wall.TC;

        Wallboard = (location.x<TP.Wallboard.T).*TP.Wallboard.TC;

        Siding = (location.x<TP.Wall.T & location.x>(TP.Wall.T - TP.Siding.T)).*TP.Wallboard.TC;

        Foam = (TP.Wall.T+TP.Plate.T<location.x).*TP.Wall.TC;
       
        % Thermal Conductivity:
        TC = Wallboard + Stud + Siding + Plate + Foam;
end

%% Used to PLot Sample Points if Needed
%figure(1)
%scatter(location.x,location.y,'.','black')
%hold on
end