function spikeData =spikeSyncAnal(sessionData, sessionTheta)

spikeData = [];
cellIDnum = 0;

thetaData = sessionTheta.data';
starttime = sessionTheta.starttime;
endtime = starttime + ((1/sessionTheta.samprate)*(length(thetaData)-1));
thetaTime = (starttime:(1/sessionTheta.samprate):endtime)';
plot(thetaTime,thetaData)
return

for tetrode = 1:length(sessionData)
    if ~isempty(sessionData{tetrode})
        for clustID = 1:length(sessionData{tetrode})
            if ( (~isempty(sessionData{tetrode}{clustID})) && (~isempty(sessionData{tetrode}{clustID}.data)) )
                cellIDnum = cellIDnum+1;
                tmpSpikeInfo = sessionData{tetrode}{clustID}.data(:,1);
%                 figure
%                 d = diff(tmpSpikeInfo);
%                 d = d(find(d < .5));
%                 d = [d;-d];
%                 edges = [-.3:.0005:.3];
% 
%                 N = histc(d,edges);
%                 bar(edges,N,'histc');
                
                tmpSpikeInfo(:,2) = cellIDnum;
                spikeData = [spikeData; tmpSpikeInfo];
            end
        end
    end
end

spikeData = sortrows(spikeData,1);
 
for i = 1:cellIDnum
    %impulse{i} = gaussian(.5+(.05*i),21);
    impulse{i} = gaussian(1,21);
end
timesnippet = [2050 2060];
%timesnippet = [3285 3290];
%impulse = gaussian(1,11);

numsamples = (timesnippet(2)-timesnippet(1))*10000;
S = zeros(1,numsamples);
playspikes = round((spikeData(find((spikeData(:,1)>timesnippet(1)) & (spikeData(:,1)<timesnippet(2))),1)-timesnippet(1))*10000);
playspikeID = spikeData(find((spikeData(:,1)>timesnippet(1)) & (spikeData(:,1)<timesnippet(2))),2);
for i = 1:length(playspikes)
    S(playspikes(i)-10:playspikes(i)+10) = S(playspikes(i)-10:playspikes(i)+10)+impulse{playspikeID(i)};
end
wavwrite(S,10000,'test.wav');
%sound(S,10000)

gridrate = 200;
numsamples = floor((timesnippet(2)-timesnippet(1))*(gridrate));
timeGrid = timesnippet(1):(1/gridrate):timesnippet(2);
if(length(timeGrid)>numsamples)
    timeGrid = timeGrid(1:end-1);
end
spikeGrid = zeros(1,numsamples);
playspikes = round((spikeData(find((spikeData(:,1)>timesnippet(1)) & (spikeData(:,1)<timesnippet(2))),1)-timesnippet(1))*gridrate);
for i = 1:length(playspikes)
    spikeGrid(playspikes(i)) = spikeGrid(playspikes(i))+1;
end

corrwindow = zeros(1,(gridrate/2)+1);
spikeLoc = find(spikeGrid);
for i = 1:length(spikeLoc)
    if ((spikeLoc(i)>(gridrate/4))&&(spikeLoc(i)<(length(spikeGrid)-(gridrate/4))))
        tmpwindow = spikeGrid(spikeLoc(i)-(gridrate/4):spikeLoc(i)+(gridrate/4));
        %tmpwindow((gridrate/4)+1) = tmpwindow((gridrate/4)+1)-1;
        corrwindow = corrwindow + tmpwindow;
    end
end

bar(corrwindow)






