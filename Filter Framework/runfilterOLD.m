function f = runfilter(f)

for an = 1:length(f)
    
    animaldir = f(an).animal{2};
    animalprefix = f(an).animal{3};
    totalepochs = [];
    
    totalepochs = [];
    for g = 1:length(f(an).epochs)
        totalepochs = [totalepochs; f(an).epochs{g}];
    end
    totalepochs = unique(totalepochs,'rows');
    
    
    foptions = f(an).function.options;
    
     if isfield(f(an).output, f(an).function.name)
         eval(['f(an).output.',f(an).function.name,'=[];']);
         f(an).output = rmfield(f(an).output,f(an).function.name);
     end
    
    for g = 1:length(f(an).epochs)
        
        for e = 1:size(f(an).epochs{g},1)
            
            disp(['Group ',num2str(g),', Epoch [',num2str(f(an).epochs{g}(e,:)),']']);
            loadstring = [];
            for lv = 1:length(f(an).function.loadvariables)
                
                if isfield(f(an).data,f(an).function.loadvariables{lv})
                    %if the load variable was already defined in the data
                    %filter, only load the filtered data
                    try
                        loadindex = getfield(f(an).data,f(an).function.loadvariables{lv},{g});
                        loadindex = loadindex{1}{e};
                        loadindex = [repmat(f(an).epochs{g}(e,:), [size(loadindex,1) 1]) loadindex];
                        eval([f(an).function.loadvariables{lv},' = loaddatastruct(animaldir, animalprefix, f(an).function.loadvariables{lv}, loadindex);']);
                    catch
                        eval([f(an).function.loadvariables{lv},' = loaddatastruct(animaldir, animalprefix, f(an).function.loadvariables{lv}, f(an).epochs{g}(e,:));']);
                    end

                else
                    %otherwise, load the entire dataset for the epoch
                    eval([f(an).function.loadvariables{lv},' = loaddatastruct(animaldir, animalprefix, f(an).function.loadvariables{lv}, f(an).epochs{g}(e,:));']);
                end
                loadstring = [loadstring, f(an).function.loadvariables{lv},','];
            end
            fields = fieldnames(f(an).data);
            tmpindex = [];            
            for fnum = 1:length(fields)
                tmpdatafilter = getfield(f(an).data,fields{fnum});
                if ((length(tmpdatafilter) >= g) && (length(tmpdatafilter{g}) >= e)) %check to make sure that the data was defines for this group
                    tmpindex = setfield(tmpindex,fields{fnum},tmpdatafilter{g}{e});
                end
            end
            tmpindex.epochs = f(an).epochs{g}(e,:);
            excludeperiods = f(an).excludetime{g}{e};
            
            %We store the result in a field named after the function
            eval(['f(an).output.',f(an).function.name,'.results{g}{e} = ',f(an).function.name,'(tmpindex,excludeperiods,', loadstring, 'foptions{:});']);
            eval(['f(an).output.',f(an).function.name,'.loadvariables = f(an).function.loadvariables;']);
            eval(['f(an).output.',f(an).function.name,'.options = f(an).function.options;']);
            
        end
    end
end
        
    
    


    
