function out = calcdspikerate(index, excludetimes, dspikes, varargin)
% function out = calcriprates(index, excludetimes, ripples, varargin)
%
% written for a SINGLE channel
% collects all valid data, breaks it up into chunks of size timeint,
% calculates ripple rates for each chunk using bins specified, returns
% rates for each chunk (1 column/chunk)   any remainder time is ignored
% NO BOOTSTRAPPING

%Yuri's notes
%varargin allows for any number of inputs: "varargin is a 1-by-N cell array, 
%where N is the number of inputs that the function receives after the
%explicitly declared input"

% set option defaults
appendindex = 1;  %default
Fs = 1000;
bins = [5 50]; %default

%CHECK: checks every other varagin array entry, look at function in other
%code to figure out why
for option = 1:2:length(varargin)-1
    %every time an input after the specified inputs is "appendindex" it
    %makes variable appendindex to whatever input that comes after
    if ischar(varargin{option})
        switch(varargin{option})
            case 'appendindex'
                appendindex = varargin{option+1};
            case 'bins'
                bins = varargin(option+1);
            otherwise
                error(['Option ',varargin{option},' unknown.']);
        end
    else
        %error checking
        error('Options must be strings, followed by the variable');
    end
end

%~ = NOT
%goes to see whether there are dspikes based on the f function
if(~isempty(dspikes{index.epochs(1)}{index.epochs(2)}))
    %uses f function to find the dspikes in the correct channel and session
    d = dspikes{index.epochs(1)}{index.epochs(2)}{index.chinfo(1)};
    %  collect all valid times into one from dspike variable
    fulltimes = d.timerange(1):.001:d.timerange(2);
    validtimeinds = find(~isExcluded(fulltimes, excludetimes));
    validtimes = fulltimes(validtimeinds);
    validdur = length(validtimes)/Fs;
    totaldur = length(fulltimes)/Fs;
    
    %exclude events outside inclusion times
    % morevalid = find(~isExcluded(d.starttime,excludetimes) & ~isExcluded(d.endtime,excludetimes));
    
    %exclude events that occur on 12+ chans
    %[morevalid, excluded] = getvaliddspikes(dspikes,index);
    %getvaliddspikes(dspikes,index,trigindex,excludetimes, [.4 .4], 3, 0);
    [morevalid, excluded] = getvaliddspikes(dspikes,index,excludetimes, [.4 .4], 3);
    %makes the group of valid dspikes by looking through the qualifying
    %spikes with good maxthresh values within the timeframe
    validspikesizes = d.maxthresh(morevalid);
    %goes through all the bins and counts the number of spikes
    counts = histc(validspikesizes,bins,1);

    %in this case out = f from runcalcdspikerate
    out.rates = counts/validdur;
    out.sizes = validspikesizes;
    out.validdur = validdur;
    out.totaldur = totaldur;
    out.baseline = d.baseline;
    out.std = d.std;
    %YK 7/15/20 just because
    out.excluded = excluded;
    out.valid = morevalid;
    
    if (appendindex)
        out.index = index;
    end
end