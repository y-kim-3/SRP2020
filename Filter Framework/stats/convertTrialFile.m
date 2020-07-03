function trialinfo = convertTrialFile(prefix);

trialinfo = []; 
a = loaddatastruct([pwd,'/'],prefix,'trials');
for d = 1:length(a)
     for e = 1:length(a{d})
         fields = fieldnames(a{d}{e});
         for t = 1:length(a{d}{e}.rewarded)
             
             trialinfo{d}{e}{t} = [];
             for f = 1:length(fields)
                tmp = getfield(a{d}{e},fields{f});
                if isnumeric(tmp)                                        
                    trialinfo{d}{e}{t} = setfield(trialinfo{d}{e}{t},fields{f},tmp(t,:));
                else
                    trialinfo{d}{e}{t} = setfield(trialinfo{d}{e}{t},fields{f},tmp{t});
                    
                end
             end
         end
     end
end
     
save([prefix,'trialinfo'],'trialinfo','-v6');