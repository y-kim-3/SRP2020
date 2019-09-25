function eeg = convertToFilterFramework_trodes_optimized(datadir,animaldir,prefix,session,channels)
%createDataFilterLFPFiles(filename,dest,animalID)
% MK Trodes modified by AG 3/5/15, modified by EJ 4/8/15

%This function extracts LFP information and saves data in the FilterFramework format.
%The filename is a .rec file (an output file of Trodes). should contain animal prefix and recording session
%dest -- the directory where the processed files should be saved for the
%animal
%animalpref -- a string identifying the animal's prefix (appended to the
%beginning of the files).
%sessionNum -- session number, also specified in the .rec filename
%channels -- array of channels to load
%   MUST BE CONSECUTIVE AND START AT 1
%Uses <animalprefix>task.mat in same directory to divide the recording session into epochs and define the
% other descriptors.
%example, if the recoring file is called jim02_date time etc.rec, then the task
%file should be called jimtask.mat.

%% Task Setup
%load task file
taskname = sprintf('%s/%stask.mat',animaldir,prefix);
load(taskname);
nepochs = length(task{session});

for e = 1:nepochs
    if(~strcmp(task{session}{e}.env, 'FAIL') && ~strcmp(task{session}{e}.descript, 'FAIL'))
        %%get config info
        currentTimeRange = [task{session}{e}.start/1000 task{session}{e}.end/1000];
        if(nepochs>1)
            sessstr = sprintf('%s%02d-%02d',prefix,session,e);
        else
            sessstr = sprintf('%s%02d',prefix,session);
        end
        filename = sprintf('%s/%s.rec',datadir,sessstr);
        configInfo = readTrodesFileConfig_optimized(filename);
        samplingRate = str2num(configInfo.samplingRate);
        numChannels = str2num(configInfo.numChannels);
        headerSize = str2num(configInfo.headerSize); %removed in newest Trodes release (06-30-2017)
        configSize = configInfo.configSize;
        numCards = numChannels/32;
        
        
        %% Channel Setup
        %map channels to nTrodes
        hwChannels = [];
        displist = [];
        for trodeInd = 1:length(configInfo.nTrodes)
            for channelInd = 1:length(configInfo.nTrodes(trodeInd).channelInfo)
                hwRead = str2num(configInfo.nTrodes(trodeInd).channelInfo(channelInd).hwChan);
                new_hw_chan =  (mod(hwRead,32)*numCards)+floor(hwRead/32)+1;
                hwChannels = [hwChannels new_hw_chan];
            end
        end
        disp(displist);
        
        %create filter
        downSampleFactor = samplingRate/1000;
        bandpassLow = .1;
        bandpassHigh = 300;
        [c,d] = butter(2, [bandpassLow bandpassHigh]/(samplingRate/2));
        
        %% Read in file
        %open recording file
        fid = fopen(filename,'r');
        disp('Reading timestamps...');
        
        %read & downsample timestamps
        fseek(fid, configSize+headerSize*2, 'bof'); %move the pointer
        timestamps = (fread(fid,[1,inf],'1*uint32=>double',(2*headerSize)+(numChannels*2))')/samplingRate;
        
        %janky fix for timestamps bug
        frame = (timestamps(end) - timestamps(1))/length(timestamps);
        indices = [1:length(timestamps)];
        timestamps = timestamps(1) + frame*(indices'-1);
        timestamps = downsample(timestamps,downSampleFactor);
        
        fclose(fid);
        
        %for each channel, read & save data
        parpool('local', 6); %run the following loop on 6 cores
        parfor i = 1:length(channels)
        %for i = 1:length(channels)
            disp(['Reading channel ',num2str(channels(i)),'...']);
            
            %read, format, filter, & downsample data for 1 channel
            fid = fopen(filename,'r');
            
            fseek(fid, configSize+headerSize*2+4+2*(hwChannels(channels(i))-1), 'bof'); %move the pointer
            channelData = fread(fid,[1,inf],'1*int16=>int16',(2*headerSize)+2+(numChannels*2))';
            channelData = double(channelData)*-1; %reverse the sign to make spike point up
            channelData = channelData * 12500/65536; %convert to uV, divide by 2^16 for some reason
            channelData = int16(filtfilt(c,d,channelData));   %filter first
            channelData = downsample(channelData,downSampleFactor);   %then downsample
            
            %eeg{1,currentSession}{1,e}{1,i} = struct();
            epochDataInd = find((timestamps >= currentTimeRange(1))&(timestamps < currentTimeRange(2)));
            eeg_temp{i}.timerange = [timestamps(epochDataInd(1)) timestamps(epochDataInd(end))];
            eeg_temp{i}.starttime = timestamps(epochDataInd(1));
            eeg_temp{i}.endtime = timestamps(epochDataInd(end));
            eeg_temp{i}.samprate = 1000;
            eeg_temp{i}.nTrode = i;
            eeg_temp{i}.nTrodeChannel = 1;
            eeg_temp{i}.data = channelData(epochDataInd,1);
            eeg_temp{i}.descript = 'No description';
            
            fclose(fid);
        end
        delete(gcp); %shut down the parallel pool
        
        %save to correct structure, separate from parfor loop to prevent
        %classification error
        for i = 1:length(channels)
            clearvars eeg;
            eeg{session}{e}{channels(i)} = eeg_temp{i};
            savename = sprintf('%s/%seeg%02d-%d-%02d.mat',animaldir,prefix,session,e,channels(i));  %epochString
            save(savename,'-v6','eeg');
        end
    end
end