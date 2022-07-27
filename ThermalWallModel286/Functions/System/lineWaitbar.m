function lineWaitbar(Fcn,N,numP,numM,msg)
%LINEWAITBAR Summary of this function goes here
%   FCN = The function you want to activate
%       0 = Reset Bar and Delete Line. Run this first
%       1 = Add one to the bar and display it
%       2 = Update bar without adding 1
%   N = Total number of processes

%% Definte Variables:
persistent p
persistent line
persistent psize % size of previous line
barsize = 20; % The desired length of the progress bar

e.numP = false;
e.numM = false;
e.msg = false;

%% Check If Reset Was Requested:
if Fcn == 0
    p = 0;
    line = [];
    psize = 0;
    return
end

%% Determine Existence:

if ~exist('p','var') || isempty(p)
    p = 0;
end

if ~exist('Fcn','var')
    error('[!] You must specify what type of output you want from lineWaitbar')
end

if ~exist('N','var') && ~isempty(N)
    error('[!] You must the total number of processes')
end

if exist('numP','var') && ~isempty(numP)
    e.numP = true;
end

if exist('numM','var') && ~isempty(numM)
    e.numM = true;
end

if exist('msg','var') && ~isempty(msg)
    e.msg = true;
    if ~isa(msg,'char')
        error('[!] msg must be a char array!')
    end
end

%% Rewrite Functions if they Don't Exist:
if ~e.numP
    numP = NaN;
end

if ~e.numM
    numM = NaN;
end

if ~e.msg
    msg = NaN;
end

%% Select Function:

switch Fcn
    case 1
        p = p + 1;
        line = createLine(p,e,N,numP,numM,msg,barsize);
    case 2
        line = createLine(p,e,N,numP,numM,msg,barsize);
end

%% Print Line:
% Backspace previous line:
if psize > 0
    fprintf(repmat('\b', 1, psize));
end

% Print Line:
fprintf(line)

% Get size of line
psize = numel(line) - 1;

end

%% Create Line:
function line = createLine(p,e,N,numP,numM,msg,barsize)

% Initiate line
line = '[*] ';

% Number of Programs
if e.numP
    line = [line,'[',num2str(numP),'] '];
end

% Model Number
if e.numM
    numMstr = num2str(numM);
    line = [line,'[Model ',numMstr,'] '];
end

% Custom Message
if e.msg
    if msg(end) == ' '
        line = [line,msg];
    else
        line = [line,msg,' '];
    end
end 

% Progress Bar
prog = barsize * (p/N);

if prog >= barsize
    line = [line, 'Complete'];
elseif prog < 0
    error(['[!] Something has gone terribly wrong that lead the progrss' ...
        'bar to be negative. Check lineWaitbar.'])
else
    barB = zeros(1,barsize); % Binary Version of the Bar

    for i = 1:prog
        barB(i) = 1;
    end
    
    bar = '['; % Graphical Bar

    for i = barB
        switch i
            case 1
                bar = [bar,'='];
            otherwise
                bar = [bar,' '];
        end
    end
    
    line = [line,bar,']'];

end

    line = [line,'\n']; % Create New Line

end



