clearvars -except f figopt

% location = '(isequal($area,''ca1'') && contains($layer,''*sr*''))';
location = '(isequal($area,''ca3'') && (contains($layer,''pyr'') | contains($layer,''sr'')))';
% location = '( isequal($area,''dg'')&& (contains($layer,''val hil'') | contains($layer,''val gc'')))';

% Figure and Font Sizes
set(0,'defaultaxesfontweight','normal'); set(0,'defaultaxeslinewidth',2);
set(0,'defaultaxesfontsize',16);
set(0,'DefaultAxesFontName','Arial')

%figopts:
%2 = average power at 1 timepoint during event (eg SG power immediately
%after ripple onset)
%4 = baseline & SD

%% calculate  power in various freq bands at one timepoint for specific areas
if figopt==2
    set(0,'DefaultAxesFontName','Arial')
    animnames = [];
    animgeno = [];
    cols = [];
    
    for a = 1:length(f)
        results = f(a).output.RTspecgram4.results;
        %load chinfo file to lookup site locations
        animinfo = animaldef(f(a).animal{1});
        infofile = sprintf('%s%schinfo.mat',animinfo{2},animinfo{3});
        load(infofile)
        
        %identify sites in location of interest
        temp = evaluatefilter(chinfo,location);
        sites{a} = unique(temp(:,3));
        [sites{a},siteinds] = intersect(results{1}{1}.probeindex(:,3),sites{a});
        
        probe{a} = [];
        pwr{a} = repmat(-5000,5000,length(siteinds));
        for c = 1:length(siteinds)  %iterate thru selected sites
            %combine data over epochs
            probe{a}{c} = [];
            lastind = 0;
            times = results{1}{1}.times;
            freqs = results{1}{1}.freqs;
            for e = 1:length(results{1})
                [sites{a},siteinds] = intersect(results{1}{e}.probeindex(:,3),sites{a});
                if length(results{1}{e}.freqs)>1 && c<=length(siteinds)
                    probe{a}{c} = cat(3,probe{a}{c},results{1}{e}.Sprobe{1}{siteinds(c)});
                end
            end
        end
        animnames = [animnames; f(a).animal(3) ];
        cols = [cols; f(a).animal{5} ];
        animgeno = [animgeno; f(a).animal(4)];
        
    end
    

    bandnames = {'slow gamma'};
    bands = [4 7];
    timeind = 5;  %time ms after thresh crossing
    
    for b = 1:size(bands,1)
        bandstart = bands(b,1);
        bandend = bands(b,2);
        pwr = [];
        avgpwr = [];
        stdpwr = [];
        stds = [];
        channames = [];
        chancols = [];
        spacing = [1];
        %plot each channel, grouped by animal
        for a=1:length(animnames)
            temp = [];
            for c = 1:length(probe{a}) %for each channel
                temp = [temp mean(squeeze(mean(probe{a}{c}(timeind,bandstart:bandend,:),2)))];
            end
            
            if ~isempty(probe{a})
                avgpwr = [avgpwr mean(temp)];
                stdpwr = [stdpwr std(temp)];  %variation among channels
                pwr = [pwr temp];
            else
                avgpwr = [avgpwr NaN];
                stdpwr = [stdpwr NaN];  %variation among channels
                pwr = [pwr NaN];
            end
            
        end
        bandnames{b}
        avgpwr'

    end
end

%% plot zscore baseline and stdev
%only works with one condition

if figopt ==4
    animnames = [];
    cols = [];
    animgeno = [];
    basechan = [];
    sdchan = [];
    baseline = [];
    sd = [];
    
    for a = 1:length(f)
        results = f(a).output.RTspecgram3.results;
        %load chinfo file to lookup site locations
        animinfo = animaldef(f(a).animal{1});%f(a).animal;
        infofile = sprintf('%s%schinfo.mat',animinfo{2},animinfo{3});
        load(infofile)
        %identify sites in location of interest
        temp = evaluatefilter(chinfo,location);
        sites{a} = unique(temp(:,3));
        [sites{a},siteinds] = intersect(results{1}{1}.probeindex(:,3),sites{a});
        clear temp
        
        basechan = [];
        sdchan = [];
        if(~isempty(siteinds))
            for g = 1:length(results)  %iterate thru conditions
                for c = 1:length(siteinds)  %iterate thru selected sites
                    baseepochs = [];
                    sdepochs = [];
                    freqs = results{g}{1}.freqs;
                    for e = 1:length(results{g}) %combine data over epochs
                        [sites{a},siteinds] = intersect(results{1}{e}.probeindex(:,3),sites{a});
                        baseepochs = cat(3, baseepochs, results{g}{e}.meanPprobe{1}{siteinds(c)});
                        sdepochs = cat(3, sdepochs, results{g}{e}.stdPprobe{1}{siteinds(c)});
                    end
                    basechan = [basechan; mean(baseepochs,3)];  %{a}(c,:) combine data over epochs
                    sdchan = [sdchan; mean(sdepochs,3)];
                end
                baseline = [baseline; mean(basechan,1)];%(a,:) combine data over channels
                sd = [sd; mean(sdchan,1)];
            end
        else
            baseline = [baseline; nan(1,44)];
            sd = [sd; nan(1,44)];
        end
        animnames = [animnames; f(a).animal(3) ];
        cols = [cols; f(a).animal{5} ];
        animgeno = [animgeno; f(a).animal(4)];
    end
    
    bands = [4 7];
    bandnames = {'slow gamma'};
    
    for b = 1:size(bands,1)
        bandstart = bands(b,1);
        bandend = bands(b,2);
        
        for a = 1:length(animnames)
            meanbaseline(a) = mean2(baseline(a,bandstart:bandend));
            meansd(a) = mean2(sd(a,bandstart:bandend));
        end
        disp(bandnames{b})
        meanbaseline'
        meansd'
    end
end
