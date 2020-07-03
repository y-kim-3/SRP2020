function spikes = convertSpikesFile(prefix);

trialinfo = []; 
spikes = loaddatastruct([pwd,'/'],prefix,'spikes');
ci = loaddatastruct([pwd,'/'],prefix,'cellinfo');
for d = 1:length(spikes)
    for e = 1:length(spikes{d})
        for t = 1:length(spikes{d}{e})
            if ~isempty(spikes{d}{e}{t})
                for c = 1:length(spikes{d}{e}{t})
                    if ~isempty(spikes{d}{e}{t}{c})
                        
                        
                        fields = fieldnames(ci{d}{e}{t}{c});
                        
                        for f = 1:length(fields)
                            tmp = getfield(ci{d}{e}{t}{c},fields{f});
                            spikes{d}{e}{t}{c} = setfield(spikes{d}{e}{t}{c},fields{f},tmp);
                            
                        end
                    end
                end
            end
        end
    end
end

     
save([prefix,'spikes'],'spikes','-v6');