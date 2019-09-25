function extract_spikes(datadir, animaldir, prefix, day, epoch, varargin)
cd(datadir)

taskname = sprintf('%s/%stask.mat',animaldir,prefix);
load(taskname);
nepochs = length(task{day});

fullname = sprintf('%s%02d',prefix,day);
filemaskpath = [datadir '/' fullname];

chinfoname = sprintf('%s/%schinfo.mat',animaldir,prefix);
load(chinfoname);

ccref = 0;
%find first corpus callosum site & load eeg
for c = 1:length(chinfo{day}{epoch})
    if isequal(chinfo{day}{epoch}{c}.area,'cc')
        ccref = c;
        break
    end
end
if ccref==0
    error('Set corpus callosum reference site in chinfo')
end
configfile = sprintf('ch%02d_ref_config.trodesconf',ccref);

extractSpikeBinaryFiles(datadir, fullname, configfile) %extraction code adds '.rec' back

%%add this back  for newer Trodes versions
fullname = filemaskpath(slashind(end)+1:end);
Spikepath = [filemaskpath '.spikes/' fullname '.spikes'];
starttime = task{day}{epoch}.start/1000;
endtime = task{day}{epoch}.end/1000;

for i = 1:32 %read & store data for 1 channel
    Spikepath_chan = sprintf('%s_nt%d.dat',Spikepath, i);
    Spike_chan{i} = readTrodesExtractedDataFile(Spikepath_chan);
    if ~isempty(Spike_chan{i}.fields(1).data)%i~=ccref
        s = 1;
        e = length(Spike_chan{i}.fields(1).data);
        while s<=e && double(Spike_chan{i}.fields(1).data(s))/Spike_chan{i}.clockrate<starttime
            s=s+1;
        end
        while e>0 && double(Spike_chan{i}.fields(1).data(e))/Spike_chan{i}.clockrate>endtime
            e=e-1;
        end
        if s>e %no spikes in time window
            Spike_chan{i}.fields(1).data = [];
            Spike_chan{i}.fields(2).data = [];
        else
            Spike_chan{i}.fields(1).data = Spike_chan{i}.fields(1).data(s:e);
            Spike_chan{i}.fields(2).data = Spike_chan{i}.fields(2).data((s:e),:);
        end
    end
end

for i = 1:32 %read & store data for 1 channel
    clearvars mua
    
    mua{day}{epoch}{i}.timerange = [starttime endtime];
    mua{day}{epoch}{i}.starttime = starttime;
    mua{day}{epoch}{i}.endtime = endtime;
    mua{day}{epoch}{i}.samprate = Spike_chan{i}.clockrate;
    mua{day}{epoch}{i}.nTrode = i;
    mua{day}{epoch}{i}.ref = Spike_chan{i}.referencentrode;
    mua{day}{epoch}{i}.spiketimes = double(Spike_chan{i}.fields(1).data);
    mua{day}{epoch}{i}.waveform = double(Spike_chan{i}.fields(2).data);
    mua{day}{epoch}{i}.descript = 'MUA extracted with exportSpikes, 600-6000Hz filtered, CC reference';
    
    savename = sprintf('%s/%smua%02d-%d-%02d.mat',animaldir,prefix,day,epoch,i);
    save(savename,'mua','-v7.3');
end

end