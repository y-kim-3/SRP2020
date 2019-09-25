function out = calcriprates2(index, excludetimes, ripples, varargin)
% function out = calcriprates(index, excludetimes, ripples, varargin)
%
% written for a SINGLE channel
% collects all valid data, breaks it up into chunks of size timeint,
% calculates ripple rates for each chunk using bins specified, returns
% rates for each chunk (1 column/chunk)   any remainder time is ignored
% NO BOOTSTRAPPING

% set option defaults
appendindex = 1;  %default
bins = [3 5 7 50];
timebins = 0:5:120;

for option = 1:2:length(varargin)-1
    if ischar(varargin{option})
        switch(varargin{option})
            case 'appendindex'
                appendindex = varargin{option+1};
            case 'bins'
                bins = varargin{option+1};
            case 'timebins'
                timebins = varargin{option+1};
            otherwise
                error(['Option ',varargin{option},' unknown.']);
        end
    else
        error('Options must be strings, followed by the variable');
    end
end

if(~isempty(ripples{index.epochs(1)}{index.epochs(2)}))
    rips = ripples{index.epochs(1)}{index.epochs(2)}{index.chinfo(1)};
    Fs = rips.samprate;
    %  collect all valid times into one
    fulltimes = rips.timerange(1):1/Fs:rips.timerange(2);
    validtimeinds = find(~isExcluded(fulltimes, excludetimes));
    validtimes = fulltimes(validtimeinds);
    validdur = length(validtimes)/Fs;
    totaldur = length(fulltimes)/Fs;   %should be same as timerange(2)-timerange(1)

    trigindex = [index.epochs(1) index.epochs(2) index.chinfo(1)];
    [morevalid, excluded] = getvalidrips(ripples,index,trigindex,excludetimes, [0.4 0.4], 3, 0);

    validripsizes = rips.maxthresh(morevalid);
    timebinsize = timebins(2) - timebins(1);
    validriptimes = rips.starttime(morevalid)/60; %rip times in minutes
    counts = histc(validripsizes,bins,1);
    timecounts = histc(validriptimes,timebins,1)/(timebinsize*60); %rips per second
    rates = counts/validdur;
    if ~isempty(rates)
        timerates = timecounts/rates(1);
    else
        timerates = 0;
    end
    sizes = validripsizes;

    out.rates = rates;
    out.counts = counts;
    out.sizes = sizes;
    out.excluded = excluded;
    out.timecounts = timecounts;
    out.timerates = timerates;
    out.validdur = validdur;
    out.totaldur = totaldur;
    out.baseline = rips.baseline;
    out.std = rips.std;
    
    if (appendindex)
        out.index = index;
    end
end