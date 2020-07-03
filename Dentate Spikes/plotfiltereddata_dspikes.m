
Fs=1000;  %sampling freq (/sec)
s = d;
e = 1;

%identify ca1 pyr channel
location = '(isequal($area,''dg'')&& (contains($layer,''gc'')||contains($layer,''hil'')))';  %search terms to search for 'pyr 1' (best pyr chan) in 'ca1' (to be searched inside 'chinfo')
load(sprintf('%s/%schinfo.mat',animaldir,prefix)) %loads chinfo
temp = evaluatefilter(chinfo,location); %Opens chinfo returns matches from 'location' in format [session, epoch, channel] (some repeated values because of chinfo)
if(isempty(temp))
    error('Chinfo must contain at least one gc channel');
end
ctarget = unique(temp(:,3)); %(':,3) looks specifically in col3 for the unique entries
        
window = 5000; %time after start in ms (1ms=1sample)
y_shift=400; %spacing btwn traces for plot y-direction

%load filters
    load('agthetafilter.mat')
    load('aglowgamfilter.mat')
    load('agdeltafilter.mat')
    load('agspindlefilter.mat')
    load('ejdsfilter2.mat')
    
load(sprintf('%s/%spos%02d.mat', animaldir, prefix, s)) %loads position information for session 's'
eegfile = sprintf('%s/%seeg%02d-%d-%02d.mat', animaldir, ...
            prefix, s, e, ctarget(1)); %specifies raw data for the session, epoch, channel
load(eegfile);
eegs = double(eeg{s}{e}{ctarget(1)}.data);
numsamples = 10;  %how many chunks of data to print
load(sprintf('%s/%sdspikes%02d.mat', animaldir, prefix, s))
ds = dspikes{s}{e}{ctarget(1)};
totalDS = length(dspikes{s}{e}{ctarget(1)}.startind); %total ds number (counted by start ind)
randDS = randi(totalDS,1,numsamples); %gives 1xnumrips random integers indicating selected ripple events
starts = ds.startind(randDS);

for r = 1:length(starts)
    figure
    set(gcf,'Position',[61 440 2000 616]);

    %build time vec
    timevec = starts(r)-window:starts(r)+window; %build time vector, of the window before and after start index

    %plot raw trace
    plot(timevec,eegs(timevec)','k','Linewidth',2);
    hold on
    
    %filter and calculate ratios
    theta = hilbert(filtfilt(thetafilter.kernel,1,eegs(timevec)));
    %thetaenv = abs(theta);
    delta = hilbert(filtfilt(deltafilter.kernel,1,eegs(timevec)));
    %deltaenv = abs(delta);
    lowgam = hilbert(filtfilt(lowgamfilter.kernel,1,eegs(timevec)));
    spindle = hilbert(filtfilt(spindlefilter.kernel,1,eegs(timevec)));
    dsattempt = hilbert(filtfilt(dsfilter.kernel,1,eegs(timevec)));

    plot(timevec,delta-y_shift,'b','Linewidth',2)
    plot(timevec,theta-2*y_shift,'g','Linewidth',2)
    plot(timevec,spindle-3*y_shift,'c','Linewidth',2)
    plot(timevec,dsattempt-4*y_shift,'r','Linewidth',2)
    plot(timevec,lowgam-5*y_shift,'m','Linewidth',2)
    %ratios on same line (plot)
    %velocity
%     starttime = lookup(eeg{s}{e}{ctarget}.starttime+starts(r)-window/Fs,pos{s}{e}.time); %find matching times
%     endtime = lookup(eeg{s}{e}{ctarget}.starttime+(starts(r)+window)/Fs,pos{s}{e}.time);
%     interptimes = linspace(pos{s}{e}.time(starttime),pos{s}{e}.time(endtime),window+1); %make new time vector with Fs1000
%     vels = interp1(pos{s}{e}.time(starttime:endtime),pos{s}{e}.vel(starttime:endtime),interptimes);  %interpolate vels over new vector (increase Fs)
%     %plot(timevec,-6*y_shift*ones(1,window+1),'k') %line at 0
%     %plot(timevec,(-6*y_shift+110)*ones(1,window+1),'k--') %line at 10
%     plot(timevec,100*vels-6*y_shift,'Linewidth',2)  %velocity **x100** to make visible
%     plot(timevec,-6.5*y_shift*ones(1,window+1),'w') %invisible line to extend plot area
%     labels = {'velocity','ratios','lowgam','theta','delta','raw'};
xlim([starts(r)-500, starts(r)+500])
     set(gca,'xtick',[])
    set(gca, 'XTickLabel', '')
    set(gca,'ytick',[])
    set(gca, 'YTickLabel', '')
    xpos = mean(xlim);
    %text(repmat(xpos,7,1),[-6*y_shift:y_shift:0], labels','horizontalalignment','center','Rotation',0,'FontSize',16)
    title(sprintf('%s s%d, e%d, c%d, r%d. window is %02d sec.', prefix, s, e, ctarget, r, window/Fs))
    axis tight
    box off 
    
    
end