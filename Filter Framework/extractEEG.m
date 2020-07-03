function [filtData, timestamps] = extractEEG(filename,NumChannels, channels, headerExists) 

% rec file

if (nargin < 4)
    headerExists = 1;
end


sampleFreq = 25000;
downSampleFactor = 25;
bandpassLow = .1;
bandpassHigh = 300;
[c,d] = butter(2, [bandpassLow bandpassHigh]/(sampleFreq/2));


fid = fopen(filename,'r');

headersize = 0;
if (headerExists)
    junk = fread(fid,10000,'char');
    headersize = strfind(junk','</Configuration>')+16;
    frewind(fid);
end
junk = fread(fid,headersize,'char');
junk = fread(fid,1,'int16');
timestamps = fread(fid,[1,inf],'1*uint32=>uint32',2+(NumChannels*2))';
timestamps = double(timestamps)/25000;
frewind(fid);


filtData = [];
thetaFiltData = [];
refData = [];


for i = 1:length(channels)  
    junk = fread(fid,headersize,'char');
    junk = fread(fid,1,'int16');
    junk = fread(fid,1,'uint32');
    junk = fread(fid,channels(i)-1,'int16');
    channelData = fread(fid,[1,inf],'1*int16=>int16',4+(NumChannels*2))';
    %if the file got cut off...
    if (length(channelData) < length(timestamps))
        channelData(end+1) = channelData(end);
    end
    frewind(fid);
    
    channelData = double(channelData);
    channelData = channelData * 12500;
    channelData = channelData / 65536;
    channelData = filtfilt(c,d,channelData);
    
    filtData = [filtData int16(channelData)];
    
    
end

filtData = downsample(filtData,downSampleFactor);
timestamps = downsample(timestamps,downSampleFactor);

fclose(fid);




