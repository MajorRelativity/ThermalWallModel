function [preP,numC] = preRunIndex(qCollection)
%PRERUNINDEX Summary of this function goes here
%   Detailed explanation goes here

%% Preallocate Varaibles: 

maxpreP = 10; % Must have a value that indicates the size of the longest preprogram
numC = 1;

%% Create Index
for C = qCollection
    
    switch C
        case -2
            % Program #-2 - Debug: Display Collection Index
            prePline = -2; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                error(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
            
            break
        case 0
            % Ignore
            numC = numC - 1;
            break
        case 1            
            % Program #1 - Generate Geometry
            prePline = [101 119 103 104 107 112 114 1]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                error(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
       case 2          
            % Program #2 - Run Model From Geometry
            prePline = [101 119 104 105 117 106 109 118 107 2]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                error(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
       case 3          
            % Program #3 - Contour Slices
            prePline = [101 119 107 3]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                error(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
        case 4
            % Program #4 - Get Temperature at Point
            prePline = [101 119 107 4]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                error(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
       case 51            
            % Program #51 - 2D Generate Geometry
            prePline = [101 119 112 111 104 108 114 51]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                error(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
       case 52          
            % Program #52 - 2D Run Model From Geometry
            prePline = [101 119 104 105 116 106 109 118 108 52]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                error(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
       case 53          
            % Program #53 - 2D Contour Plot
            prePline = [101 119 108 53]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                error(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
        case 54
            % Program #54 - 2D Get Temperature at Point
            prePline = [101 119 108 54]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                error(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
        case 55
            % Program #55 - 2D Generate Single Geometry with Stud
            prePline = [101 119 111 104 108 112 113 55]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                error(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
        case 56
            % Program #56 - 2D Plot Current Thermal Properties
            prePline = [101 119 108 112 113 56]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                error(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
        case 57      
            % Program #57 - 2D Generate All Geometries with Stud
            prePline = [101 119 111 104 108 112 115 57]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                error(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end
        case 58          
            % Program #58 - 2D Solve All Stud Analysis Models
            prePline = [101 119 104 105 116 106 109 118 108 58]; %prePrograms always end with their program ID #

            % Add zeros if program size is less than max size

            if size(prePline,2) < maxpreP
                prePline = [prePline, zeros(1,maxpreP - size(prePline,2))];
            elseif size(prePline,2) > maxpreP
                error(['[!] Max preProgram Size MUST be updated to ',num2str(size(prePline,2))])
            end

            % Concatonate to P

            if exist('preP','var')
                preP = [preP;prePline];
            else
                preP = prePline;
            end

    end
    
    numC = numC + 1;
    
end


end

