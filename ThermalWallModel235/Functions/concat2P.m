function [P] = concat2P(Pline,P,Order)
%CONCAT2P Concatonates the current Collection to the Collection group
%   P is the matrix that contains all of the collections the user intends
%   to run in that session of thermal wall model. Each time a Collection is
%   initialized, it must be added to the matrix. To do so, it uses this
%   function.
%
% - Pline is that specific line of P
% - P is the overall P
% - Order is whether this is a preProgram (0) or a Program (1)

%% User Edited:
% Set the max values below to the maximum length of a preProgram or Program
% respectively

maxpreP = 13; % Must have a value that indicates at least the size of the longest preprogram
maxP = 20; % Must have a value that indicates at least the size of the longest program

%% Body
switch Order
    case 0
        % Add zeros if program size is less than max size
        
        if size(Pline,2) < maxpreP
            Pline = [Pline, zeros(1,maxpreP - size(Pline,2))];
        elseif size(Pline,2) > maxpreP
            error(['[!] Max preProgram Size MUST be updated to ',num2str(size(Pline,2))])
        end
        
    case 1
        if size(Pline,2) < maxP
            Pline = [Pline, zeros(1,maxP - size(Pline,2))];
        elseif size(Pline,2) > maxP
            error(['[!] Max Program Size MUST be updated to ',num2str(size(Pline,2))])
        end
        
end

% Concatonate to P
P = [P;Pline];

end

