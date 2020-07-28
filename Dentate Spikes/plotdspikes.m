
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

window = 500; %time before and after in ms (1ms=1sample); 1sec total  %500
x_shift = 700; %spacing btwn traces for plot x-direction   %700
y_shift=1500; %spacing btwn traces for plot y-direction

load(sprintf('%s/%sdspikes%02d.mat', animaldir, prefix, s)) %loads ripples structure for session 's' (from extract_ripples.m contains information from all events classified as ripples, all chan)
numrips = 10;  %how many ripples to print
starts = dspikes{s}{e}{ctarget(1)}.startind(dspikes{s}{e}{ctarget(1)}.startind<900000);
totalripnum = length(starts);
%rips = randi(totalripnum,1,numrips);

rips = randsample(totalripnum,numrips); %gives 1xnumrips random integers indicating selected ripple events
rips = rips.';

for r = rips
    figure %generate one
    %%get ripple event times
    
    startindex=dspikes{s}{e}{ctarget(1)}.midind(r)-window;
    endindex = dspikes{s}{e}{ctarget(1)}.midind(r)+window;
    timevec = startindex:(startindex+2*window); %build time vector, of the window before and after start index
    
    for c=1:length(dspikes{s}{e}) %To figure out how many channels you have (some are 32, 31, etc)
        
        file = sprintf('%s/%seeg%02d-%d-%02d.mat', animaldir, ...
            prefix, s, e, c); %specifies raw data for the session, epoch, channel
        load(file);
            
        if c<=8 %first shank of plots
            hold on
            axis off
            plot(timevec,eeg{s}{e}{c}.data(startindex:endindex)-c*y_shift)
        elseif c>8 && c<=16 %second shank of plots
            plot((timevec+window+x_shift),eeg{s}{e}{c}.data(startindex:endindex)-(c-8)*y_shift)
        elseif c>16 && c<=24 %third shank of plots
            plot((timevec+2*window+2*x_shift),eeg{s}{e}{c}.data(startindex:endindex)-(c-16)*y_shift)
        elseif c>24 %fourth shank of plots
            plot((timevec+3*window+3*x_shift),eeg{s}{e}{c}.data(startindex:endindex)-(c-24)*y_shift)
        end
    end
    
    set(gcf, 'Position', [1 38 1920 487])
end