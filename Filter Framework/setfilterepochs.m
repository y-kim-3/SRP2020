function f = setfilterepochs(f, filterInput)
% f = setfilterepochs(f, filterInput)
% Sets the wanted recording epochs for the data filter f.  filterInput is
% either a  cell array of filter strings (for multiple data groups), or 
% just one filter string.  Each filter string following the rules in EVALUATEFILTER.m
% Assumes that each animal's data folder has files named 'task##.mat' that
% contain cell structures with task information.

if ~iscell(filterInput)
    error('The cell filter input must be a cell array');
end

for an = 1:length(f)
    if isempty(f(an).animal)
        error(['You must define an animal for the filter before filtering the epochs'])
    end
    datadir = f(an).animal{2};
    animalprefix = f(an).animal{3};
    
    %task = loaddatastruct(datadir,animalprefix,'task');
    f(an).epochs = [];
    f(an).excludetime = [];
    if iscell(filterInput) %if there are multiple filters in a cell array, create multiple epoch groups
        for j = 1:length(filterInput)
            if (length(filterInput{j}) ~= 2)
                error('Epoch filter: Each cell in filterInput must contain {variablename, filterstring}');
            end
            task = loaddatastruct(datadir, animalprefix, filterInput{j}{1});
            if isstr(filterInput{j}{2})              
                f(an).epochs{j} = evaluatefilter(task,filterInput{j}{2});
                if isempty(f(an).epochs)
                    error('Cannot find epochs. Either cannot find task.mat or no epochs in task.mat meet these criteria.');
                end
                f(an).excludetime{j} = [];
                for k = 1:size(f(an).epochs{j},1)                    
                    f(an).excludetime{j}{k} = [];
                end
            else
                error('Epoch filter: Each cell in filterInput must contain {variablename, filterstring}');
            end
        end
    
    else
        error('FILTERINPUT must either be a cell array or a string');
    end
    f(an).arguments.epochs = filterInput;
end

