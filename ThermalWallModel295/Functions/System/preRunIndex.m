function [preP,numC] = preRunIndex(qCollection)
%PRERUNINDEX Summary of this function goes here
%   Detailed explanation goes here

%% Preallocate Varaibles: 

numC = 1;
preP = [];

%% Create Index
for C = qCollection
    
    switch C
        case -4
            % Collection #-4 - Tool: Save All Figures
            prePline = [122 -4];
        case -3
            % Collection #-3 - Tool: Unit Conversion Tool
            prePline = [101 112 121 -3];
        case -2
            % Collection #-2 - Debug: Display Collection Index
            prePline = -2; %prePrograms always end with their program ID #
            
            % Concatonate to preP
            preP = concat2P(prePline,preP,0);
            
            break
        case 0
            % Ignore
            numC = numC - 1;
            break
        case 1            
            % Collection #1 - Generate Geometry
            prePline = [101 119 103 104 107 112 114 1]; %prePrograms always end with their program ID #

        case 2          
            % Collection #2 - Run Model From Geometry
            prePline = [101 119 104 105 117 106 109 118 107 2]; %prePrograms always end with their program ID #

        case 3          
            % Collection #3 - Contour Slices
            prePline = [101 119 107 3]; %prePrograms always end with their program ID #

        case 4
            % Collection #4 - Get Temperature at Point
            prePline = [101 119 107 4]; %prePrograms always end with their program ID #

        case 5       
            % Collection #5 - Generate Single Geometry with Stud
            prePline = [101 119 103 104 107 112 113 5]; %prePrograms always end with their program ID #

        case 6   
            % Collection #6 - Run Model From Geometry with Mesh Overrides
            prePline = [101 119 103 104 107 112 114 1]; %prePrograms always end with their program ID #
            
        case 51            
            % Collection #51 - 2D Generate Geometry
            prePline = [101 119 112 111 104 108 114 51]; %prePrograms always end with their program ID #

        case 52          
            % Collection #52 - 2D Run Model From Geometry
            prePline = [101 119 104 105 116 106 109 118 108 52]; %prePrograms always end with their program ID #

        case 53          
            % Collection #53 - 2D Contour Plot
            prePline = [101 119 108 53]; %prePrograms always end with their program ID #

        case 54
            % Collection #54 - 2D Get Temperature at Point
            prePline = [101 119 108 54]; %prePrograms always end with their program ID #

        case 55
            % Collection #55 - 2D Generate Single Geometry with Stud
            prePline = [101 119 111 104 108 112 113 55]; %prePrograms always end with their program ID #

        case 56
            % Collection #56 - 2D Plot Current Thermal Properties
            prePline = [101 119 108 112 113 56]; %prePrograms always end with their program ID #

        case 57      
            % Collection #57 - 2D Generate All Stud Analysis Geometries
            prePline = [101 119 111 104 108 112 115 57]; %prePrograms always end with their program ID #

        case 58          
            % Collection #58 - 2D Solve All Stud Analysis Models
            prePline = [101 119 104 105 116 106 109 118 108 58]; %prePrograms always end with their program ID #

        case 59
            % Collection #59 - 2D Create all Foam Analysis Geometries
            prePline = [101 119 104 105 116 106 109 118 108 112 114 110 59]; %prePrograms always end with their program ID #

        case 60
            % Collection #60 - 2D Plot Single Geometry
            prePline = [101 119 104 108 60]; %prePrograms always end with their program ID #

        case 61          
            % Collection #61 - 2D Solve All Foam Analysis Models
            prePline = [101 119 104 105 116 106 109 118 108 61]; %prePrograms always end with their program ID #

        case 62
            % Collection #62 - 2D Generate All Plate Analysis Geometries
            prePline = [101 119 111 104 108 112 113 120 62]; %prePrograms always end with their program ID #

        case 63
            % Collection #63 - 2D Solve All Plate Analysis Models
            prePline = [101 119 104 105 116 106 109 118 108 63]; %prePrograms always end with their program ID #
        case 64
            % Collection #64 - 2D Plot Temperatures Across Intersection
            prePline = [101 119 108 64]; %prePrograms always end with their program ID #
        case 65
            % Collection #65 - 2D Get Average Temperature Across Plate
            prePline = [101 119 108 65]; %prePrograms always end with their program ID #
        case 66
            % Collection #66 - 2D Get Heat Flux at a Point
            prePline = [101 119 108 66]; %prePrograms always end with their program ID #
        case 67
            % Collection #67 - 2D Plot Single Mesh
            prePline = [101 119 104 108 67]; %prePrograms always end with their program ID #
        case 68
            % Collection #68 - 2D Plot Heat Flux Across Wall
            prePline = [101 119 108 68]; %prePrograms always end with their program ID #
        case 69
            % Collection #69 - 2D Plot Full Heat Flux
            prePline = [101 119 108 69]; %prePrograms always end with their program ID #
            

    end
    
    % Concatonate Addition to PreP
    preP = concat2P(prePline,preP,0);
    
    numC = numC + 1;
    
end


end

