function [morevalid, excluded] = getvaliddspikes(dspikes,index,excludeperiods, win, minstd)


%clean up code, make sure it runs without errors, uncomment stuff!!!

% getvalidrips runs within DF2.0
% given ripples for appopriate day and trigindex,
% Mostvalid criteria: (YURI: things to mess with)
% - larger than threshold SD - (change SD cutoff)
% - not too close to beginning or end of recording (dont change)
% - do not occur during exclude times - (sleeping or moving?)
% - are not detected on more than 12 channels (likely noise) - (events that happen in all 32 channels: garbage - its external ex. mouse bonks head)
%                             (the number 12 can be adjusted)
% IF interripwin is provided, also excludes rips that happen within 1sec of another ripple (endtime - starttime)

% Returns indices of ripples that meet criteria
% Returns exclusion stats [total, noise events, overlapping events]

%extract info from index in  the dspike file
s = index.epochs(1);
e = index.epochs(2);
gc = index.chinfo;
directory = index.animal{2};
prefix = index.animal{3};

d = dspikes{s}{e}{gc};
% d = dspikes;
%validdspikes = find((d.maxthresh >= minstd) & ~isExcluded(d.starttime,excludeperiods) & ~isExcluded(d.endtime,excludeperiods));
dslengths = d.endtime - d.starttime;
% validdspikes = find(dslengths<0.5); %0.05 YURI 7/15/20
%exclude events outside inclusion times
validdspikes = find(dslengths<0.5 & d.maxthresh >= minstd & ~isExcluded(d.starttime,excludeperiods) & ~isExcluded(d.endtime,excludeperiods));
%YK 7/16/20 commented out histogram/figure so they stopped forming when run
%figure
%hist(dslengths)
excluded(1) = length(validdspikes); %initial number of detected nonexcluded rips
%%%%%validdspikes = find(d.maxthresh >= 5)

%YK 7/15/20 taken from getvalidrips
%exclude spikes too close to beginning or end
    while d.starttime(validdspikes(1)) < d.timerange(1)+win(1)
        validdspikes(1) = [];
    end
    
    while d.endtime(validdspikes(end)) > d.timerange(2)-win(2)
        validdspikes(end) = [];
    end

% EJ 4/6/17 changed to eliminate rips that start or end during
% excludeperiods (instead of just overlapping with midpoint)
dspikestarts = d.starttime(validdspikes);
dspikeends = d.endtime(validdspikes);
% YK 7/15/20 comment out inversion code - not working
% location = 'isequal($area,''dg'') && contains($layer,''*val mol 1*'')';
% infofile = sprintf('%s/%schinfo.mat',directory,prefix);
% load(infofile)
% temp = evaluatefilter(chinfo,location);
% mol = unique(temp(:,3));
% 
% file = sprintf('%s/%seeg%02d-%d-%02d.mat', directory, prefix, s, e, gc);
% load(file);
% gceeg = double(eeg{s}{e}{gc}.data);
% file = sprintf('%s/%seeg%02d-%d-%02d.mat', directory, prefix, s, e, mol);
% load(file);
% moleeg = double(eeg{s}{e}{mol}.data);

%ds = [];

mostvalid = [];
counter = zeros(length(dspikestarts),length(dspikes{index.epochs(1)}{index.epochs(2)}));
 for b = 1:length(dspikestarts)%aka go through all the dspikes
    % MAKE SURE CHRONUX NOT ON PATH or wrong findpeaks function
    %finds max values in gcpks, their index at gcpkinds
%     [gcpks, gcpkinds] = findpeaks(gceeg(dspikestarts(b):dspikeends(b)));
%     [~, dspeakind] = max(gcpks);
%     %[molpks, molpkinds] = findpeaks(-1*moleeg(dspikestarts(b):dspikeends(b)));
%     [molpks, molpkinds] = findpeaks(-1*moleeg(dspikestarts(b)+gcpkinds(dspeakind)-50:dspikestarts(b)+gcpkinds(dspeakind)+50));
%     [~, molpeakind] = min(molpks);
%     molpkinds = molpkinds+gcpkinds(dspeakind)-50;
%     %diffs = pdist2(gcpkinds(dspeakind), molpkinds);
%     %if(min(diffs)<10)
%     %    mostvalid = [mostvalid; validdspikes(b)];
%     %end
%     peakdiffs(b) = gcpkinds(dspeakind) - molpkinds(molpeakind);
%     
%     if(dslengths(b) > .1)
% %if(peakdiffs(b)<=10 && peakdiffs(b)>=0)
%         
%         figure
%         plot(real(gceeg(dspikestarts(b):dspikeends(b))))
%         hold on
%         scatter(gcpkinds, gcpks)
%         
%         figure
%         plot(real(moleeg(dspikestarts(b):dspikeends(b))))
%         hold on
%         scatter(molpkinds, -1*molpks)
%         
%     end
    %for each channel, look at all the dspikes in that channel
    
            for c = 1:length(dspikes{index.epochs(1)}{index.epochs(2)})
                r1 = dspikes{index.epochs(1)}{index.epochs(2)}{c};
                % EJ 4/6/17 changed to require noise events to occur at 5SD for detection
                %vr1 = find(r1.maxthresh*r1.std+r1.baseline > d.std*5+d.baseline);
                %YK if the midtime for spike b isn't in this channel's spike
                %midtimes, then that means this spike isn't present in the
                %channel. if it's not in the channel, counter puts a 1 in
                %that plot.
                if find(isExcluded(r1.midtime,[dspikestarts(b) dspikeends(b)]))
                    %if find(isExcluded(r1.midtime,[ripstarts(b) ripends(b)]))
                    counter(b,c) = 1;
                end
            end 
    %detects events that are detected on more than 1 channel
 end
% figure
%     bins = -200:10:200;
% hist(peakdiffs,bins)
%look at how many dspikes were excluded after picking out spikes that don't
%meet the qualifications (in too many channels, not too close to beginning
%or end, etc.)
% excluded(2) = length(validdspikes)-length(mostvalid);
counter = sum(counter,2);
    morevalid = validdspikes(counter<13);
    excluded(2) = length(validdspikes)-length(morevalid);
    
%     if interrip win provided, exclude events that happen within 1sec of another event
%     if (nargin>5)
%         intervals = d.starttime(morevalid(2:end))-d.starttime(morevalid(1:end-1));
%         for i = 1:length(intervals)
%             if intervals(i)<interripwin
%                 morevalid(i) = 0;
%                 morevalid(i+1) = 0;
%             end
%         end
%     end
%     mostvalid = morevalid(morevalid>0);
%     overlaprips = length(morevalid)-length(mostvalid);
%     excluded(3) = overlaprips;

end

