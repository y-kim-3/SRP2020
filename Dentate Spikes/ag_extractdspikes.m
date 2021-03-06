function ag_extractdspikes(directoryname, fileprefix, day, min_suprathresh_duration, nstd, varargin)
%min suprathresh... how long does envelope need to be above threshold to detect as event
%nstd = number of standard deviations

%based on extractripples
%extract dentate spikes
%with no filtering, extracts events that are large - mindur 10ms, 5SD above
%baseline
%exclude any events that coincide with ripples, since the deflection is
%likely to just be the sharp wave
%save one file per session, just like ripples
%
% automatically runs through all eps per day

% Outputs:
%dspikes 	- structue with various fields, including the following which
%			describe each dentate spike.
%	starttime - time of beginning of dspike
%	endtime	  - time of end of dspike
%	midtime   - time of midpoint of energy of event
%	peak	  - peak height of waveform)
%	maxthresh - the largest threshold in stdev units at which this dspike
%			would still be detected.
%	energy	  - total sum squared energy of waveform (area under curve)
%	startind  - index of start time in eeg structure
%	endind    - index of end time in eeg structure
%	midind    - index of middle time in eeg structure
%
%
%defaults
stdev = 0;
baseline = 0;
maxpeakval = 1000;

%goes through the varargin array, finding the labels before each value
%the user might want to specify/change the default values
for option = 1:2:length(varargin)-1
    if isstr(varargin{option})
        switch(varargin{option})
            case 'stdev'
                stdev = varargin{option+1};
            case 'baseline'
                baseline = varargin{option+1};
            case 'maxpeakval'
                maxpeakval = varargin{option+1};
            otherwise
                error(['Option ',varargin{option},' unknown.']);
        end
    else
        error('Options must be strings, followed by the variable');
    end
end

% define the standard deviation for the Gaussian smoother which we
% apply before thresholding (this reduces sensitivity to spurious
% flucutations in the dentate spike envelope)
smoothing_width = 0.004; % 4 ms

%input
d = day;

% move to the directory
%input
cd(directoryname);

%list of all files in folder
tmpflist = dir(sprintf('*eeg%02d-*.mat', day));
%get rip list from pyr1 chan
%to find a site, copy this code and modify slightly
load(sprintf('%s/%schinfo.mat',directoryname,fileprefix))
location = '(isequal($area,''ca1'')&& contains($layer,''pyr 1'')  )';%
pyr1chan = evaluatefilter(chinfo(day),location);
pyr1chan = unique(pyr1chan(:,3));
%all i need to know is what the comments say
for i = 1:length(tmpflist) %iterate through all eps, all chans
    % load the eeg file
    load(tmpflist(i).name);
    % get the epoch number
    dash = find(tmpflist(i).name == '-');
    e = str2num(tmpflist(i).name((dash(1)+1):(dash(2)-1)));
    t = str2num(tmpflist(i).name((dash(2)+1:dash(2)+2)));
    % gives you raw trace envelope
    renv = abs(hilbert(double(eeg{d}{e}{t}.data)));
    
    % smoothing and the envelope:
    % do i need to get rid of smoothing (figure it out)
    samprate = eeg{d}{e}{t}.samprate;
     kernel = gaussian(smoothing_width*samprate, ceil(8*smoothing_width*samprate));
     renv = smoothvect(renv, kernel);
    % calculate the threshold in uV units (microV)
     baseline = mean(renv);
     stdev = std(renv);
    %baseline = mean(abs(double(eeg{d}{e}{t}.data))); %mean(renv);
    %stdev = std(abs(double(eeg{d}{e}{t}.data))); %std(renv);
    %cut off #
    thresh = baseline + nstd * stdev;
    % find the events
    % calculate the duration in terms of samples
    mindur = round(min_suprathresh_duration * samprate);
    
    % extract the events if this is a valid trace
    if (thresh > 0) & any(find(renv<baseline))
        tmpevents = extracteventsnew(renv, thresh, baseline, 0, mindur, 0)';
       %tmpevents = extracteventsnew(double(eeg{d}{e}{t}.data), thresh, baseline, 0, mindur, 0)';
        %eliminate any events within 100ms of ripples; they are
        %sharpwaves
        %probably will be editing this portion, change the window  of
        %restriction, do we need to eliminate events near ripples at all?
        load(sprintf('%s/%sripples%02d.mat',directoryname, fileprefix,day'))
        %ripinds = [ripples{d}{e}{pyr1chan}.startind - 100, ripples{d}{e}{pyr1chan}.endind + 100];
        ripinds = [ripples{d}{e}{pyr1chan}.startind - 100, ripples{d}{e}{pyr1chan}.endind + 100];
        valids = ~isExcluded(tmpevents(:,8),ripinds); %midind anywhere in window of rips
        % Assign the fields
        % start and end indeces
        ds.startind = tmpevents(valids,1);
        ds.endind = tmpevents(valids,2);
        % middle of energy index
        ds.midind = tmpevents(valids,8);
        
        %convert the samples to times for the first three fields
        ds.starttime = eeg{d}{e}{t}.starttime + ds.startind / samprate;
        ds.endtime = eeg{d}{e}{t}.starttime + ds.endind / samprate;
        ds.midtime = eeg{d}{e}{t}.starttime + ds.midind / samprate;
        %gets us information
        ds.peak = tmpevents(valids,3);
        ds.energy = tmpevents(valids,7);
        ds.maxthresh = (tmpevents(valids,9) - baseline) / stdev;
        ds.threshind = tmpevents(valids,10);
        ds.threshtime = eeg{d}{e}{t}.starttime + tmpevents(valids,10) / samprate;
    else
        ds.startind = [];
        ds.endind = [];
        ds.midind = [];
        ds.starttime = [];
        ds.endtime = [];
        ds.midtime = [];
        ds.peak = [];
        ds.energy = [];
    end
    if any(find(renv<baseline))==0
        warning(['No below baseline values in data.  Fields left blank, ',tmpflist(i).name])
    end
    
    ds.timerange = [0 length(renv)/samprate] + eeg{d}{e}{t}.starttime;
    ds.samprate = eeg{d}{e}{t}.samprate;
    ds.threshold = thresh;
    ds.baseline = baseline;
    ds.std = stdev;
    ds.minimum_duration = min_suprathresh_duration;
    
    dspikes{d}{e}{t} = ds;
    clear eeg ds ripples;
end
save(sprintf('%s/%sdspikes%02d.mat', directoryname, fileprefix, d), 'dspikes');
end
