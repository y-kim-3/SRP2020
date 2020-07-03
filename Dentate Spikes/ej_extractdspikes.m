function ej_extractdspikes(directoryname, fileprefix, day, min_suprathresh_duration, nstd, varargin)
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
%	energy	  - total sum squared energy of waveform
%	startind  - index of start time in eeg structure
%	endind    - index of end time in eeg structure
%	midind    - index of middle time in eeg structure
%
%
%defaults
stdev = 0;
baseline = 0;
maxpeakval = 1000;
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
% flucutations in the ripple envelope)
smoothing_width = 0.004; % 4 ms

d = day;

% move to the directory
cd(directoryname);

tmpflist = dir(sprintf('*eeg%02d-*.mat', day));
%get rip list from pyr1 chan
load(sprintf('%s/%schinfo.mat',directoryname,fileprefix))
location = '(isequal($area,''ca1'')&& contains($layer,''pyr 1'')  )';%
pyr1chan = evaluatefilter(chinfo(day),location);
pyr1chan = unique(pyr1chan(:,3));

    for i = 1:length(tmpflist) %iterate through all eps, all chans
        % load the ripple file
        load(tmpflist(i).name);
        % get the epoch number
        dash = find(tmpflist(i).name == '-');
        e = str2num(tmpflist(i).name((dash(1)+1):(dash(2)-1)));
        t = str2num(tmpflist(i).name((dash(2)+1:dash(2)+2)));
        % raw trace envelope
        %eeg{d}{e}{t}.data(eeg{d}{e}{t}.data<0) = 0;
        renv = abs(hilbert(double(eeg{d}{e}{t}.data)));
        
        % smooth the envelope:
        samprate = eeg{d}{e}{t}.samprate;
        kernel = gaussian(smoothing_width*samprate, ceil(8*smoothing_width*samprate));
        renv = smoothvect(renv, kernel);
        % calculate the threshold in uV units        
        baseline = mean(abs(double(eeg{d}{e}{t}.data))); %mean(renv);
        stdev = std(abs(double(eeg{d}{e}{t}.data))); %std(renv);
        thresh = baseline + nstd * stdev;
        % find the events
        % calculate the duration in terms of samples
        mindur = round(min_suprathresh_duration * samprate);
        
        % extract the events if this is a valid trace
        if (thresh > 0) && any(find(renv<baseline))
            tmpevents = extracteventsnew(double(eeg{d}{e}{t}.data), thresh, baseline, 0, mindur, 0)'; %renv
            
%             for ev = 1:length(tmpevents)
%                 [gcpks, gcpkinds] = findpeaks(double(eeg{d}{e}{t}.data(tmpevents(ev,1):tmpevents(ev,2))));
%                 
%                 figure
%                 plot(real(eeg{d}{e}{t}.data(tmpevents(ev,1):tmpevents(ev,2))))
%                 hold on
%                 scatter(gcpkinds, gcpks)
%                 
%                 figure
%                 plot((renv(tmpevents(ev,1):tmpevents(ev,2)) - baseline)/stdev)
%             end

            %eliminate any events within 100ms of ripples; they are
            %sharpwaves
            load(sprintf('%s/%sripples%02d.mat',directoryname, fileprefix,day'))
            %EJ 6/2/17 increased to 200ms as used in Bragin 1999 paper
            ripinds = [ripples{d}{e}{pyr1chan}.startind - 100, ripples{d}{e}{pyr1chan}.endind + 100];
            valids = ~isExcluded(tmpevents(:,8),ripinds);
            %outside = ~isExcluded(tmpevents(:,8),ripinds); %midind anywhere in window of rips
            %ripinds = [ripples{d}{e}{pyr1chan}.startind - 50, ripples{d}{e}{pyr1chan}.endind + 50];
            %inside = logical(isExcluded(tmpevents(:,8),ripinds));
            %valids = outside & inside;
            %valids = ((tmpevents(:,9) - baseline) / stdev) > 5;
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
            ds.peak = tmpevents(valids,3);
            ds.energy = tmpevents(valids,7);
            ds.maxthresh = (tmpevents(valids,9) - baseline) / stdev;
            ds.maxpeak = (tmpevents(valids,3) - baseline) / stdev;
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
