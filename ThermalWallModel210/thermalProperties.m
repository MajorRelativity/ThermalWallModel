function TC = thermalProperties(location,state,TCw,TCs,SPl,SPu,Tw,propertyStyle)
%% Thermal Properties
switch propertyStyle
    case 'GenericStud'
        Stud = ((location.y>SPu | location.y<SPl).*TCw + (location.y>=SPl & location.y<=SPu).*TCs);
        TC = ((.9*Tw)<location.x)*TCw + ((.9*Tw)>=location.x & (.1*Tw)<=location.x).*Stud + ((.1*Tw)>location.x)*TCw;
    case 'TimeMachine'
        Plate = (Tw<=location.x & Tw+0.0015875>=location.x).*((0.151>location.y & -0.151<location.y).*236 + (0.151<=location.y | -0.151>=location.y).*TCw);
        Stud = ((location.y>SPu | location.y<SPl).*TCw + (location.y>=SPl & location.y<=SPu).*TCs);
        Plywood = ((Tw*.8)<location.x & Tw>location.x)*(TCw*5/1.26); %This is the conversion to the thermal conductivity for the plywood covering the wall
        TC = ((Tw*.8)>=location.x).*Stud + Plywood + Plate + (Tw+0.0015875<location.x)*TCw;
        
end

%% Used to PLot Sample Points if Needed
%figure(1)
%scatter(location.x,location.y,'.','black')
%hold on
end