function [out] = gettdratio_direct(epochs, tdratio, cellinfo, varargin)
% out = gettdratio(animaldir,animalprefix,epochs, tetlist, options)
%
%     animaldir and animal prefix are strings indicating the base director for
%     the animal's data and the prefix for the data files
%
%     epochs is an Nx2 list of days and epochs
%
%     tetlist is a list of tetrodes to use or an empty matrix if the
%     'cellfilter' option is used.
%
% options are
%	'cellfilter', 'cellfilterstring'
%		     specifies a cell filter to select the tetrodes to use for
%		     high theta filtering
% Produces a cell structure with a time field and a normalized theta/delta ratio field
%
% Examples:
% gettdratio('/data/name/Fre', 'fre', epochs, 1)
% gettdratio('/data/name/Fre', 'fre', epochs, [], 'cellfilter', '(isequal($area, ''CA1''))')

% assign the options
cellfilter = '';

for option = 1:2:length(varargin)-1
    switch varargin{option}
        case 'cellfilter'
            cellfilter = varargin{option+1};
        otherwise
            error(['Option ''', varargin{option}, ''' not defined']);
    end
end

%check to see if a cell filter is specified
if (~isempty(cellfilter))
    % this will cause us to ignore tetlist
    d = epochs(1);
    e = epochs(2);
    tetlist =  evaluatefilter(cellinfo{d}{e}, cellfilter);
    tetlist = unique(tetlist(:,1))';
    
end

out = [];

for i = 1:size(epochs,1)
    % if cellfilter is set, apply it to this day and epoch
    if (~isempty(cellfilter))
        tetlist =  evaluatefilter(cellinfo{epochs(i,1)}{epochs(i,2)}, ...
            cellfilter);
        % get rid of the cell indeces and extract only the tetrode numbers
        tetlist = unique(tetlist(:,1))';
    end
    if (~isempty(tetlist))
        
        maxvar = 0;
        td = [];
        times = [];
        
        
        for t = 1:length(tetlist)
            tmptd = tdratio{epochs(i,1)}{epochs(i,2)}{tetlist(t)}.tdr;
            tmptd(find(isnan(tmptd))) = 0;
            if (var(tmptd) > maxvar)
                td = tmptd;
                times = tdratio{epochs(i,1)}{epochs(i,2)}{tetlist(t)}.time;
            end
        end
        out = times';     
        out(:,2) = (td/mean(td))';
    end
end
