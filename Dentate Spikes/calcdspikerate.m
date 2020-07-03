function out = calcdspikerate(index, excludetimes, dspikes, varargin)
% function out = calcriprates(index, excludetimes, ripples, varargin)
%
% written for a SINGLE channel
% collects all valid data, breaks it up into chunks of size timeint,
% calculates ripple rates for each chunk using bins specified, returns
% rates for each chunk (1 column/chunk)   any remainder time is ignored
% NO BOOTSTRAPPING

% set option defaults
appendindex = 1;  %default
Fs = 1000;
bins = [5 50];

for option = 1:2:length(varargin)-1
    if ischar(varargin{option})
        switch(varargin{option})
            case 'appendindex'
                appendindex = varargin{option+1};
            otherwise
                error(['Option ',varargin{option},' unknown.']);
        end
    else
        error('Options must be strings, followed by the variable');
    end
end

if(~isempty(dspikes{index.epochs(1)}{index.epochs(2)}))
    d = dspikes{index.epochs(1)}{index.epochs(2)}{index.chinfo(1)};
    %  collect all valid times into one
    fulltimes = d.timerange(1):.001:d.timerange(2);
    validtimeinds = find(~isExcluded(fulltimes, excludetimes));
    validtimes = fulltimes(validtimeinds);
    validdur = length(validtimes)/Fs;
    totaldur = length(fulltimes)/Fs;
    
    %exclude events outside inclusion times
    morevalid = find(~isExcluded(d.starttime,excludetimes) & ~isExcluded(d.endtime,excludetimes));
    
    %exclude events that occur on 12+ chans
%     [morevalid, excluded] = getvaliddspikes(dspikes,index);
    %getvaliddspikes(dspikes,index,trigindex,excludetimes, [.4 .4], 3, 0);
    
    validripsizes = d.maxthresh(morevalid);
    counts = histc(validripsizes,bins,1);

    out.rates = counts/validdur;
    out.sizes = validripsizes;
    out.validdur = validdur;
    out.totaldur = totaldur;
    out.baseline = d.baseline;
    out.std = d.std;
    
    if (appendindex)
        out.index = index;
    end
end