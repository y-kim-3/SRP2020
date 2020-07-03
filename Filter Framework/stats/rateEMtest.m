function [EMrates,percentChange] = rateEM(trialdata, bininfo, binborders)

InstantRates = ones(1,length(binborders)-1);
EMrates = ones(length(trialdata),length(binborders)-1);    
oldEMrates = ones(length(trialdata),length(binborders)-1); 
ActualRates = [];
learningRate = .05;

for i = 1:length(trialdata)
    
    tmptimes = trialdata{i};
    tmpbininfo = bininfo{i};
    
    spikecounts = histc(tmptimes,binborders);
    occupancy = histc(tmpbininfo,binborders)*(1/30);
    spikecounts = spikecounts(1:end-1);
    occupancy = occupancy(1:end-1);
    spikecounts = spikecounts(:);
    occupancy = occupancy(:);
    
 
    
    
    %spikecounts = smoothvect(spikecounts(:),gaussian(2,21));
    %occupancy = smoothvect(occupancy(:),gaussian(2,21));
    
    %spikecounts = smoothvect(spikecounts(:),gaussian(2,17));
    %occupancy = smoothvect(occupancy(:),gaussian(2,17));
    
    ActualRates(i,1:length(binborders)-1) = (spikecounts./occupancy)';
    
end



for EMloop = 1:100
    for i = 1:length(trialdata)
        
        InstantRates = InstantRates + learningRate*(ActualRates(i,:)-InstantRates);
        EMrates(i,:) = InstantRates;
        
    end
    for i = length(trialdata):-1:1
        
        InstantRates = InstantRates + learningRate*(ActualRates(i,:)-InstantRates);
        %EMrates(i,:) = InstantRates;
        
    end
    percentChange = (EMrates-oldEMrates)./oldEMrates;
    maxpercentChange = max(percentChange(:));
end


