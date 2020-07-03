function out = loaddatastruct(animaldir, animalprefix, datatype, indices)

% out = loaddatastruct(animaldir, animalprefix, datatype)
% out = loaddatastruct(animaldir, animalprefix, datatype, indices)
%
% Load the components of a data cell array of combines then into one
% variable.  Datatype is a string with the base name of the files.  If INDICES
% is omitted, all files are loaded and the data are combined.  Otherwise, 
% only the data for the specified indices will be included. Each index
% takes up a row in the input, and can be [days] or [days epochs] or 
%[days epochs ...].

if (nargin < 4)
    indices = [];
end
out = [];
% datafiles = dir([animaldir, animalprefix,'*', datatype,'*']);
datafiles = dir([animaldir, animalprefix,datatype,'*']);
if(length(datafiles)==0) 
    error('File not found. Confirm that animaldef is correct and that all files are in the correct folder.');
end
for i = 1:length(datafiles)
    fileDataIndex = [];
    fileDataIndexStrings = regexp(datafiles(i).name,'\d+[-.]','match'); %pull out the index strings
    for indNum = 1:length(fileDataIndexStrings)
        fileDataIndex(1,indNum) = str2num(fileDataIndexStrings{indNum}(1:end-1)); %convert index string to numeric
    end
    
    if isempty(indices)
        load([animaldir,datafiles(i).name]);
        
        eval(['out = datavaradd(out,',datatype,',fileDataIndex);']);
    else
        if (size(indices,2) == size(fileDataIndex,2)) %the index depth matches the storage depth
            
            indexmatch = sum(ismember(indices,fileDataIndex,'rows'));
            if (indexmatch)
                load([animaldir,datafiles(i).name]);
                eval(['out = datavaradd(out,',datatype,',fileDataIndex);']); %add the whole file
                if isnumeric(out)
                    error(['Error while indexing variable ''',datatype,'''']);
                end
            end
        elseif (size(indices,2) > size(fileDataIndex,2)) %the index depth is higher detail than the storage depth
            
            %when a file is loaded, there is a chance that multiple indices
            %use that file
            indexmatch = find(ismember(indices(:,1:size(fileDataIndex,2)),fileDataIndex,'rows'));           
            if (~isempty(indexmatch))
                loadindex = indices(indexmatch,:);
                load([animaldir,datafiles(i).name]);               
                eval(['out = datavaradd(out,',datatype,',loadindex);']); %add only the parts of the file that match the indices
                if isnumeric(out)
                    error(['Error while indexing variable ''',datatype,'''']);
                end
            elseif isempty(fileDataIndex)
                load([animaldir,datafiles(i).name]);
                eval(['out = datavaradd(out,',datatype,',indices);']); %add only the parts of the file that match the indices
                if isnumeric(out)
                    error(['Error while indexing variable ''',datatype,'''']);
                end
            end
        elseif (size(indices,2) < size(fileDataIndex,2)) %the index depth is lower detail than storage depth
            
            indexmatch = sum(ismember(indices,fileDataIndex(1:size(indices,2)),'rows'));
            if (indexmatch)
                load([animaldir,datafiles(i).name]);
                if (strcmp(datatype,'HPeeg'))
                    datatype='eeg';
                end
                eval(['out = datavaradd(out,',datatype,',fileDataIndex);']); %add the whole file
                if isnumeric(out)
                    error(['Error while indexing variable ''',datatype,'''']);
                end
            end
        end
               
    end
end


%--------------------------------------
function out = datavaradd(origvar, addcell, index)


out = origvar;
if isempty(index) %no index given, so start over with the input
    out = addcell;    
else
    
    for i = 1:size(index,1)
        str = ['{',num2str(index(i,:)),'}'];
        str = regexprep(str,'\s+','}{');
        
        try         
            eval(['origvar',str,'=','addcell',str,';']);
        catch
            disp(['Index ',str,' does not exist.']);
            out = -1;
            return;
        end
        
    end
    out = origvar;
end


        
